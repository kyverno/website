---
title: 'Require Tekton Bundle'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - TaskRun
  - PipelineRun
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/tekton/require-tekton-bundle/require-tekton-bundle.yaml" target="-blank">/tekton/require-tekton-bundle/require-tekton-bundle.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-tekton-bundle
  annotations:
    policies.kyverno.io/title: Require Tekton Bundle
    policies.kyverno.io/category: Tekton
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: TaskRun, PipelineRun
    kyverno.io/kyverno-version: 1.7.1
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/description: PipelineRun and TaskRun resources must be executed from a bundle
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: check-bundle-pipelinerun
      match:
        any:
          - resources:
              kinds:
                - PipelineRun
      validate:
        message: A bundle is required.
        pattern:
          spec:
            pipelineRef:
              bundle: "?*"
    - name: check-bundle-taskrun
      match:
        any:
          - resources:
              kinds:
                - TaskRun
      validate:
        message: A bundle is required.
        pattern:
          spec:
            taskRef:
              bundle: "?*"

```
