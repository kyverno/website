---
type: "docs"
title: Disallow Host Path
linkTitle: Disallow Host Path
weight: 42
description: >
    HostPath volumes let pods use host directories and volumes in containers. Using host resources can be used to access shared data or escalate privileges and should not be allowed.
---

## Category
Pod Security Standards (Default)

## Definition
[/pod-security/default/disallow-host-path.yaml](https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-host-path.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-path
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Default)
    policies.kyverno.io/description: >-
      HostPath volumes let pods use host directories and volumes in containers.
      Using host resources can be used to access shared data or escalate privileges
      and should not be allowed.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: host-path
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        HostPath volumes are forbidden. The fields spec.volumes[*].hostPath must not be set.
      pattern:
        spec:
          =(volumes):
          - X(hostPath): "null"

```
