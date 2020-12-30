---
type: "docs"
title: No Loadbalancers
linkTitle: No Loadbalancers
weight: 24
description: >
    
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict_loadbalancer.yaml" target="-blank">/other/restrict_loadbalancer.yaml</a>

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
