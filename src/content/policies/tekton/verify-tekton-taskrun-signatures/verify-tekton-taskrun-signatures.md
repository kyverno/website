---
title: 'Require Signed Tekton Task'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - TaskRun
tags: []
version: 1.7.0
description: 'A signed bundle is required.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/tekton/verify-tekton-taskrun-signatures/verify-tekton-taskrun-signatures.yaml" target="-blank">/tekton/verify-tekton-taskrun-signatures/verify-tekton-taskrun-signatures.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: signed-tekton-task-bundle
  annotations:
    policies.kyverno.io/title: Require Signed Tekton Task
    policies.kyverno.io/category: Tekton
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: TaskRun
    kyverno.io/kyverno-version: 1.7.2
    policies.kyverno.io/minversion: 1.7.0
    kyverno.io/kubernetes-version: '1.23'
    policies.kyverno.io/description: A signed bundle is required.
spec:
  validationFailureAction: Audit
  webhookTimeoutSeconds: 30
  rules:
    - name: check-signature
      match:
        resources:
          kinds:
            - TaskRun
      imageExtractors:
        TaskRun:
          - name: taskruns
            path: /spec/taskRef
            value: bundle
            key: name
      verifyImages:
        - imageReferences:
            - '*'
          attestors:
            - entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEahmSvGFmxMJABilV1usgsw6ImcQ/
                      gDaxw57Sq+uNGHW8Q3zUSx46PuRqdTI+4qE3Ng2oFZgLMpFN/qMrP0MQQg==
                      -----END PUBLIC KEY-----
```
