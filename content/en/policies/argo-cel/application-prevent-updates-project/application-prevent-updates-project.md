---
title: "Prevent Updates to Project in CEL expressions"
category: Argo in CEL
version: 
subject: Application
policyType: "validate"
description: >
    This policy prevents updates to the project field after an Application is created.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//argo-cel/application-prevent-updates-project/application-prevent-updates-project.yaml" target="-blank">/argo-cel/application-prevent-updates-project/application-prevent-updates-project.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: application-prevent-updates-project
  annotations:
    policies.kyverno.io/title: Prevent Updates to Project in CEL expressions
    policies.kyverno.io/category: Argo in CEL 
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.12.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/subject: Application
    policies.kyverno.io/description: >-
      This policy prevents updates to the project field after an Application is created.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: project-updates
      match:
        any:
        - resources:
            kinds:
              - Application
      celPreconditions:
        - name: "operation-should-be-update"
          expression: "request.operation == 'UPDATE'"
      validate:
        cel:  
          expressions:
            - expression: "object.spec.project == oldObject.spec.project"
              message: "The spec.project cannot be changed once the Application is created."


```
