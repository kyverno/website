---
date: 2026-05-22
title: Your Cluster Has No Rules. ValidatingPolicy Fixes That.
tags:
  - General
authors:
  - name: Kirti Goyal
excerpt: Learn how Kyverno ValidatingPolicy works with real-world examples for enforcing labels, resource limits, trusted registries, and production safeguards in Kubernetes.
draft: true
---

Something that surprises most people when they first start working with Kubernetes is that
by default, a cluster will accept almost anything thrown at it.

No resource limits? Sure. No labels? Fine. Privileged containers? Go ahead.
That's completely fine for learning.

But in a real shared cluster, one bad manifest can:

- consume all node resources,
- bypass security controls,
- or create deployments that become impossible to manage later.

Kubernetes doesn't judge. It just runs whatever it's told to. That's why rules become necessary.

That's when Kyverno's `ValidatingPolicy` comes in.

## What ValidatingPolicy actually does

You can think of it like an automated code review that runs on every resource before it enters the cluster.

Except instead of relying on a human reviewer who might miss something or approve a bad change during a busy day, the policy runs automatically on every request.

Every time someone runs `kubectl apply`, Kyverno intercepts that request and evaluates
the policy expression. If the expression returns `true`, the resource passes. If it
returns `false`, the resource is blocked and the person gets the error message back.

## Two modes: block it or just watch it

Before writing anything, there's one decision to make for every ValidatingPolicy:
either block violations, or just report them?

```yaml
validationActions:
  - Deny # blocks the request, so nothing gets created
```

```yaml
validationActions:
  - Audit # allows the request but logs the violation in a PolicyReport
```

This matters more than it seems. When introducing a new policy to an existing cluster,
starting with `Deny` is almost never the right move. It'll block things that are already
running and cause incidents.

**The safer approach**: start with `Audit` first. Let it run for a few days, see what it
catches, fix the existing violations, then switch to `Deny`.

Think of Audit as "silent observer mode." The rule is running. Violations are being
recorded. Nothing is breaking. It's just gathering information before the lever gets pulled.

## The anatomy of a ValidatingPolicy

Here's the full structure, so nothing in the examples below surprises you:

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: your-policy-name
spec:
  validationActions:
    - Deny # or Audit
  matchConstraints:
    resourceRules:
      - apiGroups: [''] # '' means core API group (Pods, Services, etc.)
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE'] # when does this policy run?
        resources: ['pods'] # which resource type?
  validations:
    - expression: 'your CEL expression here' # must return true to pass
      message: 'what the user sees when blocked'
```

Four things to understand:

- **`matchConstraints`**: This is the **filter**. Which resources does this policy apply to? Like which API group, which operations. Think of it as deciding who gets checked at this particular door.

- **`operations`**: `CREATE` only catches new resources. Add `UPDATE` to also catch
  changes to existing ones. Most security policies should include both otherwise someone
  can create a compliant resource and then edit it to remove the required fields.

- **`validations.expression`**: This is the actual rule that's written in CEL. It must evaluate to `true` for the resource to be allowed. If it evaluates to `false`, Kyverno blocks it.

- **`validations.message`**: This is what the developer sees when they're blocked. Make this
  useful. Just seeing "Validation failed" tells nobody anything. Whereas, "All containers must define resource limits. See the platform docs for guidance" is actually helpful.

## Use case 1: Require labels on every Pod

This is the most common ValidatingPolicy there is. Labels are how teams organize, monitor, and route traffic in Kubernetes. A Pod without proper labels is like an unlabeled box
in a warehouse. Good luck finding it when something goes wrong at 2 AM.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-team-label
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: >
        has(object.metadata.labels) &&
        'team' in object.metadata.labels &&
        object.metadata.labels['team'] != ''
      message: "Every Pod must have a 'team' label with a non-empty value."
```

**Try it:**

Apply the policy:

```bash
kubectl apply -f require-team-label.yaml
```

Try creating a Pod without the label:

```bash
kubectl run nginx --image=nginx
```

**Expected output:**

```text
Error from server: admission webhook "validate.kyverno.svc" denied the request:
Every Pod must have a 'team' label with a non-empty value.
```

Now create one with the label:

```bash
kubectl run nginx --image=nginx --labels team=platform
```

This time it goes through. That's the full cycle: deny, fix, allow.

## Use case 2: Enforce resource limits

This one is critical for any shared cluster. Without resource limits, one badly
configured Pod can consume all the CPU and memory on a node and take down everything
else running alongside it.
Think of it like one person at an all-you-can-eat buffet taking everything and everyone else goes hungry.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-resource-limits
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: >
        object.spec.containers.all(c,
          has(c.resources) &&
          has(c.resources.limits) &&
          has(c.resources.limits.cpu) &&
          has(c.resources.limits.memory)
        )
      message: 'All containers must define both CPU and memory limits.'
```

The `all()` function is CEL's way of saying "this must be true for every item in this
list." Here it checks every container in the Pod and not just the first one.

**Try it:**

Apply the policy, then try this Pod:

```yaml
# bad-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: greedy-pod
  labels:
    team: platform
spec:
  containers:
    - name: nginx
      image: nginx
      # no resource limits defined
```

```bash
kubectl apply -f bad-pod.yaml
```

It gets **blocked**. Now add limits:

```yaml
# good-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: good-pod
  labels:
    team: platform
spec:
  containers:
    - name: nginx
      image: nginx
      resources:
        limits:
          cpu: '500m'
          memory: '128Mi'
```

```bash
kubectl apply -f good-pod.yaml
```

This one is **allowed**.

## Use case 3: Block images from untrusted registries

A cluster that pulls images from anywhere is a security risk. Someone accidentally uses
`image: somerandomperson/nginx-modified:latest` and what's actually in that image? Nobody
knows.
This policy enforces that all images must come from a **trusted registry.**

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-image-registry
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: >
        object.spec.containers.all(c,
          c.image.startsWith('ghcr.io/myorg/')
        )
      message: 'Images must be pulled from ghcr.io/myorg/ only.'
```

Replace `ghcr.io/myorg/` with the trusted registry for the specific cluster.

## Use case 4: Minimum replicas for production Deployments

A Deployment running one replica is a single point of failure. If that pod crashes,
the service goes down. This policy ensures production Deployments always run at least
two replicas for basic high availability.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-min-replicas-prod
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: ['apps']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['deployments']
  validations:
    - expression: >
        !has(object.metadata.labels) ||
        !('env' in object.metadata.labels) ||
        object.metadata.labels['env'] != 'production' ||
        object.spec.replicas >= 2
      message: 'Production Deployments must have at least 2 replicas.'
```

**Read this as:** if the Deployment doesn't have an `env: production` label, skip this
check entirely. If it does, replicas must be at least 2. Only production gets enforced.
Dev and staging can do whatever they need.

## Rolling out a new policy safely

Here's the right way to introduce a policy to a cluster that already has workloads
running on it.

#### 1. Start with Audit

```yaml
validationActions:
  - Audit
```

Apply the policy. Let it run for a few days. Then check what it caught:

```bash
kubectl get policyreport -A -o wide
```

This shows every resource in the cluster that would have been blocked under `Deny`.
Fix those first.

#### 2. Switch to Deny

Once existing resources are compliant, update the policy:

```yaml
validationActions:
  - Deny
```

```bash
kubectl apply -f your-policy.yaml
```

No surprises. No incidents. That's how policies get rolled out safely on real clusters.

## Background scanning — catching what's already there

By default, ValidatingPolicy only checks resources as they come in. But what about
resources created before the policy existed?
That's what background scanning is for:

```yaml
spec:
  evaluation:
    admission:
      enabled: true # check new resources at admission
    background:
      enabled: true # also scan existing resources periodically
```

With background scanning **enabled**, Kyverno runs the policy against everything already
in the cluster and records violations in **PolicyReports**, even resources that were never
touched by an **admission request**. This is how teams find what's already non-compliant
before they start enforcing rules.

## Scoping to one namespace

By default, `ValidatingPolicy` applies cluster-wide. For stricter rules that should only
apply to one namespace like production, you can use `NamespacedValidatingPolicy`:

```yaml
apiVersion: policies.kyverno.io/v1
kind: NamespacedValidatingPolicy
metadata:
  name: require-ha-replicas
  namespace: production
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: ['apps']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['deployments']
  validations:
    - expression: 'object.spec.replicas >= 2'
      message: 'Production deployments must have at least 2 replicas.'
```

Same structure, just different kind. Namespace owners can manage this themselves without
needing cluster-admin permissions. This is useful for multi-tenant clusters where different
teams own different namespaces.

## Dynamic error messages

The `message` field gives everyone the same static error. For more complex rules,
`messageExpression` builds a message dynamically from the resource itself:

```yaml
validations:
  - expression: "'environment' in object.metadata.labels"
    messageExpression: >
      "Deployment " + object.metadata.name +
      " is missing the required 'environment' label"
    message: "Required label 'environment' is missing"
```

Instead of a generic "validation failed," the developer sees:

```text
Deployment my-api is missing the required 'environment' label
```

They know exactly which resource failed and exactly why. That's the difference between
a policy that helps people and one that just frustrates them.

If `messageExpression` errors for any reason, Kyverno falls back to the static `message`
automatically. So, it's better to always keep both.

## PolicyExceptions: because rules sometimes need exceptions

A strict policy is in place. But one specific team has a legitimate reason to bypass it.
Modifying the policy itself would weaken it for everyone. That's when `PolicyException`
comes into the picture:

```yaml
apiVersion: kyverno.io/v2
kind: PolicyException
metadata:
  name: allow-legacy-app
  namespace: legacy-namespace
spec:
  exceptions:
    - policyName: require-resource-limits
      ruleNames:
        - require-resource-limits
  match:
    any:
      - resources:
          kinds:
            - Pod
          namespaces:
            - legacy-namespace
```

Here the policy stays intact. The exception is a separate resource. Which is auditable, reviewable, and revocable. The legacy app gets its exception. But everyone else still follows the rule.

## Three CEL patterns that are used constantly

### Safely checking if a field exists:

```yaml
# Safe navigation. It won't error if labels don't exist
object.metadata.?labels['team'].orValue('') != ''

#Explicit check: same result, more verbose
has(object.metadata.labels) && 'team' in object.metadata.labels
```

### Checking all containers in a Pod:

```yaml
# Must be true for every container
object.spec.containers.all(c, has(c.resources.limits))
```

### Checking if any container matches:

```yaml
# At least one container must match
object.spec.containers.exists(c, c.image.startsWith('ghcr.io/'))
```

These three patterns cover the majority of **ValidatingPolicy expressions** encountered
in real clusters.

## Debugging when something isn't working

When you have applied the policy but nothing seems to be enforcing? Here's how to figure out why:

```bash
# Confirm the policy was applied
kubectl get validatingpolicy

# Check for violations in policy reports
kubectl get policyreport -A -o wide

# Check Kyverno admission controller logs
kubectl logs -n kyverno -l app.kubernetes.io/component=admission-controller
```

**Here are most common reasons why a policy doesn't seem to work:**

- The policy was applied to the wrong namespace
- The `operations` field only has `CREATE` but the violation is on an `UPDATE`
- The resource kind doesn't match what's in `matchConstraints`

## The autogen feature: write once, cover everything

When a ValidatingPolicy targets Pods, Kyverno can automatically generate equivalent
rules for Deployments, Jobs, CronJobs, and StatefulSets as well. Because all of those eventually create Pods.

```yaml
spec:
  autogen:
    podControllers:
      controllers:
        - deployments
        - jobs
        - cronjobs
        - statefulsets
```

You just have to apply one rule. Kyverno handles the rest.

## Want to experiment without a cluster?

Try any of the policies in this guide directly in the browser:
https://playground.kyverno.io/

Want to try out `ValidatingPolicy`along with the other new Kyverno policy types? Jump in to the playground. Paste the policy on the left side, paste any of the test pods on the right, and see exactly
what Kyverno can do!
