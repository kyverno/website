---
title: 'Disallow empty Ingress host in VPOL'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Ingress
tags:
  - Best Practices in VPOL
version: 1.19.1
description: 'An ingress resource needs to define an actual host name in order to be valid. This policy ensures that there is a hostname for each rule defined.'
createdAt: "2026-02-23T00:26:12.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices-vpol/disallow-empty-ingress-host/disallow-empty-ingress-host.yaml" target="_blank" rel="noopener noreferrer">/best-practices-vpol/disallow-empty-ingress-host/disallow-empty-ingress-host.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-empty-ingress-host
  annotations:
    policies.kyverno.io/title: Disallow empty Ingress host in VPOL
    policies.kyverno.io/category: Best Practices in VPOL
    policies.kyverno.io/minversion: 1.19.1
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Ingress
    policies.kyverno.io/description: An ingress resource needs to define an actual host name in order to be valid. This policy ensures that there is a hostname for each rule defined.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: false
  matchConstraints:
    resourceRules:
      - apiGroups:
          - networking.k8s.io
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - ingresses
  variables:
    - name: rules
      expression: object.spec.?rules.orValue([])
  validations:
    - expression: variables.rules.all(rule, 'ingress-host' in exceptions.allowedValues || (has(rule.host) && rule.host != '' && has(rule.http)))
      message: The Ingress host name must be defined, not empty.

```
