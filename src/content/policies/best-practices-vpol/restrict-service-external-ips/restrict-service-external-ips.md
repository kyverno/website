---
title: 'Restrict External IPs'
category: validate
severity: medium
type: ValidatingPolicy
subjects: []
tags:
  - Best Practices
description: 'This policy restricts the use of externalIPs in Service resources. External IPs can pose security risks and should be carefully controlled.'
createdAt: "2026-02-12T12:56:39.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices-vpol/restrict-service-external-ips/restrict-service-external-ips.yaml" target="-blank">/best-practices-vpol/restrict-service-external-ips/restrict-service-external-ips.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  annotations:
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: This policy restricts the use of externalIPs in Service resources. External IPs can pose security risks and should be carefully controlled.
    policies.kyverno.io/severity: medium
    policies.kyverno.io/title: Restrict External IPs
  name: restrict-external-ips
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
          - services
  validationActions:
    - Audit
  validations:
    - expression: "!has(object.spec.externalIPs) || size(object.spec.externalIPs) == 0"
      message: externalIPs are not allowed.

```
