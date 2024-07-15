---
title: "Prevent Use of Default Project in CEL expressions"
category: Argo in CEL
version: 1.11.0
subject: Application
policyType: "validate"
description: >
    This policy prevents the use of the default project in an Application.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//argo-cel/application-prevent-default-project/application-prevent-default-project.yaml" target="-blank">/argo-cel/application-prevent-default-project/application-prevent-default-project.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: application-prevent-default-project
  annotations:
    policies.kyverno.io/title: Prevent Use of Default Project in CEL expressions
    policies.kyverno.io/category: Argo in CEL 
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/subject: Application
    policies.kyverno.io/description: >-
      This policy prevents the use of the default project in an Application.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: default-project
      match:
        any:
        - resources:
            kinds:
              - Application
            operations:
            - CREATE
            - UPDATE
      validate:
        cel:
          expressions:
            - expression: "has(object.spec.project) && object.spec.project != 'default'"
              message: "The default project may not be used in an Application."


```
