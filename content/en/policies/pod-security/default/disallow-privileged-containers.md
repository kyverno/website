---
type: "docs"
title: Disallow Privileged Containers
linkTitle: Disallow Privileged Containers
weight: 39
description: >
    Privileged mode disables most security mechanisms and must not be allowed.
---

## Category
Pod Security Standards (Default)

## Definition
[/pod-security/default/disallow-privileged-containers.yaml](https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-privileged-containers.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Default)
    policies.kyverno.io/description: >-
      Privileged mode disables most security mechanisms and must not be allowed.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: priviledged-containers
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged
        and spec.initContainers[*].securityContext.privileged must not be set to true.
      pattern:
        spec:
          =(initContainers):
          - =(securityContext):
              =(privileged): "false"          
          containers:
          - =(securityContext):
              =(privileged): "false"
```
