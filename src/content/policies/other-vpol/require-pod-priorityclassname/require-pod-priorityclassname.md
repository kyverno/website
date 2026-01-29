---
title: 'Require Pod priorityClassName in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Multi-Tenancy
  - EKS Best Practices in vpol
description: 'A Pod may optionally specify a priorityClassName which indicates the scheduling priority relative to others. This requires creation of a PriorityClass object in advance. With this created, a Pod may set this field to that value. In a multi-tenant environment, it is often desired to require this priorityClassName be set to make certain tenant scheduling guarantees. This policy requires that a Pod defines the priorityClassName field with some value.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/require-pod-priorityclassname/require-pod-priorityclassname.yaml" target="-blank">/other-vpol/require-pod-priorityclassname/require-pod-priorityclassname.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-pod-priorityclassname
  annotations:
    policies.kyverno.io/title: Require Pod priorityClassName in ValidatingPolicy
    policies.kyverno.io/category: Multi-Tenancy, EKS Best Practices in vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: A Pod may optionally specify a priorityClassName which indicates the scheduling priority relative to others. This requires creation of a PriorityClass object in advance. With this created, a Pod may set this field to that value. In a multi-tenant environment, it is often desired to require this priorityClassName be set to make certain tenant scheduling guarantees. This policy requires that a Pod defines the priorityClassName field with some value.
spec:
  validationActions:
    - Audit
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
  validations:
    - expression: object.spec.?priorityClassName.orValue('') != ''
      message: Pods must define the priorityClassName field.

```
