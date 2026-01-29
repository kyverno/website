---
title: 'Block Pod Exec by Namespace Name'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.15.0
description: 'The `exec` command may be used to gain shell access, or run other commands, in a Pod''s container. While this can be useful for troubleshooting purposes, it could represent an attack vector and is discouraged. This policy blocks Pod exec commands to Pods in a Namespace called `pci`.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/block-pod-exec-by-namespace/block-pod-exec-by-namespace.yaml" target="-blank">/other-vpol/block-pod-exec-by-namespace/block-pod-exec-by-namespace.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: deny-exec-by-namespace-name
  annotations:
    policies.kyverno.io/title: Block Pod Exec by Namespace Name
    policies.kyverno.io/category: Sample
    policies.kyverno.io/minversion: 1.15.0
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: The `exec` command may be used to gain shell access, or run other commands, in a Pod's container. While this can be useful for troubleshooting purposes, it could represent an attack vector and is discouraged. This policy blocks Pod exec commands to Pods in a Namespace called `pci`.
spec:
  evaluation:
    background:
      enabled: true
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - resources:
          - pods/exec
        operations:
          - CONNECT
        apiGroups:
          - ""
        apiVersions:
          - v1
  validations:
    - message: |
        Pods in this namespace may not be exec'd into.
      expression: |
        request.namespace != "pci"

```
