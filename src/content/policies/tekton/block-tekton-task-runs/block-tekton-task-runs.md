---
title: 'Block Tekton TaskRun'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - TaskRun
tags:
  - Tekton
version: 1.6.0
description: 'Restrict creation of TaskRun resources to the Tekton pipelines controller.'
createdAt: "2022-09-21T15:42:39.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/tekton/block-tekton-task-runs/block-tekton-task-runs.yaml" target="-blank">/tekton/block-tekton-task-runs/block-tekton-task-runs.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-tekton-task-runs
  annotations:
    policies.kyverno.io/title: Block Tekton TaskRun
    policies.kyverno.io/category: Tekton
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: TaskRun
    kyverno.io/kyverno-version: 1.7.1
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/description: Restrict creation of TaskRun resources to the Tekton pipelines controller.
spec:
  validationFailureAction: Audit
  background: false
  rules:
    - name: check-taskrun-user
      match:
        any:
          - resources:
              kinds:
                - TaskRun
      exclude:
        any:
          - subjects:
              - kind: User
                name: system:serviceaccount:tekton-pipelines:tekton-pipelines-controller
      preconditions:
        all:
          - key: "{{ request.operation || 'BACKGROUND' }}"
            operator: AnyIn
            value:
              - CREATE
              - UPDATE
      validate:
        message: Creating a TaskRun is not allowed.
        deny: {}

```
