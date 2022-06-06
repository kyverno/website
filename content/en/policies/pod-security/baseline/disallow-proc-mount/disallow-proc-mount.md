---
title: "Disallow procMount"
category: Pod Security Standards (Baseline)
version: 
subject: Pod
policyType: "validate"
description: >
    The default /proc masks are set up to reduce attack surface and should be required. This policy ensures nothing but the default procMount can be specified. Note that in order for users to deviate from the `Default` procMount requires setting a feature gate at the API server.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/baseline/disallow-proc-mount/disallow-proc-mount.yaml" target="-blank">/pod-security/baseline/disallow-proc-mount/disallow-proc-mount.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-proc-mount
  annotations:
    policies.kyverno.io/title: Disallow procMount
    policies.kyverno.io/category: Pod Security Standards (Baseline)
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    policies.kyverno.io/description: >-
      The default /proc masks are set up to reduce attack surface and should be required. This policy
      ensures nothing but the default procMount can be specified. Note that in order for users
      to deviate from the `Default` procMount requires setting a feature gate at the API
      server.
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: check-proc-mount
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: >-
          Changing the proc mount from the default is not allowed. The fields
          spec.containers[*].securityContext.procMount, spec.initContainers[*].securityContext.procMount,
          and spec.ephemeralContainers[*].securityContext.procMount must be unset or
          set to `Default`.
        pattern:
          spec:
            =(ephemeralContainers):
              - =(securityContext):
                  =(procMount): "Default"
            =(initContainers):
              - =(securityContext):
                  =(procMount): "Default"
            containers:
              - =(securityContext):
                  =(procMount): "Default"

```
