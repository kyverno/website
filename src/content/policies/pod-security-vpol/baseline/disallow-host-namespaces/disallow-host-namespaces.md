---
title: 'Disallow Host Namespaces in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Pod Security Standards (Baseline) in ValidatingPolicy
version: 1.14.0
description: 'Host namespaces (Process ID namespace, Inter-Process Communication namespace, and network namespace) allow access to shared information and can be used to elevate privileges. Pods should not be allowed access to host namespaces. This policy ensures fields which make use of these host namespaces are unset or set to `false`.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-vpol/baseline/disallow-host-namespaces/disallow-host-namespaces.yaml" target="-blank">/pod-security-vpol/baseline/disallow-host-namespaces/disallow-host-namespaces.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-host-namespaces
  annotations:
    policies.kyverno.io/title: Disallow Host Namespaces in ValidatingPolicy
    policies.kyverno.io/category: Pod Security Standards (Baseline) in ValidatingPolicy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: 1.30+
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Host namespaces (Process ID namespace, Inter-Process Communication namespace, and network namespace) allow access to shared information and can be used to elevate privileges. Pods should not be allowed access to host namespaces. This policy ensures fields which make use of these host namespaces are unset or set to `false`.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  variables:
    - name: hostNetwork
      expression: object.spec.?hostNetwork.orValue(false)
    - name: hostIPC
      expression: object.spec.?hostIPC.orValue(false)
    - name: hostPID
      expression: object.spec.?hostPID.orValue(false)
  validations:
    - expression: "!(variables.hostNetwork || variables.hostIPC || variables.hostPID)"
      message: "Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must be unset or set to `false`.         "

```
