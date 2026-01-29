---
title: 'Restrict Seccomp (Strict) in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Pod Security Standards (Restricted) in ValidatingPolicy
version: 1.14.0
description: 'The seccomp profile in the Restricted group must not be explicitly set to Unconfined but additionally must also not allow an unset value. This policy,  requiring Kubernetes v1.30 or later, ensures that seccomp is  set to `RuntimeDefault` or `Localhost`. A known issue prevents a policy such as this using `anyPattern` from being persisted properly in Kubernetes 1.23.0-1.23.2.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-vpol/restricted/restrict-seccomp-strict/restrict-seccomp-strict.yaml" target="-blank">/pod-security-vpol/restricted/restrict-seccomp-strict/restrict-seccomp-strict.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-seccomp-strict
  annotations:
    policies.kyverno.io/title: Restrict Seccomp (Strict) in ValidatingPolicy
    policies.kyverno.io/category: Pod Security Standards (Restricted) in ValidatingPolicy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: 1.30+
    policies.kyverno.io/description: The seccomp profile in the Restricted group must not be explicitly set to Unconfined but additionally must also not allow an unset value. This policy,  requiring Kubernetes v1.30 or later, ensures that seccomp is  set to `RuntimeDefault` or `Localhost`. A known issue prevents a policy such as this using `anyPattern` from being persisted properly in Kubernetes 1.23.0-1.23.2.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  variables:
    - name: allContainers
      expression: object.spec.containers +  object.spec.?initContainers.orValue([]) +  object.spec.?ephemeralContainers.orValue([])
  validations:
    - expression: object.spec.?securityContext.?seccompProfile.?type.orValue('RuntimeDefault') in ['RuntimeDefault', 'Localhost'] && variables.allContainers.all(container,  container.?securityContext.?seccompProfile.?type.orValue('RuntimeDefault') in ['RuntimeDefault', 'Localhost'])
      message: seccompProfile.type must be either 'RuntimeDefault' or 'Localhost'.

```
