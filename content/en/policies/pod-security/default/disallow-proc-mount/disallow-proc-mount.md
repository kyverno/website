---
type: "docs"
title: Require Default Proc Mount
linkTitle: Require Default Proc Mount
weight: 37
description: >
    The default /proc masks are set up to reduce attack surface and should be required.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-proc-mount/disallow-proc-mount.yaml" target="-blank">/pod-security/default/disallow-proc-mount/disallow-proc-mount.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-default-proc-mount
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Default)
    policies.kyverno.io/description: >-
      The default /proc masks are set up to reduce attack surface and should be required.
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: check-proc-mount
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: >-
          Changing the proc mount from the default is not allowed. The fields
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
