---
date: 2026-10-13
title: 'Enhancing Kyverno Pod Security with User Namespace Support'
tags:
  - Security
excerpt: Introducing user namespace support in Kyverno's Pod Security policies, bringing validation in line with Kubernetes Pod Security Admission while keeping critical security checks intact.
draft: false
authors:
  - name: Suhani
---

Your team needs to run a legacy image that starts as root, but your cluster enforces the Restricted Pod Security Standard. You set `hostUsers: false` to run the Pod in a user namespace. Kubernetes Pod Security Admission (PSA) accepts the Pod, but Kyverno rejects it for running as root.

Why do two admission controllers that enforce the same standard disagree? Kubernetes updated PSA to account for how user namespaces change what container root means on the host, and the Kyverno policies hadn't caught up.

## What a user namespace changes

In a container without a user namespace, UID `0` inside the container is also UID `0` on the host. If an attacker escapes the container, their process runs as root on the node.

User namespaces add a layer of isolation by mapping the container's user IDs (UIDs) and group IDs (GIDs) to unprivileged IDs on the host. A process can run as root inside the container without root privileges on the node, which limits the damage of a container escape.

To give a Pod its own user namespace, set `hostUsers` to `false`:

```yaml
spec:
  hostUsers: false
```

I tested this on a kind cluster running Kubernetes v1.36. Inside the container, the process reported UID `0`:

```console
$ kubectl exec userns-root -- id
uid=0(root) gid=0(root) groups=0(root),10(wheel)

$ kubectl exec userns-root -- cat /proc/self/uid_map
         0 3468427264      65536
```

The mapping shows that container UID `0` is host UID `3468427264`. The kubelet picks a different range for each Pod, so your numbers will differ.

User namespaces became generally available in [Kubernetes v1.36](https://kubernetes.io/blog/2026/04/23/kubernetes-v1-36-userns-ga/).

## Why PSA relaxes three checks

Starting with Pod Security Standards policy version v1.35, PSA skips three checks for Pods that explicitly set `hostUsers: false`:

- **`runAsNonRoot` and `runAsUser` (Restricted).** These exist only because container root used to be host root.
- **`procMount` (Baseline only).** Inside a user namespace, root doesn't hold the host privileges that make an unmasked `/proc` most dangerous. The Restricted profile still requires the default `/proc` mount, for reasons covered later in this post.

The policy version comes from the `pod-security.kubernetes.io/<MODE>-version` Namespace label, which defaults to `latest`. Every other check, such as privileged containers or added capabilities, still applies.

## What the new chart setting does

The Kyverno `kyverno-policies` Helm chart didn't look at `hostUsers`, so its policies kept rejecting these Pods. The chart now has a `podSecurityUserNamespaces` setting. It defaults to `false` because it accepts Pods that were rejected before, and loosening a security policy should be a deliberate choice. Upgrading the chart alone changes nothing.

When you set it to `true`, three `ValidatingPolicy` resources skip their check for Pods that use a user namespace:

| Policy                         | Profile    | Relaxed field  |
| ------------------------------ | ---------- | -------------- |
| `require-run-as-nonroot`       | Restricted | `runAsNonRoot` |
| `require-run-as-non-root-user` | Restricted | `runAsUser`    |
| `disallow-proc-mount`          | Baseline   | `procMount`    |

Each policy gets one guard at the start of its CEL expression:

```cel
object.spec.?hostUsers.orValue(true) == false ||
```

`orValue(true)` treats a missing `hostUsers` field as `true`, the Kubernetes default, so only an explicit `hostUsers: false` is relaxed.

## Why Restricted still requires the default `/proc` mount

The container runtime normally masks sensitive paths in `/proc`. `procMount: Unmasked` removes them, and the API server allows that only when `hostUsers` is `false`. When I tested this, the API server rejected an unmasked Pod without `hostUsers: false` before Kyverno even saw it.

However, a user namespace changes who the process is, not which kernel it uses. Every container on a node shares one kernel, and an unmasked `/proc` exposes more of it. In PSA, the Restricted `procMount` check replaces the Baseline one and has no user namespace exception.

Because each control is a separate Kyverno policy, relaxing `disallow-proc-mount` alone would weaken Restricted. So when the setting is on and Restricted policies are installed, the chart adds `disallow-proc-mount-strict`, which never relaxes, and keeps `disallow-proc-mount` strict as well.

## Enable and test the setting

You need Kyverno and a `kyverno-policies` chart release that includes the setting. Chart versions up to and including `3.9.1` don't have it, and the change will ship in the next `release-1.19` patch release. Use a cluster at Kubernetes v1.35 or later, so that PSA makes the same decisions.

To check whether your Helm repository has the setting, run:

```sh
helm show values kyverno/kyverno-policies | grep podSecurityUserNamespaces
```

On a test cluster, install the Restricted policies in `Enforce` mode with the setting turned on. If you already use the chart, upgrade your existing release with `--reset-then-reuse-values --set policyType=ValidatingPolicy --set podSecurityUserNamespaces=true` instead. This keeps your current values, and setting `policyType` makes sure a release first installed with `ClusterPolicy` picks up the change. The `--reset-then-reuse-values` flag needs Helm 3.14 or later.

```sh
helm upgrade --install kyverno-pss kyverno/kyverno-policies \
  --namespace kyverno-policies --create-namespace \
  --set podSecurityStandard=restricted \
  --set validationFailureAction=Enforce \
  --set podSecurityUserNamespaces=true
```

Save this Pod, which runs as root in a user namespace and meets every other Restricted rule, as `userns-root.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: userns-root
spec:
  hostUsers: false
  securityContext:
    runAsUser: 0
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      image: busybox:1.36
      command: ['sleep', '3600']
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
```

Submit it with a server-side dry run. This runs admission without creating or scheduling the Pod, so your nodes don't need user namespace support for this test:

```sh
kubectl create namespace demo  # Skip if the Namespace already exists.
kubectl apply -f userns-root.yaml -n demo --dry-run=server
```

Kyverno accepts it:

```console
pod/userns-root created (server dry run)
```

Now delete the `hostUsers: false` line and run the command again. Kyverno rejects the Pod, because it would be root on the node:

```console
Error from server: admission webhook "vpol.validate.kyverno.svc-fail" denied the request:
Policy require-run-as-non-root-user failed: Running as root user (UID 0) is not allowed. ...
```

The other cases follow the same pattern. Here's how PSA (policy v1.35+) and Kyverno handle four test Pods, before and after you enable `podSecurityUserNamespaces`. Bold marks what changes.

| Test Pod (profile)                                | PSA     | Kyverno (default) | Kyverno (enabled) |
| ------------------------------------------------- | ------- | ----------------- | ----------------- |
| Root with user namespace (Restricted)             | Allowed | Denied            | **Allowed**       |
| Root without user namespace (Restricted)          | Denied  | Denied            | Denied            |
| Unmasked `/proc` with user namespace (Restricted) | Denied  | Denied            | Denied            |
| Unmasked `/proc` with user namespace (Baseline)   | Allowed | Denied            | **Allowed**       |

Once enabled, Kyverno matches PSA in every row.

For more options, see the [Kyverno Pod Security guide](https://kyverno.io/docs/guides/pod-security/).

## Check these limits before production

- **Kubernetes version:** The chart doesn't check your Pod Security Standards version. Turn the setting on only for clusters at Kubernetes v1.35 or later whose Namespaces don't pin an older `pod-security.kubernetes.io/<MODE>-version`, or Kyverno will allow Pods that PSA denies.
- **Policy type:** The setting applies only when `policyType` is `ValidatingPolicy`, the chart default. It has no effect on the deprecated `ClusterPolicy` templates, on policies installed with Kustomize, or on the `validate.podSecurity` rule, where support is tracked in [kyverno/kyverno#15981](https://github.com/kyverno/kyverno/issues/15981).
- **Node support:** Admission can accept a Pod that a node can't start. Nodes need Linux 6.3 or later, filesystems with ID-mapped mount support, and a runtime such as containerd 2.0 or later or CRI-O 1.25 or later. Pods that use a user namespace also have their own [limitations](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/#limitations), such as no host networking or NFS volumes.

## Try it with your root workloads

If an image has been stuck because it needs root inside the container, try it with `hostUsers: false` and `podSecurityUserNamespaces` turned on, and share what you find in [#kyverno](https://slack.k8s.io/) on Kubernetes Slack. For details, see [kyverno/kyverno#17693](https://github.com/kyverno/kyverno/pull/17693) and the Kubernetes guide to [using a user namespace with a Pod](https://kubernetes.io/docs/tasks/configure-pod-container/user-namespaces/).
