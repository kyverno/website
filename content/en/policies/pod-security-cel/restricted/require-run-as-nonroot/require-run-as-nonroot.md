---
title: "Require runAsNonRoot in CEL"
category: Pod Security Standards (Restricted) in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    Containers must be required to run as non-root. This policy ensures `runAsNonRoot` is set to true.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security-cel/restricted/require-run-as-nonroot/require-run-as-nonroot.yaml" target="-blank">/pod-security-cel/restricted/require-run-as-nonroot/require-run-as-nonroot.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-run-as-nonroot
  annotations:
    policies.kyverno.io/title: Require runAsNonRoot in CEL
    policies.kyverno.io/category: Pod Security Standards (Restricted) in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kyverno-version: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      Containers must be required to run as non-root. This policy ensures
      `runAsNonRoot` is set to true.
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
            operations:
            - CREATE
            - UPDATE
      validate:
        cel:
          expressions:
            - expression: >-
                (
                    (
                      has(object.spec.securityContext) &&
                      has(object.spec.securityContext.runAsNonRoot) &&
                      object.spec.securityContext.runAsNonRoot == true
                    ) && (
                      (
                          object.spec.containers +
                          (has(object.spec.initContainers) ? object.spec.initContainers : []) +
                          (has(object.spec.ephemeralContainers) ? object.spec.ephemeralContainers : [])
                      ).all(container,
                          !has(container.securityContext) ||
                          !has(container.securityContext.runAsNonRoot) ||
                          container.securityContext.runAsNonRoot == true)
                    )
                ) || (
                    (
                        object.spec.containers +
                        (has(object.spec.initContainers) ? object.spec.initContainers : []) +
                        (has(object.spec.ephemeralContainers) ? object.spec.ephemeralContainers : [])
                    ).all(container,
                        has(container.securityContext) &&
                        has(container.securityContext.runAsNonRoot) &&
                        container.securityContext.runAsNonRoot == true)
                )
              message: >-
                Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot or all of
                spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot and
                spec.ephemeralContainers[*].securityContext.runAsNonRoot, must be set to true.
                

```
