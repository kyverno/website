---
title: 'Prevent Use of Default Project in CEL expressions'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Application
tags:
  - Argo in CEL
version: 1.14.0
description: 'This policy prevents the use of the default project in an Application.'
createdAt: "2026-04-12T16:53:01.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/argo-vpol/application-prevent-default-project/application-prevent-default-project.yaml" target="-blank">/argo-vpol/application-prevent-default-project/application-prevent-default-project.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: application-prevent-default-project
  annotations:
    policies.kyverno.io/title: Prevent Use of Default Project in CEL expressions
    policies.kyverno.io/category: Argo in CEL
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.17.0
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: 1.34-1.35
    policies.kyverno.io/subject: Application
    policies.kyverno.io/description: This policy prevents the use of the default project in an Application.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - argoproj.io
        apiVersions:
          - v1alpha1
        operations:
          - CREATE
          - UPDATE
        resources:
          - applications
  validations:
    - message: The default project may not be used in an Application.
      expression: object.spec.?project.orValue('') != 'default'

```
