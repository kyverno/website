---
type: "docs"
title: Restrict Automount Sa Token
linkTitle: Restrict Automount Sa Token
weight: 24
description: >
    Kubernetes automatically mounts service account credentials in each pod. The service account may be assigned roles allowing pods to access API resources. To restrict access, opt out of auto-mounting tokens by setting automountServiceAccountToken to false.
---

## Category
Security

## Definition
[/other/restrict_automount_sa_token.yaml](https://github.com/kyverno/policies/raw/main//other/restrict_automount_sa_token.yaml)

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-automount-sa-token
  annotations:
    policies.kyverno.io/category: Security
    policies.kyverno.io/description: Kubernetes automatically mounts service account 
      credentials in each pod. The service account may be assigned roles allowing pods 
      to access API resources. To restrict access, opt out of auto-mounting tokens by 
      setting automountServiceAccountToken to false.
spec:
  rules:
  - name: validate-automountServiceAccountToken
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Auto-mounting of Service Account tokens is not allowed"
      pattern:
        spec:
          automountServiceAccountToken: false
```
