---
title: 'Require Labels'
category: validate
severity: medium
type: ValidatingPolicy
subjects: []
tags:
  - Best Practices
description: 'Enforce the presence of required labels that identify semantic attributes of applications or Deployments. Specifically, ensure that the standard label `app.kubernetes.io/name` is present on Pods with a non-empty value to enable consistent tooling and querying capabilities.'
createdAt: "2026-02-12T12:56:39.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices-vpol/require-labels/require-labels.yaml" target="-blank">/best-practices-vpol/require-labels/require-labels.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  annotations:
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: Enforce the presence of required labels that identify semantic attributes of applications or Deployments. Specifically, ensure that the standard label `app.kubernetes.io/name` is present on Pods with a non-empty value to enable consistent tooling and querying capabilities.
    policies.kyverno.io/severity: medium
    policies.kyverno.io/title: Require Labels
  name: require-labels
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
    - expression: has(object.metadata.labels) && 'app.kubernetes.io/name' in object.metadata.labels && object.metadata.labels['app.kubernetes.io/name'] != ''
      messageExpression: "'Pod ' + object.metadata.name + ' must have the label app.kubernetes.io/name with a non-empty value. Found labels: ' + (has(object.metadata.labels) ? string(object.metadata.labels) : 'none')"

```
