---
title: "Disallow empty Ingress host in CEL expressions"
category: Best Practices in CEL
version: 1.11.0
subject: Ingress
policyType: "validate"
description: >
    An ingress resource needs to define an actual host name in order to be valid. This policy ensures that there is a hostname for each rule defined.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices-cel/disallow-empty-ingress-host/disallow-empty-ingress-host.yaml" target="-blank">/best-practices-cel/disallow-empty-ingress-host/disallow-empty-ingress-host.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-empty-ingress-host
  annotations:
    policies.kyverno.io/title: Disallow empty Ingress host in CEL expressions
    policies.kyverno.io/category: Best Practices in CEL 
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Ingress
    policies.kyverno.io/description: >-
      An ingress resource needs to define an actual host name
      in order to be valid. This policy ensures that there is a
      hostname for each rule defined.
spec:
  validationFailureAction: Audit
  background: false
  rules:
    - name: disallow-empty-ingress-host
      match:
        any:
        - resources:
            kinds:
              - Ingress
            operations:
            - CREATE
            - UPDATE
      validate:
        cel:
          expressions:
            - expression: >-
                object.spec.?rules.orValue([]).all(rule, has(rule.host) && has(rule.http))
              message: "The Ingress host name must be defined, not empty."
        

```
