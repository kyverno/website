---
title: 'Restrict NodePort Services'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Service
tags:
  - Best Practices
description: 'This policy restricts the creation of Services with type NodePort. NodePort services expose applications on a static port on each node, which can pose security risks and complicate network management.'
createdAt: "2026-02-12T12:56:39.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices-vpol/restrict-node-port/restrict-node-port.yaml" target="-blank">/best-practices-vpol/restrict-node-port/restrict-node-port.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  annotations:
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: This policy restricts the creation of Services with type NodePort. NodePort services expose applications on a static port on each node, which can pose security risks and complicate network management.
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/title: Restrict NodePort Services
  name: restrict-nodeport
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
    - expression: object.spec.type != 'NodePort'
      message: Services of type NodePort are not allowed.

```
