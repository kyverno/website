---
title: Overview
excerpt: Kyverno policy types and supporting resources.
sidebar:
  order: 1
---

Kyverno uses [Common Expression Language (CEL)](https://kubernetes.io/docs/reference/using-api/cel/) to validate, mutate, generate, and delete resources, and to verify container images. Policies can be applied in Kubernetes clusters and, where supported, to JSON payloads outside Kubernetes.

## Policy Types

All policy types below use `policies.kyverno.io/v1`.

| Policy Type                                                         | Description                                          |
| ------------------------------------------------------------------- | ---------------------------------------------------- |
| [ValidatingPolicy](/docs/policy-types/validating-policy)            | Validate Kubernetes resources or JSON payloads       |
| [MutatingPolicy](/docs/policy-types/mutating-policy)                | Mutate new or existing resources                     |
| [GeneratingPolicy](/docs/policy-types/generating-policy)            | Create or clone resources based on flexible triggers |
| [DeletingPolicy](/docs/policy-types/deleting-policy)                | Delete matching resources based on a schedule        |
| [ImageValidatingPolicy](/docs/policy-types/image-validating-policy) | Verify container image signatures and attestations   |

Each policy type also has a namespaced variant: `NamespacedValidatingPolicy`, `NamespacedMutatingPolicy`, `NamespacedGeneratingPolicy`, `NamespacedDeletingPolicy`, and `NamespacedImageValidatingPolicy`. These apply only to resources in the namespace in which the policy is created.

For existing installations using earlier policy APIs, see [Migrating to CEL Policies](/docs/guides/migration-to-cel). Use the version selector to access reference documentation for older Kyverno releases.

## Supporting Resource Types

| Resource Type                                                   | Description                                                      | API Version               |
| --------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------- |
| [PolicyException](/docs/guides/exceptions)                      | Exempt resources from policies using CEL match conditions        | `policies.kyverno.io/v1`  |
| [GlobalContextEntry](/docs/policy-types/global-context-caching) | Cache Kubernetes resources or external API data for policies     | `kyverno.io/v2`           |
| UpdateRequest                                                   | Internal type used for background generate and mutate processing | `kyverno.io/v2`           |
| [PolicyReport / ClusterPolicyReport](/docs/guides/reports)      | Policy results reporting                                         | `wgpolicyk8s.io/v1alpha2` |
| EphemeralReport / ClusterEphemeralReport                        | Internal intermediary report types                               | `reports.kyverno.io/v1`   |

## API Versions

Use `policies.kyverno.io/v1` in policy and exception manifests, and `kyverno.io/v2` for GlobalContextEntry. Consult the [upgrade guide](/docs/installation/upgrading) before changing Kyverno versions. The [`kyverno migrate`](/docs/kyverno-cli/reference/kyverno_migrate) command rewrites stored objects to their current storage version; it does not translate policy logic between policy types.
