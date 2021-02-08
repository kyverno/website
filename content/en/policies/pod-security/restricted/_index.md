---
type: "docs"
title: "Restricted"
linkTitle: "Restricted"
weight: 20
type: docs
description: >
    Heavily restricted policies following current Pod hardening best practices. 
---

To apply the [Default](https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline-default) and <a href="https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted" target="_blank">Restricted</a> policies [install Kyverno](/docs/installation/) and run the following [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) command:

```sh
kustomize build https://github.com/kyverno/policies/pod-security/restricted/ | kubectl apply -f -
```

This command installs all policies with `validateFailureAction: enforce` and hence will block resources that violate policies. Alternatively, you can clone the [Git repo](https://github.com/kyverno/policies/tree/main/pod-security/restricted) to install the policies.