---
title: "Disallow Empty Ingress Host"
category: 
version: 
subject: 
policyType: "validate"
description: >
    
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/disallow-empty-ingress-host/disallow_empty_ingress_host.yaml" target="-blank">/best-practices/disallow-empty-ingress-host/disallow_empty_ingress_host.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-empty-ingress-host
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: disallow-empty-ingress-host
      match:
        resources:
          kinds:
            - Ingress
      validate:
        message: "The Ingress host name must be defined, not empty."
        deny:
          conditions:
            - key: "{{ request.object.spec.rules[].host | length(@) }}"
              operator: NotEquals
              value: "{{ request.object.spec.rules[].http | length(@) }}"
```
