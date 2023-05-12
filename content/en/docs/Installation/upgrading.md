---
title: Upgrading Kyverno
description: Upgrading Kyverno.
weight: 55
---

## Upgrading Kyverno

Kyverno supports the same upgrade methods as those supported for installation. The below sections will cover both Helm and YAML manifest. Because new versions of Kyverno often have a number of supporting resources which change, including CRDs, an upgrade cannot be done by bumping the tag of any image.

Kyverno 1.10 also brings breaking changes along with it making upgrades to 1.10 limited in nature. Always read the complete [release notes](https://github.com/kyverno/kyverno/releases) for any version prior to upgrading.

### Upgrade Kyverno with YAML

Direct upgrades from previous versions to Kyverno version 1.10 are not supported when using the YAML manifest approach. Please use the corresponding release manifest from the tagged release used to install to perform the uninstallation. Once Kyverno is removed, follow the [installation instructions](/docs/installation/methods/#install-kyverno-using-yamls) to install Kyverno 1.10.

### Upgrade Kyverno with Helm

An upgrade to Kyverno 1.10 using Helm requires manual intervention and cannot be performed via a direct upgrade process. Please see the migration guide [here](https://github.com/kyverno/kyverno/blob/release-1.10/charts/kyverno/README.md#migrating-from-v2-to-v3) for more complete information.
