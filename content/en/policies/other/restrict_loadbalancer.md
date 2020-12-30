---
type: "docs"
title: No Loadbalancers
linkTitle: No Loadbalancers
weight: 34
description: >
    
---

## Category


## Definition
[/other/restrict_loadbalancer.yaml](https://github.com/kyverno/policies/raw/main//other/restrict_loadbalancer.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: no-loadbalancers
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
