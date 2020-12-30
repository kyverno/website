---
type: "docs"
title: "Restricted"
linkTitle: "Restricted"
weight: 20
type: docs
description: >
    Heavily restricted policies following current Pod hardening best practices. 
---

To apply the <a href="https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted" target="_blank">Restricted</a> policies [install Kyverno](/docs/installation/) and run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security/restricted/ | kubectl apply -f -
```
