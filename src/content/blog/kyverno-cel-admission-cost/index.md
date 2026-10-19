---
date: 2026-10-19
title: "Half of Kyverno's CEL admission cost was not policy evaluation"
tags:
  - General
  - Performance
excerpt: "A profile of the CEL admission path showed that 86% of what Kyverno's engine allocated went into preparing the object, not evaluating policy. Here is why, what we changed, and what the numbers look like now."
authors:
  - name: Raunak Madan
draft: false
---

Kyverno's CEL engines exist to evaluate policy expressions. So when we profiled the admission path, we expected to find the cost in CEL evaluation.

It was not there. **About 86% of what the engine allocated went into preparing the object for evaluation, and almost none of it into evaluating policy.**

We went looking because public benchmarks kept putting Kyverno behind the alternatives. Those benchmarks measured the legacy `ClusterPolicy` engine, which did have a real regression at the time, and the usual answer was to point people at the newer CEL-based engine instead. That answer was right and incomplete: nobody had checked what the CEL engine itself was spending its time on.

This post is about where that cost came from, why it scaled with the number of policies you deploy, and what removing it did. The fix ships in Kyverno 1.19.2.

Read the limitations section before you quote any number here. Everything below is measured on a single machine, and most of it is a Go benchmark rather than a live cluster.

## Where a CEL admission request spent its memory

Kyverno's CEL engines evaluate policies against a CEL _activation_: a set of variables your policy expressions can reference. One of those variables is `request`, the `AdmissionRequest` the API server sent, converted into the unstructured map form CEL understands.

Here is a heap profile of the `ValidatingPolicy` engine handling admission requests, before and after the change, by share of total allocated bytes:

![Where a ValidatingPolicy request spends its allocations](./assets/c4-where-allocation-goes.png)

Before, `ConvertObjectToUnstructured` accounted for 86.8% of everything the engine allocated. CEL evaluation itself barely registered. After, object conversion falls to 2.9%, and the largest single frame becomes `evaluateWithData` — the code that actually runs your policy expressions.

The same pattern shows up in the `MutatingPolicy` engine, which was paying a smaller but still substantial version of the same cost:

![Share of allocated bytes spent converting the admission object](./assets/c1-conversion-alloc-share.png)

One caveat on reading those profiles: the post-fix benchmark completes more iterations in the same time because it is faster, so the two profiles have different absolute totals. Compare the shares, not the raw bytes. Per-request figures come from the benchmark table further down.

## Why: the request was converted once per policy

The engine looped over every policy that matched an incoming request. Inside that loop, it built the `request` activation value — which meant calling `utils.ConvertObjectToUnstructured(request)` on every iteration.

That function is cheap for an object that is already unstructured. An `AdmissionRequest` is not. Its `Object` and `OldObject` fields are `runtime.RawExtension`, which implements `json.Marshaler`, so the reflective walk hits a fast-exit path that marshals and then re-parses the entire admitted payload. Every time.

With the Pod Security Standards policy set, roughly 16 policies match a typical Pod creation. So Kyverno serialized and re-parsed the same Pod about 16 times per request, and the cost scaled with both your policy count and the size of the object being admitted.

![One admission request, sixteen matched policies](./assets/c7-before-after-diagram.png)

The object does not change between policies. There was never a reason to convert it more than once.

## The fix: build it once per request

The change moves the `request` activation build out of the per-policy loop and into the request, so every matched policy reuses one map.

The interesting part is how the map gets built without changing what your policies see. The engine takes a value copy of the `*AdmissionRequest`, zeroes out the `Object` and `OldObject` `RawExtension` fields, and runs the _same_ SDK conversion function over the blanked copy. With the payload blobs zeroed, the reflective walk only touches cheap scalars, group-version-kind maps, user info, and options — the expensive marshal and re-parse of the admitted object never happens. The object is then spliced back in.

Reusing the existing conversion function matters: equivalence with the old behavior is structural rather than something a maintainer has to keep in their head.

### The part we nearly got wrong

The first version of this change used a single shared helper for all the CEL engines. Testing caught that it silently changed policy behavior, because the engines did not agree on what `request.object` meant.

`ValidatingPolicy` and `GeneratingPolicy` built `request` with one conversion call and no splice, so `request.object` was a plain, un-normalized parse of the bytes the API server sent, with no group-version-kind or namespace injected. An empty side, such as `object` on a DELETE, surfaced as CEL null.

`MutatingPolicy` spliced in normalized objects unconditionally, so an empty side surfaced as a typed-nil map — which CEL reads as a present, non-null, empty map.

Unifying them would have flipped two things for anyone with policies already deployed: `has(request.object.metadata.namespace)` would start returning true on a namespace-omitting CREATE for validating policies, and `request.object == null` would start returning true on a DELETE for mutating policies. Both are user-visible changes to how deployed policies behave, and neither belongs in a performance fix.

So there are two builders instead of one, sharing the same fast core, each preserving exactly the contract its engines already had. Unifying them is a real conversation worth having — it just needs its own issue, its own sign-off, and its own release note.

Equivalence is pinned by golden tests that run the literal original formula as the oracle across CREATE, UPDATE, DELETE, and CONNECT, with and without optional fields, using type-sensitive comparison so an int64 quietly becoming a float64 fails the test. Two more tests pin the exact semantic flips described above by compiling and evaluating real CEL.

## What changed

The benchmark drives the real per-policy loop with a realistically sized Pod and a varying number of matched policies.

![Allocations per admission request, by number of matched policies](./assets/c2-vpol-allocs-per-op.png)

![Time per admission request, by number of matched policies](./assets/c3-vpol-time-per-op.png)

| Matched policies | Allocations before | Allocations after | Time before | Time after |
| ---------------- | ------------------ | ----------------- | ----------- | ---------- |
| 1                | 2,327              | 854               | 0.31 ms     | 0.10 ms    |
| 16               | 37,055             | 2,718             | 4.91 ms     | 0.16 ms    |
| 64               | 148,131            | 8,672             | 20.01 ms    | 0.36 ms    |

The `MutatingPolicy` engine improves on the same curve, from 258,943 to 52,689 allocations and 10.59 ms to 2.97 ms at 64 policies.

The slope is the point, not the headline multiple. Before the change, allocations grew about 63 times going from 1 policy to 64. After, about 10 times — and that residual growth is CEL evaluation, which is the work you deployed the policies to get. Object preparation is now constant per request instead of proportional to how many policies you run.

Practically: adding policies to a Kyverno deployment used to carry a hidden per-policy serialization cost on top of the evaluation you asked for. It no longer does.

## The fifth engine

A follow-up change extends the same fix to the image verification engine, which lives outside the other CEL engines' directory and had grown its own private copy of the converter. It rebuilt the request map for match conditions, again for every policy exception, and again for every pod template in extraction mode — `2N + E` redundant builds per request before the validation branch even started.

The win there is allocation, not wall-clock time: image verification is dominated by the network cost of fetching signatures and attestations, and we are not going to claim otherwise.

The root cause is worth naming, because it is more useful than either fix. There was no single place where a CEL activation got assembled, so five engines each grew their own. A shared choke point that every Kubernetes-mode engine has to call would make this class of bug impossible for the sixth engine. That work is still open.

## How this compares to native admission policies

With the per-policy tax gone, it is worth asking where Kyverno's CEL engine actually sits against the API server's own `ValidatingAdmissionPolicy`.

Running the same 16 Pod Security Standards policies through both engines on one cluster, the answer depends on how many policies you enforce:

![Which engine is faster depends on how many policies you enforce](./assets/c5-crossover.png)

At one policy, native is ahead: about 9.2 ms against Kyverno's 12.8 ms. At the full 16-policy set, Kyverno is ahead: about 20 ms against native's 29 ms.

Those numbers were measured on Kyverno 1.19.0, which predates the change described above. The Kyverno side of that chart should now be better than shown; we have not re-run the comparison.

Two cost curves with different slopes cross. Native pays a per-policy dispatch cost that scales with policy count — roughly 0.26 cores per policy, all of it on the API server. Kyverno pays a per-request cost for receiving the object over a webhook, which is fixed and therefore amortizes as you add policies. Below the crossover, native wins; above it, Kyverno does.

That framing only became accurate with this fix. Kyverno's cost was not fixed per request before it — it was per policy, which is exactly why the curve looked the way it did.

The CPU side is more one-sided. Under matched load, Kyverno's engine used about 3.2 cores against the API server's 8.2 for native. The surprise in the API server profile is that 67% of its CPU sits in the policy dispatch machinery while the actual CEL bytecode execution is about 5.5% — the cost is dispatching 16 policies and building an input for each, not evaluating them. And that load lands on the control plane, which you cannot scale horizontally the way you can scale a Kyverno deployment.

Both numbers come from a single-host setup where the webhook hop is loopback and effectively free. On a real multi-node cluster that hop costs real latency on every Kyverno request, which narrows the latency gap and matters most at low policy counts. The CPU finding does not depend on topology.

## The legacy engine, briefly

The benchmarks that prompted this work measured `ClusterPolicy`, the older non-CEL engine, so it is worth saying what happened there.

We reproduced the regression with a version ladder: four releases, a fresh cluster for each run, eight rounds in shuffled order so no version is systematically first or last, with results taken as a geometric mean against the 1.13.6 baseline.

![Legacy ClusterPolicy admission latency, measured against 1.13.6](./assets/c6-legacy-ladder-heatmap.png)

The regression is real, it is between 12% and 23% depending on load, and the step lands between 1.16.4 and 1.17.0 — where the engine started deep-copying the entire evaluation context on every checkpoint, to fix a separate bug about rule-local data leaking between rules.

The fix replaces that with a shallow snapshot plus copy-on-write at the path level, so the copy only happens when a write actually follows a checkpoint. The engine benchmark returns to roughly where it was before the regression — 1,206,838 ns per operation down to 905,979, against a pre-regression 1.16.4 baseline of 943,529 — and the deep-copy frame leaves the allocation profile entirely. The rule-isolation guarantee it was protecting still holds, pinned by a regression test that fails on the pre-fix commit.

That ships in 1.19.2 alongside the CEL work. It is deliberately not on `main`: the legacy engine is on its way out, and we would rather spend the effort on the engine that is replacing it.

## What is still slow

- The engine still pays one JSON round-trip of the admitted object per request, to preserve the raw, un-normalized parse that `request.object` has always exposed. Evaluating against the typed object, or a cheaper representation, would remove even that — but it would change what policies see, so it needs its own design.
- There is still no shared choke point for CEL activation assembly, which is the reason five engines each grew their own converter.
- Mutating policies thread full objects between policies rather than propagating a patch diff. A patch-only model is a substantially larger redesign and is not implemented.
- Tail latency under sustained load at a single replica is not addressed by any of this, and we have not re-measured it since. If you saw variance like the trials that opened this post, that specific problem is still open.

## Limitations

- **Single machine.** Everything here reproduces the _relationship_ between configurations, not the absolute numbers you would see on a 32-core server.
- **Most of this is a Go benchmark.** The allocation and timing figures come from benchmarks driving the real engine loop, and the profiles come from those benchmark runs. They isolate the engine cleanly, and they exclude network, serialization at the webhook boundary, and etcd.
- **We did not measure the fixed build on a cluster.** There is no before-and-after admission latency number from a live cluster under load. That is the obvious next step, and cluster latency includes costs this change does not touch.
- **The engine comparison uses loopback,** so the webhook network hop is excluded, and dry-run, so the etcd write is excluded.
- **The native side runs Kyverno's generated policies,** which is a faithful same-policy comparison rather than a hand-tuned native policy set.
- Side controllers were disabled in these runs. Only the admission controller was active.

## Reproduce it

The harness is in the Kyverno repository under `docs/perf-testing/`: the version ladder, the pinned Pod Security Standards policy set, the k6 scripts, and the cluster setup. The engine benchmarks live beside the code they measure, in `pkg/cel/policies/vpol/engine` and `pkg/engine/context`.

If you benchmark Kyverno and get a result you do not like, please publish it — with the method, the caveats, and the per-trial numbers. That is how this work started.

## Thanks

Thanks to [Mert Erdinç](https://merdincz.com/en/comparing-kubernetes-policy-engines/), whose careful, well-documented comparison of policy engines prompted us to go looking.

## References

- [#17572](https://github.com/kyverno/kyverno/pull/17572) — build the request activation once per admission request
- [#17585](https://github.com/kyverno/kyverno/pull/17585) — hoist the request-map build in the image verification engine
- [#17565](https://github.com/kyverno/kyverno/pull/17565) — reduce engine context checkpoint copy cost
