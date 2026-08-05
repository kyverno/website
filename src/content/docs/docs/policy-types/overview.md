---
title: Overview
excerpt: >-
  Kyverno Policy Types
sidebar:
  order: 1
---

Kyverno offers multiple policy types decribed below. Kyverno's mission is to be the best policy engine for Kubernetes, and allow applying Kubernetes style policies everywhere incuding outside of Kubernetes.

As Kubernetes has evolved, Kyverno has also evolved its APIs. Kyverno initially supported JMESPath as a fast and effecient JSON processing language. Since 2022, Kubernetes has added [extensive support for Common Expression Language (CEL)](https://kubernetes.io/docs/reference/using-api/cel/). Hence, Kyverno has also evolved to fully support CEL. This shift allows Kyverno to maintain native compatibility and reduces the cognitive load for platform teams as there is one less thing to learn!

The new CEL based Kyverno [ValidatingPolicy](/docs/policy-types/validating-policy) and [ImageValidatingPolicy](/docs/policy-types/image-validating-policy) types were introduced in v1.14 (April 2025), and [MutatingPolicy](/docs/policy-types/mutating-policy), [GeneratingPolicy](/docs/policy-types/generating-policy), and [DeletingPolicy](/docs/policy-types/deleting-policy) were added in v1.15 (July 2025).

## Policy Types

| Policy Type                                                         | Description                                                                | API Version              | Status                                   |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------ | ---------------------------------------- |
| [ValidatingPolicy](/docs/policy-types/validating-policy)            | Validate Kubernetes resources or JSON payloads                             | `policies.kyverno.io/v1` | Stable (v1.18)                           |
| [MutatingPolicy](/docs/policy-types/mutating-policy)                | Mutate new or existing resources                                           | `policies.kyverno.io/v1` | Stable (v1.18)                           |
| [GeneratingPolicy](/docs/policy-types/generating-policy)            | Create or clone resources based on flexible triggers                       | `policies.kyverno.io/v1` | Stable (v1.18)                           |
| [DeletingPolicy](/docs/policy-types/deleting-policy)                | Deletes matching resources based on a schedule                             | `policies.kyverno.io/v1` | Stable (v1.18)                           |
| [ImageValidatingPolicy](/docs/policy-types/image-validating-policy) | Verify container image signatures and attestations                         | `policies.kyverno.io/v1` | Stable (v1.18)                           |
| [ClusterPolicy](/docs/policy-types/cluster-policy/overview)         | Legacy policy type with validate, mutate, generate, and verifyImages rules | `kyverno.io/v1`          | **Deprecated (v1.19), removed in v1.20** |
| [CleanupPolicy](/docs/policy-types/cleanup-policy)                  | Legacy policy type that deletes matching resources based on a schedule     | `kyverno.io/v2`          | **Deprecated (v1.19), removed in v1.20** |

Each CEL-based policy type also has a namespaced variant (e.g. `NamespacedValidatingPolicy`, `NamespacedMutatingPolicy`, `NamespacedGeneratingPolicy`, `NamespacedImageValidatingPolicy`, and `NamespacedDeletingPolicy`) which applies only to resources in the namespace it is created in.

As of Kyverno v1.19, the CEL-based policy types provide full feature parity with the legacy `ClusterPolicy`, `Policy`, and `CleanupPolicy` types. See the [migration guide](/docs/guides/migration-to-cel) to convert existing policies.

## Supporting Resource Types

The following resource types are used together with policies. They are **not** being deprecated and continue to be supported with the CEL-based policy types:

| Resource Type                                                   | Description                                                         | API Version               | Status            |
| --------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------- | ----------------- |
| [PolicyException](/docs/guides/exceptions)                      | Exempt resources from one or more policies                          | `policies.kyverno.io/v1`  | Stable (v1.19)    |
| [GlobalContextEntry](/docs/policy-types/global-context-caching) | Cache Kubernetes resources or external API data for use in policies | `kyverno.io/v2`           | Stable            |
| UpdateRequest                                                   | Internal type used for background generate and mutate processing    | `kyverno.io/v2`           | Stable (internal) |
| [PolicyReport / ClusterPolicyReport](/docs/guides/reports)      | Policy results reporting                                            | `wgpolicyk8s.io/v1alpha2` | Stable            |
| EphemeralReport / ClusterEphemeralReport                        | Internal intermediary report type                                   | `reports.kyverno.io/v1`   | Stable (internal) |

:::note
The legacy `PolicyException` in the `kyverno.io` API group is deprecated together with `ClusterPolicy` and will be removed in v1.20. Use the `policies.kyverno.io` PolicyException instead.
:::

## Deprecated API Versions

Independent of resource deprecation, older API _versions_ of retained resources are deprecated and rotate out following normal Kubernetes API version deprecation. The resources themselves are not going away — only re-apply your manifests with the newer API version:

| Resource                               | Deprecated Version                | Use Instead     |
| -------------------------------------- | --------------------------------- | --------------- |
| All `policies.kyverno.io` policy types | `v1alpha1`                        | `v1`            |
| GlobalContextEntry                     | `kyverno.io/v2alpha1`             | `kyverno.io/v2` |
| UpdateRequest                          | `kyverno.io/v1beta1` (not served) | `kyverno.io/v2` |

:::note[Storage Version]
In v1.19, the storage version for the `policies.kyverno.io` types remains `v1beta1`. It will move to `v1` in v1.20. After upgrading, the [`kyverno migrate`](/docs/kyverno-cli/reference/kyverno_migrate) CLI command can be used to rewrite stored objects to the current storage version.
:::

## Deprecation Schedule for Legacy Types

The `ClusterPolicy`, `Policy`, and `CleanupPolicy` types, and the legacy `kyverno.io` PolicyException, follow the schedule below:

| Release | Date (estimated) | Status                                                      |
| ------- | ---------------- | ----------------------------------------------------------- |
| v1.17   | Jan 2026         | Marked for deprecation                                      |
| v1.18   | Apr 2026         | Critical fixes only                                         |
| v1.19   | Jul 2026         | **Officially deprecated — final release with full support** |
| v1.20   | Oct 2026         | **Removed**                                                 |
