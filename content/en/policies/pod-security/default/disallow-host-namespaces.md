---
type: "docs"
title: Disallow Host Namespaces
linkTitle: Disallow Host Namespaces
weight: 29
description: >
    Host namespaces (Process ID namespace, Inter-Process Communication namespace, and network namespace) allow access to shared information and can be used to elevate privileges. Pods should not be allowed access to host namespaces.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-host-namespaces.yaml" target="-blank">/pod-security/default/disallow-host-namespaces.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-namespaces
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Default)
    policies.kyverno.io/description: >- 
      Host namespaces (Process ID namespace, Inter-Process Communication namespace, and
      network namespace) allow access to shared information and can be used to elevate
      privileges. Pods should not be allowed access to host namespaces.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: host-namespaces
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Sharing the host namespaces is disallowed. The fields spec.hostNetwork,
        spec.hostIPC, and spec.hostPID must not be set to true.
      pattern:
        spec:
          =(hostPID): "false"
          =(hostIPC): "false"
          =(hostNetwork): "false"
```
