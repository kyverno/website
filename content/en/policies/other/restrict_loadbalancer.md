---
type: "docs"
title: Disallow Service Type LoadBalancer
linkTitle: Disallow Service Type LoadBalancer
weight: 25
description: >
    Sample policy to restrict use of Service type LoadBalancer.
category: Sample
rules:
  - name: no-LoadBalancer
    match:
      resources:
        kinds:
        - Service
    validate:
      message: "Service of type LoadBalancer is not allowed."
      pattern:
        spec:
          type: "!LoadBalancer"
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict_loadbalancer.yaml" target="-blank">/other/restrict_loadbalancer.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: no-loadbalancer-service
  annotations:
    policies.kyverno.io/title: Disallow Service Type LoadBalancer
    policies.kyverno.io/category: Sample 
    policies.kyverno.io/description: >-
      Sample policy to restrict use of Service type LoadBalancer.
spec:
  validationFailureAction: audit
  rules:
  - name: no-LoadBalancer
    match:
      resources:
        kinds:
        - Service
    validate:
      message: "Service of type LoadBalancer is not allowed."
      pattern:
        spec:
          type: "!LoadBalancer"
```
