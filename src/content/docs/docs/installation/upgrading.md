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
