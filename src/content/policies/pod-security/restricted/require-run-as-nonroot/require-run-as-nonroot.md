---
title: 'Require runAsNonRoot'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
description: 'Containers must be required to run as non-root users. This policy ensures `runAsNonRoot` is set to `true`. A known issue prevents a policy such as this using `anyPattern` from being persisted properly in Kubernetes 1.23.0-1.23.2.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security/restricted/require-run-as-nonroot/require-run-as-nonroot.yaml" target="-blank">/pod-security/restricted/require-run-as-nonroot/require-run-as-nonroot.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-run-as-nonroot
  annotations:
    policies.kyverno.io/title: Require runAsNonRoot
    policies.kyverno.io/category: Pod Security Standards (Restricted)
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: 1.22-1.23
    policies.kyverno.io/description: Containers must be required to run as non-root users. This policy ensures `runAsNonRoot` is set to `true`. A known issue prevents a policy such as this using `anyPattern` from being persisted properly in Kubernetes 1.23.0-1.23.2.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: run-as-non-root
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`.
        anyPattern:
          - spec:
              securityContext:
                runAsNonRoot: 'true'
              '=(ephemeralContainers)':
                - '=(securityContext)':
                    '=(runAsNonRoot)': 'true'
              '=(initContainers)':
                - '=(securityContext)':
                    '=(runAsNonRoot)': 'true'
              containers:
                - '=(securityContext)':
                    '=(runAsNonRoot)': 'true'
          - spec:
              '=(ephemeralContainers)':
                - securityContext:
                    runAsNonRoot: 'true'
              '=(initContainers)':
                - securityContext:
                    runAsNonRoot: 'true'
              containers:
                - securityContext:
                    runAsNonRoot: 'true'
```
