---
type: "docs"
title: Disallow Proc Mount
linkTitle: Disallow Proc Mount
weight: 48
description: >
    The default /proc masks are set up to reduce attack surface and should be required.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-proc-mount.yaml" target="-blank">/pod-security/default/disallow-proc-mount.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-proc-mount
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Default)
    policies.kyverno.io/description: >-
      The default /proc masks are set up to reduce attack surface and should be required.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: proc-mount
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Changing the proc mount from the defaults is not allowed. The fields
        spec.containers[*].securityContext.procMount and
        spec.initContainers[*].securityContext.procMount must not be changed 
        from `Default`.
      pattern:
        spec:
          =(initContainers):
          - =(securityContext):
              =(procMount): "Default"
          containers:
          - =(securityContext):
              =(procMount): "Default"

```
