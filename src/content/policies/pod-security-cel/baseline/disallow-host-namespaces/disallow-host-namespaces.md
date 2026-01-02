---
title: 'Disallow Host Namespaces in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Pod Security Standards (Baseline) in CEL
version: 1.11.0
description: 'Host namespaces (Process ID namespace, Inter-Process Communication namespace, and network namespace) allow access to shared information and can be used to elevate privileges. Pods should not be allowed access to host namespaces. This policy ensures fields which make use of these host namespaces are unset or set to `false`.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-cel/baseline/disallow-host-namespaces/disallow-host-namespaces.yaml" target="-blank">/pod-security-cel/baseline/disallow-host-namespaces/disallow-host-namespaces.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-namespaces
  annotations:
    policies.kyverno.io/title: Disallow Host Namespaces in CEL expressions
    policies.kyverno.io/category: Pod Security Standards (Baseline) in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Host namespaces (Process ID namespace, Inter-Process Communication namespace, and network namespace) allow access to shared information and can be used to elevate privileges. Pods should not be allowed access to host namespaces. This policy ensures fields which make use of these host namespaces are unset or set to `false`.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: host-namespaces
      match:
        any:
          - resources:
              kinds:
                - Pod
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: ( object.spec.?hostNetwork.orValue(false) == false) && ( object.spec.?hostIPC.orValue(false) == false) && ( object.spec.?hostPID.orValue(false) == false)
              message: Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must be unset or set to `false`.

```
