---
title: 'Prevent Updates to Project in CEL expressions'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Application
tags:
  - Argo in CEL
version: 1.17.0
description: 'This policy prevents updates to the project field after an Application is created.'
createdAt: "2026-10-25T00:12:22.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/argo-vpol/application-prevent-updates-project/application-prevent-updates-project.yaml" target="_blank" rel="noopener noreferrer">/argo-vpol/application-prevent-updates-project/application-prevent-updates-project.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: application-prevent-updates-project
  annotations:
    policies.kyverno.io/title: Prevent Updates to Project in CEL expressions
    policies.kyverno.io/category: Argo in CEL
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.17.0
    policies.kyverno.io/minversion: 1.17.0
    kyverno.io/kubernetes-version: 1.34-1.35
    policies.kyverno.io/subject: Application
    policies.kyverno.io/description: This policy prevents updates to the project field after an Application is created.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: false
  matchConstraints:
    resourceRules:
      - apiGroups:
          - argoproj.io
        apiVersions:
          - v1alpha1
        operations:
          - UPDATE
        resources:
          - applications
  validations:
    - message: The spec.project cannot be changed once the Application is created.
      expression: object.spec.project == oldObject.spec.project

```
