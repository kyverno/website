---
title: 'Require Requests and Limits'
category: validate
severity: medium
type: ValidatingPolicy
subjects: []
tags:
  - Best Practices
description: 'This policy validates that all containers have CPU and memory resource requests and memory limits defined.'
createdAt: "2026-02-12T12:56:39.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices-vpol/require-pod-requests-limits/require-pod-requests-limits.yaml" target="-blank">/best-practices-vpol/require-pod-requests-limits/require-pod-requests-limits.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  annotations:
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: This policy validates that all containers have CPU and memory resource requests and memory limits defined.
    policies.kyverno.io/severity: medium
    policies.kyverno.io/title: Require Requests and Limits
  name: require-requests-limits
spec:
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  validationActions:
    - Audit
  validations:
    - expression: variables.allContainers.all(c, has(c.resources) && has(c.resources.requests) && has(c.resources.requests.memory) && c.resources.requests.memory != '' && has(c.resources.requests.cpu) && c.resources.requests.cpu != '' && has(c.resources.limits) && has(c.resources.limits.memory) && c.resources.limits.memory != '')
      message: CPU and memory resource requests and memory limits are required for containers.
  variables:
    - expression: object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])
      name: allContainers

```
