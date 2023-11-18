---
title: "Disallow Privileged Containers in CEL expressions"
category: Pod Security Standards (Baseline) in CEL
version: 
subject: Pod
policyType: "validate"
description: >
    Privileged mode disables most security mechanisms and must not be allowed. This policy ensures Pods do not call for privileged mode.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security-cel/baseline/disallow-privileged-containers/disallow-privileged-containers.yaml" target="-blank">/pod-security-cel/baseline/disallow-privileged-containers/disallow-privileged-containers.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
  annotations:
    policies.kyverno.io/title: Disallow Privileged Containers in CEL expressions
    policies.kyverno.io/category: Pod Security Standards (Baseline) in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      Privileged mode disables most security mechanisms and must not be allowed. This policy
      ensures Pods do not call for privileged mode.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: privileged-containers
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        cel:
          expressions:
            - expression: >-
                object.spec.containers.all(container, !has(container.securityContext) ||
                !has(container.securityContext.privileged) ||
                container.securityContext.privileged == false)
              message: >-
                Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged
                must be unset or set to `false`.

            - expression: >-
                !has(object.spec.initContainers) ||
                object.spec.initContainers.all(container, !has(container.securityContext) ||
                !has(container.securityContext.privileged) ||
                container.securityContext.privileged == false)
              message: >-
                Privileged mode is disallowed. The fields spec.initContainers[*].securityContext.privileged
                must be unset or set to `false`.

            - expression: >-
                !has(object.spec.ephemeralContainers) ||
                object.spec.ephemeralContainers.all(container, !has(container.securityContext) ||
                !has(container.securityContext.privileged) ||
                container.securityContext.privileged == false)
              message: >-
                Privileged mode is disallowed. The fields spec.ephemeralContainers[*].securityContext.privileged
                must be unset or set to `false`.

```
