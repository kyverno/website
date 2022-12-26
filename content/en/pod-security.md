+++
description = "Pod Security Standards implemented as Kyverno policies."
title = "Pod Security"
type = "policies"
url = "/policies/pod-security/"
+++

<br/>

These Kyverno policies are based the on [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) definitions. To apply all Pod Security Standard policies (recommended) [install Kyverno](/docs/installation/) and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/), then run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

{{% alert title="Note" color="info" %}}
The upstream `kustomize` should be used to apply customizations in these policies, available [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/). In many cases the version of `kustomize` built-in to `kubectl` will not work.
{{% /alert %}}

Installation is also available via [Helm](/docs/installation/#install-kyverno-using-helm) by using the chart `kyverno-policies`. For more information, see the kyverno-policies repo [here](/policies/).

Pod Security Standard policies are organized in two groups, **Baseline** and **Restricted**. Use the filters on the left sidebar to select and view the policies currently covered in each group by selecting the appropriate Policy Category.
