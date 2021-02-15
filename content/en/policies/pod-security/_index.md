---
type: "docs"
title: "Pod Security"
linkTitle: "Pod Security"
weight: 10
type: "policies"
description: >
    Policies to secure Kubernetes Pods.
---

Policies based on <a href="https://kubernetes.io/docs/concepts/security/pod-security-standards/" target="_blank">Kubernetes Pod Security Standards</a>. To apply all pod security policies (recommended) [install Kyverno](/docs/installation/) and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/), then run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

{{% alert title="Note" color="info" %}}
The upstream `kustomize` should be used to apply customizations in these policies, available [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/). In many cases the version of `kustomize` built-in to `kubectl` will not work.
{{% /alert %}}
