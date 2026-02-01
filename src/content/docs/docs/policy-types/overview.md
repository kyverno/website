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

| Policy Type                                                         | Description                                                                | API Version              | Status             |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------ | ------------------ |
| [ValidatingPolicy](/docs/policy-types/validating-policy)            | Validate Kubernetes resources or JSON payloads                             | `policies.kyverno.io/v1` | Stable (v1.17)     |
| [MutatingPolicy](/docs/policy-types/mutating-policy)                | Mutate new or existing resources                                           | `policies.kyverno.io/v1` | Stable (v1.17)     |
| [GeneratingPolicy](/docs/policy-types/generating-policy)            | Create or clone resources based on flexible triggers                       | `policies.kyverno.io/v1` | Stable (v1.17)     |
| [DeletingPolicy](/docs/policy-types/deleting-policy)                | Deletes matching resources based on a schedule                             | `policies.kyverno.io/v1` | Stable (v1.17)     |
| [ImageValidatingPolicy](/docs/policy-types/image-validating-policy) | Verify container image signatures and attestations                         | `policies.kyverno.io/v1` | Stable (v1.17)     |
| [ClusterPolicy](/docs/policy-types/cluster-policy/overview)         | Legacy policy type with validate, mutate, generate, and verifyImages rules | `kyverno.io/v1`          | Deprecated (v1.17) |
| [CleanupPolicy](/docs/policy-types/cleanup-policy)                  | Legacy policy type that deletes matching resources based on a schedule     | `kyverno.io/v2`          | Deprecated (v1.17) |

## Deprecation Schedule for Legacy Types

The `ClusterPolicy` and `CleanupPolicy` will be suported for multiple releases, as detailed below:

| Release | Date (estimated) | Status                 |
| ------- | ---------------- | ---------------------- |
| v1.17   | Jan 2026         | Marked for deprecation |
| v1.18   | Apr 2026         | Critical fixes only    |
| v1.19   | Jul 2026         | Critical fixes only    |
| v1.20   | Oct 2026         | Planned for removal    |
