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

## Upgrading to Kyverno v1.20

### Legacy policy resources block install and upgrade

Kyverno v1.19 deprecated the legacy `kyverno.io` policy types (see [Deprecations](#deprecations) below). In v1.20, the Helm chart **blocks `helm install` and `helm upgrade` by default** while any legacy policy resources still exist on the cluster, so that you migrate them before completing the upgrade. The affected types are `ClusterPolicy`, `Policy`, `CleanupPolicy`, `ClusterCleanupPolicy`, and the legacy `PolicyException`, in every served `kyverno.io` version. The check covers each kind's older versions too, not only its current one, so objects stored under `v2beta1` or `v2alpha1` are found as well.

The gate has two layers:

- A **render-time check** that runs during `helm install` and `helm upgrade` against a live cluster and fails with the offending resource counts and names.
- A **`pre-install`/`pre-upgrade` hook Job** for GitOps tools that apply Helm hooks server-side, such as Argo CD and Flux.

To complete the upgrade, first migrate your legacy policies to the CEL-based [policy types](/docs/policy-types/overview) using the [migration guide](/docs/guides/migration-to-cel), then confirm none remain:

```bash
kubectl get clusterpolicies,policies,cleanuppolicies,clustercleanuppolicies -A
kubectl get policyexceptions.kyverno.io -A
```

If you must upgrade before completing the migration, set the acknowledgement value to disable the gate:

```bash
helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set upgrade.acknowledgeLegacyPoliciesNotEnforced=true
```

`upgrade.acknowledgeLegacyPoliciesNotEnforced=true` disables both layers. It does not restore enforcement: Kyverno v1.20 does not execute legacy policies under any setting, so this only records that you accept the legacy policies on this cluster are no longer enforced. To disable only the hook Job while keeping the render-time check, set `upgrade.legacyPolicyCheck.enabled=false`.

:::caution[Renamed in v1.20]
This value was called `upgrade.allowLegacyPolicies` before v1.20. It was renamed because setting it to `true` no longer allows legacy policies to run. A values file that still carries `upgrade.allowLegacyPolicies: true` **fails the render** with an error pointing at the new name, rather than being silently ignored. A stale `upgrade.allowLegacyPolicies: false` is not consent either way, so it is ignored as if the key were absent.
:::

#### Bypasses

Some paths bypass both layers, while hook-disabling options bypass only the hook Job:

- Client-side rendering never populates the cluster `lookup`, so the render-time check passes: `helm template` and `helm install --dry-run` both default to `--dry-run=client`, and chart linting (`ct lint`) never connects. Their server-side forms, `helm template --dry-run=server` and `helm install --dry-run=server`, do connect to the cluster and are covered.
- `helm install --no-hooks` / `helm upgrade --no-hooks`, Argo CD's `Skip Hooks` sync option, and Flux's `spec.install.disableHooks` / `spec.upgrade.disableHooks` skip only the hook Job; native Helm still runs the render-time check.
- Installing from Kyverno's static YAML manifests skips both layers.
- Setting `global.templating.enabled=true` omits the hook Job from the render, so it skips the hook Job only. This is how Kyverno's own published manifests are generated. The render-time check still applies.

If your install method bypasses the gate, run the preflight commands above before you install or upgrade.

## Upgrading to Kyverno v1.19

### Policy APIs

Use the supported [CEL-based policy types](/docs/policy-types/overview) and [PolicyException](/docs/guides/exceptions) in `policies.kyverno.io/v1`. Complete [policy migration](/docs/guides/migration-to-cel) before upgrading to a release that no longer serves your existing policy APIs. Use the version selector for version-specific migration instructions.

Supporting resources such as GlobalContextEntry, UpdateRequest, PolicyReport, and ClusterPolicyReport remain supported. Use `kyverno.io/v2` for GlobalContextEntry and UpdateRequest.

### Storage Versions

In v1.19, the storage version for the `policies.kyverno.io` policy types remains `v1beta1`. It will move to `v1` in v1.20. After upgrading, you can use the [`kyverno migrate`](/docs/kyverno-cli/reference/kyverno_migrate) CLI command to rewrite existing stored objects to the current storage version, for example:

```sh
kyverno migrate --resource validatingpolicies.policies.kyverno.io
```

### Helm Chart Changes

Starting with v1.19, the Kyverno CRDs are managed through a dedicated `kyverno-api` chart dependency, controlled by the existing `crds.install` value. If you install CRDs separately or set `crds.install: false`, review your CRD management workflow before upgrading.

### CLI Changes

The experimental `kyverno json scan` command has been removed from the Kyverno CLI in v1.19. To validate JSON payloads, use [ValidatingPolicy](/docs/policy-types/validating-policy) with the [`kyverno apply`](/docs/kyverno-cli/reference/kyverno_apply) command, or the [kyverno-json](https://kyverno.github.io/kyverno-json/) subproject directly.

For upgrades from older releases, select the corresponding documentation version and follow its release-specific upgrade instructions.
