---
title: "Disallow SELinux"
linkTitle: "Disallow SELinux"
weight: 38
repo: "https://github.com/kyverno/policies/blob/main/pod-security/default/disallow-selinux/disallow-selinux.yaml"
description: >
    SELinux options can be used to escalate privileges and should not be allowed.
category: Pod Security Standards (Default)
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

---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-selinux/disallow-selinux.yaml" target="-blank">/pod-security/default/disallow-selinux/disallow-selinux.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-selinux
  annotations:
    policies.kyverno.io/title: Disallow SELinux
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
