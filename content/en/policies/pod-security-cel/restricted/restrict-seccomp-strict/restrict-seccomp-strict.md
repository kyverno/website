---
title: "Restrict Seccomp (Strict) in CEL"
category: Pod Security Standards (Restricted) in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    The seccomp profile in the Restricted group must not be explicitly set to Unconfined but additionally must also not allow an unset value. This policy,  requiring Kubernetes v1.19 or later, ensures that seccomp is  set to `RuntimeDefault` or `Localhost`. A known issue prevents a policy such as this using `anyPattern` from being persisted properly in Kubernetes 1.23.0-1.23.2.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security-cel/restricted/restrict-seccomp-strict/restrict-seccomp-strict.yaml" target="-blank">/pod-security-cel/restricted/restrict-seccomp-strict/restrict-seccomp-strict.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-seccomp-strict
  annotations:
    policies.kyverno.io/title: Restrict Seccomp (Strict) in CEL
    policies.kyverno.io/category: Pod Security Standards (Restricted) in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kyverno-version: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      The seccomp profile in the Restricted group must not be explicitly set to Unconfined
      but additionally must also not allow an unset value. This policy, 
      requiring Kubernetes v1.19 or later, ensures that seccomp is 
      set to `RuntimeDefault` or `Localhost`. A known issue prevents a policy such as this
      using `anyPattern` from being persisted properly in Kubernetes 1.23.0-1.23.2.
spec:
  background: true
  validationFailureAction: Audit
  rules:
    - name: check-seccomp-strict
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
                !has(object.spec.securityContext) ||
                !has(object.spec.securityContext.seccompProfile) ||
                !has(object.spec.securityContext.seccompProfile.type) ||
                object.spec.securityContext.seccompProfile.type == 'RuntimeDefault' ||
                object.spec.securityContext.seccompProfile.type == 'Localhost'
              message: >-
                Use of custom Seccomp profiles is disallowed. The field
                spec.securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`.
      
            - expression: >- 
                object.spec.containers.all(container, !has(container.securityContext) ||
                !has(container.securityContext.seccompProfile) ||
                !has(container.securityContext.seccompProfile.type) ||
                container.securityContext.seccompProfile.type == 'RuntimeDefault' ||
                container.securityContext.seccompProfile.type == 'Localhost')
              message: >-
                Use of custom Seccomp profiles is disallowed. The field
                spec.containers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`.
              
            - expression: >- 
                !has(object.spec.initContainers) ||
                object.spec.initContainers.all(container, !has(container.securityContext) ||
                !has(container.securityContext.seccompProfile) ||
                !has(container.securityContext.seccompProfile.type) ||
                container.securityContext.seccompProfile.type == 'RuntimeDefault' ||
                container.securityContext.seccompProfile.type == 'Localhost')
              message: >-
                Use of custom Seccomp profiles is disallowed. The field
                spec.initContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`.

            - expression: >- 
                !has(object.spec.ephemeralContainers) ||
                object.spec.ephemeralContainers.all(container, !has(container.securityContext) ||
                !has(container.securityContext.seccompProfile) ||
                !has(container.securityContext.seccompProfile.type) ||
                container.securityContext.seccompProfile.type == 'RuntimeDefault' ||
                container.securityContext.seccompProfile.type == 'Localhost')
              message: >-
                Use of custom Seccomp profiles is disallowed. The field
                spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`.

```
