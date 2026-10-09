---
excerpt: Pod Security Standards implemented as Kyverno policies.
title: Pod Security Standards
type: policies
url: /policies/pod-security/
---

Kubernetes Pod Security Standards provide guidelines and best practices to ensure that pods are deployed securely and follow the principle of least privilege. These standards are categorized into different levels—**Privileged**, **Baseline**, and **Restricted**—to help administrators choose the appropriate level of security for their workloads. You can learn more about these standards in the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

Kyverno supports policies for all controls defined in the Kubernetes Pod Security Standards.

## Installation

To apply all Pod Security Standard policies (recommended) [install Kyverno](/docs/installation/installation) and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/), then run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

:::note[Note]
The upstream `kustomize` should be used to apply customizations in these policies, available [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/). In many cases the version of `kustomize` built-in to `kubectl` will not work.
:::

To install the Kyverno Pod Security Standards (PSS) policies with [Helm](https://helm.sh/) instead, use the `kyverno/kyverno-policies` chart.

First, add the Kyverno Helm repository:

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

Then install the PSS policies chart:

```sh
helm install kyverno-pss kyverno/kyverno-policies \
  --namespace kyverno-policies --create-namespace
```

This command installs the policies for the **Baseline** profile, which is the chart default. To install the **Restricted** profile instead, add `--set podSecurityStandard=restricted`.  
_You can adjust the namespace as needed for your environment._

For more options and advanced configuration, refer to the [Kyverno Policies Helm chart documentation](https://github.com/kyverno/kyverno/tree/main/charts/kyverno-policies).

## User namespaces

A Pod that sets `spec.hostUsers` to `false` runs in its own [user namespace](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/), where root inside the container maps to an unprivileged user on the host. Kubernetes Pod Security Admission [relaxes some Pod Security Standards checks](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/#integration-with-pod-security-admission-checks) for these Pods when the Pod Security Standards policy version is v1.35 or later. This is the policy version that the `pod-security.kubernetes.io/<MODE>-version` Namespace label selects, not the Kubernetes server version. When you set `podSecurityUserNamespaces` to `true`, the `kyverno-policies` chart relaxes the matching Kyverno policies regardless of policy version. The setting is disabled by default.

### Requirements

- **Kubernetes support:** Linux nodes must support user namespaces. User namespaces are stable as of Kubernetes v1.36. For kernel, filesystem, and container runtime requirements, see [User Namespaces](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/#before-you-begin) in the Kubernetes documentation.

- **Helm chart version:** Use a `kyverno-policies` chart version that supports `podSecurityUserNamespaces`. Published chart versions up to and including `3.9.1` do not expose this setting. To check whether the setting is available, run:

  ```sh
  helm repo update kyverno
  helm show values kyverno/kyverno-policies | grep podSecurityUserNamespaces
  ```

  Policies installed using Kustomize do not include this chart setting.

- **Policy type:** Set `policyType` to `ValidatingPolicy`, the chart default, which installs the policies as CEL-based `ValidatingPolicy` resources. The `podSecurityUserNamespaces` setting has no effect when `policyType` is `ClusterPolicy`, which installs the deprecated `ClusterPolicy` resources instead. For details, see [Migrating to CEL Policies](/docs/guides/migration-to-cel).

### Enable user namespace support

To enable the setting for a new installation, run:

```sh
helm install kyverno-pss kyverno/kyverno-policies \
  --namespace kyverno-policies --create-namespace \
  --set podSecurityUserNamespaces=true
```

To enable it for an existing release, run:

```sh
helm upgrade kyverno-pss kyverno/kyverno-policies \
  --namespace kyverno-policies \
  --reset-then-reuse-values \
  --set policyType=ValidatingPolicy \
  --set podSecurityUserNamespaces=true
```

The `--reset-then-reuse-values` flag requires Helm v3.14 or later. It keeps the values from your existing release and picks up values that are new in the chart version, which `--reuse-values` doesn't do.

### Relaxed policies

When `podSecurityUserNamespaces` is set to `true`, the following policies relax specific checks for Pods that set `spec.hostUsers: false`.

| Policy                         | Profile    | Relaxed check                                |
| ------------------------------ | ---------- | -------------------------------------------- |
| `disallow-proc-mount`          | Baseline   | `securityContext.procMount` in containers    |
| `require-run-as-nonroot`       | Restricted | `runAsNonRoot` at the Pod or container level |
| `require-run-as-non-root-user` | Restricted | `runAsUser` at the Pod or container level    |

Pods that omit `spec.hostUsers` or set it to `true` remain subject to these checks. All other applicable policy checks continue to apply.

:::note[Note]
The **Restricted** profile requires the default `/proc` mount type, even for Pods using user namespaces. When `podSecurityUserNamespaces` is set to `true`, the chart enforces this requirement through the `disallow-proc-mount-strict` policy, which is never relaxed.

The chart installs this policy when `podSecurityStandard` is set to `restricted`, when enabled through `includeRestrictedPolicies`, or when explicitly listed in `podSecurityPolicies` with the `custom` profile. If `disallow-proc-mount-strict` is installed, the `disallow-proc-mount` policy is not relaxed either.
:::

### Verify the behavior

Run this test against a test cluster with Kyverno and the `kyverno-policies` Helm chart installed.

The API server must accept the `hostUsers` field, which requires the `UserNamespacesSupport` feature gate. This gate is enabled by default as of Kubernetes v1.33 and cannot be disabled as of v1.36.

The test uses server-side dry-run requests, so the Pod is not created or scheduled. Worker nodes do not need to support user namespaces for this admission test.

To enable user namespace support and enforce the Restricted profile, upgrade the existing `kyverno-pss` release:

```sh
helm upgrade kyverno-pss kyverno/kyverno-policies \
  --namespace kyverno-policies \
  --reset-then-reuse-values \
  --set policyType=ValidatingPolicy \
  --set podSecurityStandard=restricted \
  --set validationFailureAction=Enforce \
  --set podSecurityUserNamespaces=true
```

Save the following manifest as `userns-pod.yaml`. It runs as root (`runAsUser: 0`) inside a user namespace while satisfying the other applicable Restricted-profile requirements.

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
    - name: busybox
      image: busybox:1.36
      command: ['sleep', '3600']
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
```

Submit the Pod for server-side validation without creating or scheduling it:

```sh
kubectl apply -f userns-pod.yaml --namespace default --dry-run=server
```

**Expected result:** Kyverno allows the Pod, and `kubectl` prints the following:

```sh
pod/userns-root created (server dry run)
```

Remove `hostUsers: false` from the manifest and run the same command again.

**Expected result:** Kyverno denies the Pod because it violates the `require-run-as-nonroot` and `require-run-as-non-root-user` policies.

If the results differ, check whether either policy uses `Audit` through `validationFailureActionByPolicy`, or whether the test Namespace is excluded through `vpolExclude` or `vpolExcludeByPolicy`. By default, Kyverno also excludes the `kube-system` Namespace and its own Namespace from these policies.

## PSP migration

Kyverno has a number of policies which replicate the same PodSecurityPolicy (PSP) functionality designed to assist in migrating from PSP to Kyverno. See the PSP Migration policy category for these policies.

For a blog post covering a comparison of PodSecurityPolicy to Pod Security Admission and how to migrate from PSP to Kyverno, see [here](/blog/general/psp-migration/index.md).
