---
type: "docs"
title: "Default"
linkTitle: "Default"
weight: 10
description: >
    Minimally restrictive policy to prevent known privilege escalations.
---

To apply the <a href="https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline-default" target="_blank">Baseline/Default</a> policies [install Kyverno](/docs/installation/) and run the following [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) command:

```sh
kustomize build https://github.com/kyverno/policies/pod-security/default/ | kubectl apply -f -
```

This command installs policies with `validateFailureAction: enforce` and hence will block resources that violate policies. Alternatively, you can clone the [Git repo](https://github.com/kyverno/policies/tree/main/pod-security/default) to install the policies.