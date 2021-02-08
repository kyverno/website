---
type: "docs"
title: Require Non Root Groups
linkTitle: Require Non Root Groups
weight: 38
description: >
    Containers should be forbidden from running with a root primary or supplementary GID.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/restricted/non-root-groups.yaml" target="-blank">/pod-security/restricted/non-root-groups.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-non-root-groups
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Restricted)
    policies.kyverno.io/description: >-
      Containers should be forbidden from running with a root primary or supplementary GID.
spec:
  background: true
  validationFailureAction: audit
  rules:
  - name: check-runasgroup
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Running with root group IDs is disallowed. The fields
        spec.securityContext.runAsGroup, spec.containers[*].securityContext.runAsGroup,
        and spec.initContainers[*].securityContext.runAsGroup must be empty
        or greater than zero.
      pattern:
        spec:
          =(securityContext):
            =(runAsGroup): ">0"
          =(initContainers):
          - =(securityContext):
              =(runAsGroup): ">0"
          containers:
          - =(securityContext):
              =(runAsGroup): ">0"
  - name: check-supplementalGroups
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Adding of supplemental group IDs is not allowed. The field
        spec.securityContext.supplementalGroups must not be defined.
      pattern:
        spec:
          =(securityContext):
            =(supplementalGroups): ["null"]
  - name: check-fsGroup
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Changing of file system groups is not allowed. The field
        spec.securityContext.fsGroup must not be defined.
      pattern:
        spec:
          =(securityContext):
            X(fsGroup): "null"

```
