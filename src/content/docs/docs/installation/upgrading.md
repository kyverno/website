---
title: Upgrading Kyverno
description: Upgrading Kyverno.
sidebar:
  order: 55
---

## Upgrading Kyverno

Kyverno supports the same upgrade methods as those supported for installation. The below sections will cover both Helm and YAML manifest. Because new versions of Kyverno often have a number of supporting resources which change, including CRDs, an upgrade cannot be done by bumping the tag of any image.

Kyverno 1.10 brought breaking changes making upgrades to it or versions after 1.10 limited in nature. Always read the complete [release notes](https://github.com/kyverno/kyverno/releases) for any version prior to upgrading. If skipping a minor version, be sure to read the release notes for each minor version in between.

### Upgrade Kyverno with YAML

Direct upgrades from previous versions are not supported when using the YAML manifest approach. Please use the corresponding release manifest from the tagged release used to install to perform the uninstallation. Once Kyverno is removed, follow the [installation instructions](/docs/installation/methods#install-kyverno-using-yamls) to install Kyverno.

### Upgrade Kyverno with Helm

An upgrade from versions prior to Kyverno 1.10 to versions at 1.10 or higher using Helm requires manual intervention and cannot be performed via a direct upgrade process. Please see the Helm chart v2 to v3 migration guide [here](https://github.com/kyverno/kyverno/blob/release-1.13/charts/kyverno/README.md#migrating-from-v2-to-v3) for more complete information.

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
