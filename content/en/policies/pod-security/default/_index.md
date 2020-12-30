---
type: "docs"
title: "Default"
linkTitle: "Default"
weight: 10
description: >
    Minimally restrictive policy to prevent known privilege escalations.
---

To apply the <a href="https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline-default" target="_blank">Baseline/Default</a> policies [install Kyverno](/docs/installation/) and run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security/default/ | kubectl apply -f -
```
