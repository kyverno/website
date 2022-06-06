---
title: "Require Run As Non-Root User"
category: Pod Security Standards (Restricted)
version: 
subject: Pod
policyType: "validate"
description: >
    Containers must be required to run as non-root users. This policy ensures `runAsUser` is either unset or set to a number greater than zero.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/restricted/require-run-as-non-root-user/require-run-as-non-root-user.yaml" target="-blank">/pod-security/restricted/require-run-as-non-root-user/require-run-as-non-root-user.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-run-as-non-root-user
  annotations:
    policies.kyverno.io/title: Require Run As Non-Root User
    policies.kyverno.io/category: Pod Security Standards (Restricted)
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    policies.kyverno.io/description: >-
      Containers must be required to run as non-root users. This policy ensures
      `runAsUser` is either unset or set to a number greater than zero.
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: run-as-non-root-user
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: >-
          Running as root is not allowed. The fields spec.securityContext.runAsUser,
          spec.containers[*].securityContext.runAsUser, spec.initContainers[*].securityContext.runAsUser,
          and spec.ephemeralContainers[*].securityContext.runAsUser must be unset or
          set to a number greater than zero.
        pattern:
          spec:
            =(securityContext):
              =(runAsUser): ">0"
            =(ephemeralContainers):
            - =(securityContext):
                =(runAsUser): ">0"
            =(initContainers):
            - =(securityContext):
                =(runAsUser): ">0"
            containers:
            - =(securityContext):
                =(runAsUser): ">0"

```
