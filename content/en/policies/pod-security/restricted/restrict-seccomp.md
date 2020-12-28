---
type: "docs"
title: Restrict Seccomp
linkTitle: Restrict Seccomp
weight: 49
description: >
    The runtime default seccomp profile must be required, or only specific additional profiles should be allowed.
---

## Category
Pod Security Standards (Restricted)

## Definition
[/pod-security/restricted/restrict-seccomp.yaml](https://github.com/kyverno/policies/raw/main//pod-security/restricted/restrict-seccomp.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-seccomp
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Restricted)
    policies.kyverno.io/description: >-
      The runtime default seccomp profile must be required, or only specific
      additional profiles should be allowed.
spec:
  background: true
  validationFailureAction: audit
  rules:
  - name: seccomp
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Use of custom Seccomp profiles is disallowed. The fields
        spec.securityContext.seccompProfile.type,
        spec.containers[*].securityContext.seccompProfile.type, and
        spec.initContainers[*].securityContext.seccompProfile.type
        must be unset or set to `runtime/default`.
      pattern:
        spec:
          =(securityContext):
            =(seccompProfile):
              =(type): "runtime/default"
          =(initContainers):
          - =(securityContext):
              =(seccompProfile):
                =(type): "runtime/default"
          containers:
          - =(securityContext):
              =(seccompProfile):
                =(type): "runtime/default"

```
