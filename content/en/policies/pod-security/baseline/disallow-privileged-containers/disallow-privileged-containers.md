---
type: "docs"
title: Disallow Privileged Containers
linkTitle: Disallow Privileged Containers
weight: 42
description: >
    Privileged mode disables most security mechanisms and must not be allowed.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/baseline/disallow-privileged-containers/disallow-privileged-containers.yaml" target="-blank">/pod-security/baseline/disallow-privileged-containers/disallow-privileged-containers.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Baseline)
    policies.kyverno.io/severity: medium
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
