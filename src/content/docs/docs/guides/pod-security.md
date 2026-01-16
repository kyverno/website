---
description: Pod Security Standards implemented as Kyverno policies.
title: Pod Security Standards
type: policies
url: /policies/pod-security/
---

<br/>

These Kyverno policies are based on the [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) definitions. To apply all Pod Security Standard policies (recommended) [install Kyverno](/docs/installation/installation/ and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/), then run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

:::note[Note]
The upstream `kustomize` should be used to apply customizations in these policies, available [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/). In many cases the version of `kustomize` built-in to `kubectl` will not work.
:::

Installation is also available via [Helm](/docs/installation/installation/#high-availability-installation by using the chart `kyverno-policies`.

Pod Security Standard policies are organized in two groups, **Baseline** and **Restricted**. Use the filters on the left sidebar to select and view the policies currently covered in each group by selecting the appropriate Policy Category.

## PodSecurityPolicy Migration

Kyverno has a number of policies which replicate the same PodSecurityPolicy functionality designed to assist in migrating from PSP to Kyverno. See the PSP Migration policy category for these policies.

For a blog post covering a comparison of PodSecurityPolicy to Pod Security Admission and how to migrate from PSP to Kyverno, see [here](/blog/general/psp-migration/index.md/.
