---
type: "docs"
title: Disallow Helm Tiller
linkTitle: Disallow Helm Tiller
weight: 3
description: >
    Tiller has known security challenges. It requires administrative privileges and acts as a shared resource accessible to any authenticated user. Tiller can lead to privilge escalation as restricted users can impact other users.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/disallow_helm_tiller/disallow_helm_tiller.yaml" target="-blank">/best-practices/disallow_helm_tiller/disallow_helm_tiller.yaml</a>

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-helm-tiller
  annotations:
    policies.kyverno.io/category: Security
    policies.kyverno.io/description: Tiller has known security challenges. It requires administrative privileges and acts as a shared
      resource accessible to any authenticated user. Tiller can lead to privilge escalation as restricted users can impact other users.
spec:
  validationFailureAction: audit
  rules:
  - name: validate-helm-tiller
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Helm Tiller is not allowed"  
      pattern:
        spec:
          containers:
          - name: "*"
            image: "!*tiller*"

```
