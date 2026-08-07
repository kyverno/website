---
date: 2026-07-28
title: Announcing Kyverno 1.19!
tags:
  - Releases
excerpt: Full feature parity for CEL-based policies and the official deprecation of ClusterPolicy in Kyverno 1.19
draft: true
featured: true
---

# Announcing Kyverno Release 1.19!

We're excited to announce the release of **Kyverno 1.19**, a milestone release that achieves **full feature parity between the CEL-based policy types and the legacy policy types**.

With this release, everything you can do with a `ClusterPolicy` — validation, mutation, generation, image verification, and cleanup — can now be done with the dedicated CEL-based policy types in the `policies.kyverno.io` API group. This completes the transition that began in Kyverno 1.14 and marks the start of the final chapter for the legacy types.

## **TL;DR**

Kyverno 1.19 delivers:

- **Full feature parity** for CEL-based policy types: `ValidatingPolicy`, `MutatingPolicy`, `GeneratingPolicy`, `ImageValidatingPolicy`, and `DeletingPolicy`

- **Official deprecation of `ClusterPolicy` and `Policy`**, with removal planned for **v1.20**

- Deprecation of `CleanupPolicy`/`ClusterCleanupPolicy` and the legacy `kyverno.io` PolicyException, also removed in v1.20

- CRDs now managed through a dedicated **kyverno-api Helm chart** dependency

If you are still using `ClusterPolicy`, **now is the time to migrate**. v1.19 is the final release with full support for the legacy policy types.

## **CEL Policy Feature Parity**

The CEL-based policy types are discrete, focused resources that align with Kubernetes native policy constructs like `ValidatingAdmissionPolicy` and `MutatingAdmissionPolicy`:

| Legacy rule type       | CEL-based replacement                                               |
| ---------------------- | ------------------------------------------------------------------- |
| `validate` rules       | [ValidatingPolicy](/docs/policy-types/validating-policy)            |
| `mutate` rules         | [MutatingPolicy](/docs/policy-types/mutating-policy)                |
| `generate` rules       | [GeneratingPolicy](/docs/policy-types/generating-policy)            |
| `verifyImages` rules   | [ImageValidatingPolicy](/docs/policy-types/image-validating-policy) |
| `CleanupPolicy`        | [DeletingPolicy](/docs/policy-types/deleting-policy)                |
| `PolicyException` (v2) | [PolicyException](/docs/guides/exceptions) (`policies.kyverno.io`)  |

Each type also has a namespaced variant (e.g. `NamespacedValidatingPolicy`) for namespace-scoped policy management.

## **Deprecations and Removal Schedule**

With feature parity achieved, the legacy policy types are now officially deprecated:

| Release | Date (estimated) | Status                                                      |
| ------- | ---------------- | ----------------------------------------------------------- |
| v1.19   | Jul 2026         | **Officially deprecated — final release with full support** |
| v1.20   | Oct 2026         | **Removed**                                                 |

This applies to `ClusterPolicy`, `Policy`, `CleanupPolicy`, `ClusterCleanupPolicy`, and the legacy `kyverno.io` PolicyException.

**What is not going away:** supporting resource types such as `GlobalContextEntry` and `UpdateRequest` are retained and continue to work with CEL-based policies — only their superseded API versions (`kyverno.io/v2alpha1` and `kyverno.io/v1beta1` respectively) are deprecated. Policy reports are unaffected.

See the full [API type status overview](/docs/policy-types/overview) for details.

## **Migrating**

The [migration guide](/docs/guides/migration-to-cel) provides field-by-field mappings from `ClusterPolicy` rules to each CEL-based policy type, along with examples and troubleshooting tips. Existing Kyverno CLI tests can be reused unchanged to validate migrated policies, and the [Kyverno Playground](https://playground.kyverno.io/) supports all the new policy types.

In v1.19, the storage version of the `policies.kyverno.io` types remains `v1beta1`; it will move to `v1` in v1.20. The [`kyverno migrate`](/docs/kyverno-cli/reference/kyverno_migrate) CLI command can be used to rewrite stored objects to the current storage version after an upgrade.

## **Helm Chart Changes**

Starting with 1.19, Kyverno CRDs are managed through a dedicated `kyverno-api` chart dependency, controlled by the existing `crds.install` value. See the [upgrade notes](/docs/installation/upgrading#upgrading-to-kyverno-v119) before upgrading.

## **Thank You**

As always, this release was made possible by the Kyverno community. Thank you to everyone who contributed code, documentation, issues, and feedback. Join us on the [Kyverno Slack channel](https://slack.k8s.io/#kyverno) and at community meetings to help shape what comes next.
