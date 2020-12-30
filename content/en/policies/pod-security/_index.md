---
type: "docs"
title: "Pod Security"
linkTitle: "Pod Security"
weight: 10
description: >
    Policies for securing Kubernetes Pods
---

Policies based on <a href="https://kubernetes.io/docs/concepts/security/pod-security-standards/" target="_blank">Kubernetes Pod Security Standards</a>. To apply all pod security policies (recommended) [install Kyverno](/docs/installation/) and run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```
