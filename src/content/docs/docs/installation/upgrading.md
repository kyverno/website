---
title: Upgrading Kyverno
excerpt: Upgrading Kyverno.
sidebar:
  order: 55
---

## Upgrading Kyverno

Kyverno supports the same upgrade methods as those supported for installation. The below sections will cover both Helm and YAML manifest. Because new versions of Kyverno often have a number of supporting resources which change, including CRDs, an upgrade cannot be done by bumping the tag of any image.

Kyverno 1.10 brought breaking changes making upgrades to it or versions after 1.10 limited in nature. Always read the complete [release notes](https://github.com/kyverno/kyverno/releases) for any version prior to upgrading. If skipping a minor version, be sure to read the release notes for each minor version in between.

### Upgrade Kyverno with YAML

Direct upgrades from previous versions are not supported when using the YAML manifest approach. Please use the corresponding release manifest from the tagged release used to install to perform the uninstallation. Once Kyverno is removed, follow the [installation instructions](/docs/installation/installation#install-kyverno-using-yamls) to install Kyverno.

### Upgrade Kyverno with Helm

An upgrade from versions prior to Kyverno 1.10 to versions at 1.10 or higher using Helm requires manual intervention and cannot be performed via a direct upgrade process. Please see the Helm chart v2 to v3 migration guide [here](https://github.com/kyverno/kyverno/blob/release-1.13/charts/kyverno/README.md#migrating-from-v2-to-v3) for more complete information.

## Upgrading to Kyverno v1.19

### Deprecations

Kyverno v1.19 achieves full feature parity between the CEL-based policy types in the `policies.kyverno.io` API group and the legacy policy types. As a result:

1. **`ClusterPolicy` and `Policy` (`kyverno.io/v1`) are officially deprecated** and will be **removed in v1.20**. Migrate to the CEL-based [policy types](/docs/policy-types/overview) using the [migration guide](/docs/guides/migration-to-cel). v1.19 is the final release with full support for these types.
2. **`CleanupPolicy` and `ClusterCleanupPolicy` (`kyverno.io/v2`)** are deprecated and will be **removed in v1.20**. Use [DeletingPolicy](/docs/policy-types/deleting-policy) instead.
3. **The legacy PolicyException (`kyverno.io/v2`)** is deprecated and will be **removed in v1.20**. Use the [`policies.kyverno.io` PolicyException](/docs/guides/exceptions) instead.
4. **The `v1alpha1` versions of the `policies.kyverno.io` policy types are deprecated.** Update your manifests to use `policies.kyverno.io/v1`.
5. **The `kyverno.io/v2beta1` API versions of `ClusterPolicy`, `Policy`, `PolicyException`, `CleanupPolicy`, and `ClusterCleanupPolicy` now emit deprecation warnings when used.** These versions remain fully served in v1.19 (non-breaking), but should be migrated to `kyverno.io/v1` (`ClusterPolicy`/`Policy`) or `kyverno.io/v2` (the others) ahead of their future removal. See [Migrating from v2beta1](#migrating-from-v2beta1).

The following resource types are **not** deprecated and continue to be fully supported with CEL-based policies:

- **GlobalContextEntry**: only the older `kyverno.io/v2alpha1` API version is deprecated; use `kyverno.io/v2`.
- **UpdateRequest** (internal type): only the older `kyverno.io/v1beta1` API version is deprecated (no longer served).
- **PolicyReport / ClusterPolicyReport** (`wgpolicyk8s.io/v1alpha2`) and **EphemeralReport / ClusterEphemeralReport** (`reports.kyverno.io/v1`).

### Storage Versions

In v1.19, the storage version for the `policies.kyverno.io` policy types remains `v1beta1`. It will move to `v1` in v1.20. After upgrading, you can use the [`kyverno migrate`](/docs/kyverno-cli/reference/kyverno_migrate) CLI command to rewrite existing stored objects to the current storage version, for example:

```sh
kyverno migrate --resource policyexceptions.kyverno.io
```

### Helm Chart Changes

Starting with v1.19, the Kyverno CRDs are managed through a dedicated `kyverno-api` chart dependency, controlled by the existing `crds.install` value. If you install CRDs separately or set `crds.install: false`, review your CRD management workflow before upgrading.

### CLI Changes

The experimental `kyverno json scan` command has been removed from the Kyverno CLI in v1.19. To validate JSON payloads, use [ValidatingPolicy](/docs/policy-types/validating-policy) with the [`kyverno apply`](/docs/kyverno-cli/reference/kyverno_apply) command, or the [kyverno-json](https://kyverno.github.io/kyverno-json/) subproject directly.

### Deprecation Warnings

Starting in v1.19, Kyverno surfaces API and field deprecations proactively so clusters can inventory and migrate usage before removal:

- **Admission webhooks**: creating or updating a resource that uses a deprecated API version or field returns a Kubernetes `warnings` entry in the admission response.
- **Kyverno CLI**: `kubectl-kyverno apply` and `kubectl-kyverno test` print warnings such as `Warning: <file>: <message>` for deprecated versions and fields.
- **`--warnings-as-errors`**: the CLI exposes a root-level `--warnings-as-errors` flag (applies to `apply` and `test`). When set, any detected deprecation causes the command to exit non-zero, making it easy to gate CI pipelines on deprecations.
- **Metrics**: Kyverno increments the `kyverno_deprecated_api_requests_total{group,version,kind,field}` counter for each deprecated API request. The `field` label is the deprecated field path (empty for version-level deprecations). Use this metric to track adoption of deprecated versions across your clusters.

### Migrating from v2beta1

The `kyverno.io/v2beta1` schemas for `ClusterPolicy`, `Policy`, `PolicyException`, `CleanupPolicy`, and `ClusterCleanupPolicy` are identical to their `kyverno.io/v1` / `kyverno.io/v2` equivalents, so migration is a simple API version swap:

1. Find resources still using the deprecated versions:

   ```sh
   kubectl get clusterpolicies,policies,policyexceptions,cleanuppolicies,clustercleanuppolicies -A \
     -o custom-columns='KIND:.kind,NAME:.metadata.name,NS:.metadata.namespace,VER:.apiVersion'
   ```

2. Update each manifest's `apiVersion`:

   | Kind                                    | From                  | To                 |
   | --------------------------------------- | --------------------- | ------------------ |
   | `ClusterPolicy`, `Policy`               | `kyverno.io/v2beta1`  | `kyverno.io/v1`    |
   | `PolicyException`                       | `kyverno.io/v2beta1`  | `kyverno.io/v2`    |
   | `CleanupPolicy`, `ClusterCleanupPolicy` | `kyverno.io/v2beta1`  | `kyverno.io/v2`    |
   | `GlobalContextEntry`                    | `kyverno.io/v2alpha1` | `kyverno.io/v2`    |

3. Re-apply the updated manifests. No `spec` changes are required.

:::note
These deprecations are independent of the separate [CEL migration](/docs/guides/migration-to-cel) of the legacy policy types (`kyverno.io/v1` → `policies.kyverno.io/v1`). Migrating `v2beta1` → `v1` is only the first step; consider migrating to the CEL-based types for the long term.
:::

## Upgrading to Kyverno v1.13

### Breaking Changes

Kyverno version 1.13 contains the following breaking configuration changes:

1. **Removal of wildcard permissions**: prior versions contained wildcard view permissions, which allowed Kyverno controllers to view all resources including secrets and other sensitive information. In 1.13 the wildcard view permission was removed and a role binding to the default `view` role was added. See the documentation section on [Role Based Access Controls](/docs/installation/customization#role-based-access-controls) for more details. This change will not impact policies during admission controls but may impact reports, and may impact users with mutate and generate policies on custom resources as the controller may no longer be able to view these custom resources.

To upgrade to 1.13 and continue to allow wildcard view permissions for all Kyverno controllers, use a [Helm values file](https://github.com/kyverno/kyverno/blob/v1.13.0/charts/kyverno/values.yaml) that grants these permissions as specified below:

```yaml
admissionController:
  rbac:
    clusterRole:
      extraResources:
        - apiGroups:
            - '*'
          resources:
            - '*'
          verbs:
            - get
            - list
            - watch
backgroundController:
  rbac:
    clusterRole:
      extraResources:
        - apiGroups:
            - '*'
          resources:
            - '*'
          verbs:
            - get
            - list
            - watch
reportsController:
  rbac:
    clusterRole:
      extraResources:
        - apiGroups:
            - '*'
          resources:
            - '*'
          verbs:
            - get
            - list
            - watch
```

**NOTE**: using wildcard permissions is not recommended. Use explicit permissions instead.

2. **Default exception settings**: the Helm chart values of the prior versions enabled exceptions by default for all namespaces. This creates a potential security issue. See [CVE-2024-48921](https://github.com/kyverno/kyverno/security/advisories/GHSA-qjvc-p88j-j9rm) for more details. This change will impact users who were relying on policy exceptions to be enabled in all namespaces.

To maintain backwards compatibility, you can configure the Helm chart values to allow the same settings as the prior version. To upgrade to 1.13 and continue to allow configuring exceptions in all namespaces, set the Helm value `features.policyExceptions.namespace` to `*`:

```sh
helm upgrade kyverno kyverno/kyverno -n kyverno --set features.policyExceptions.enabled=true --set features.policyExceptions.namespace="*"
```

**NOTE**: limiting exceptions to a specific namespace is recommended.

### Dropped API versions

Kyverno 1.13 drops deprecated API versions for its managed CustomResourceDefinitions. The migration is handled automatically through Helm hook. To upgrade Kyverno without Helm, or Helm hook, you can migrate existing resources via [kube-storage-version-migrator](https://github.com/kubernetes-sigs/kube-storage-version-migrator).

See affected CRDs:

```
- cleanuppolicies.kyverno.io
- clustercleanuppolicies.kyverno.io
- clusterpolicies.kyverno.io
- globalcontextentries.kyverno.io
- policies.kyverno.io
- policyexceptions.kyverno.io
- updaterequests.kyverno.io
```
