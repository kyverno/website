---
title: 'Ensure ApplicationSet Name Matches Project'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - ApplicationSet
tags:
  - Argo
version: 1.6.0
description: 'This policy ensures that the name of the ApplicationSet is the same value provided in the project.'
createdAt: "2022-05-11T19:07:30.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/argo/applicationset-name-matches-project/applicationset-name-matches-project.yaml" target="-blank">/argo/applicationset-name-matches-project/applicationset-name-matches-project.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: applicationset-name-matches-project
  annotations:
    policies.kyverno.io/title: Ensure ApplicationSet Name Matches Project
    policies.kyverno.io/category: Argo
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.2
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: ApplicationSet
    policies.kyverno.io/description: This policy ensures that the name of the ApplicationSet is the same value provided in the project.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: match-name
      match:
        any:
          - resources:
              kinds:
                - ApplicationSet
      preconditions:
        all:
          - key: "{{ request.operation || 'BACKGROUND' }}"
            operator: NotEquals
            value: DELETE
      validate:
        message: The name must match the project.
        pattern:
          spec:
            template:
              spec:
                project: "{{request.object.metadata.name}}"

```
