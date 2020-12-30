---
type: "docs"
title: Disallow Selinux
linkTitle: Disallow Selinux
weight: 45
description: >
    SELinux options can be used to escalate privileges and should not be allowed.
---

## Category
Pod Security Standards (Default)

## Definition
[/pod-security/default/disallow-selinux.yaml](https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-selinux.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-selinux
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Default)
    policies.kyverno.io/description: >-
      SELinux options can be used to escalate privileges and should not be allowed.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: seLinux
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Setting custom SELinux options is disallowed. The fields
        spec.securityContext.seLinuxOptions, spec.containers[*].securityContext.seLinuxOptions,
        and spec.initContainers[*].securityContext.seLinuxOptions must be empty.
      pattern:
        spec:
          =(securityContext):
            X(seLinuxOptions): "null"
          =(initContainers):
          - =(securityContext):
              X(seLinuxOptions): "null"
          containers:
          - =(securityContext):
              X(seLinuxOptions): "null"

```
