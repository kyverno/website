---
title: Disallow Add Capabilities
linkTitle: Disallow Add Capabilities
weight: 28
description: >
    Capabilities permit privileged actions without giving full root access. Adding capabilities beyond the default set must not be allowed.
category: Pod Security Standards (Default)
rules:
  - name: capabilities
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Adding of additional capabilities beyond the default set is not allowed.
        The fields spec.containers[*].securityContext.capabilities.add and 
        spec.initContainers[*].securityContext.capabilities.add must be empty.
      pattern:
        spec:
          containers:
          - =(securityContext):
              =(capabilities):
                X(add): null
          =(initContainers):
          - =(securityContext):
              =(capabilities):
                X(add): null

---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-adding-capabilities.yaml" target="-blank">/pod-security/default/disallow-adding-capabilities.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-add-capabilities
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Default)
    policies.kyverno.io/description: >-
      Capabilities permit privileged actions without giving full root access.
      Adding capabilities beyond the default set must not be allowed.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: capabilities
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Adding of additional capabilities beyond the default set is not allowed.
        The fields spec.containers[*].securityContext.capabilities.add and 
        spec.initContainers[*].securityContext.capabilities.add must be empty.
      pattern:
        spec:
          containers:
          - =(securityContext):
              =(capabilities):
                X(add): null
          =(initContainers):
          - =(securityContext):
              =(capabilities):
                X(add): null

```
