---
title: 'Block Pod Exec by Pod Name'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.15.0
description: 'The `exec` command may be used to gain shell access, or run other commands, in a Pod''s container. While this can be useful for troubleshooting purposes, it could represent an attack vector and is discouraged. This policy blocks Pod exec commands to Pods beginning with the name `myapp-maintenance-`.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/block-pod-exec-by-pod-name/block-pod-exec-by-pod-name.yaml" target="-blank">/other-vpol/block-pod-exec-by-pod-name/block-pod-exec-by-pod-name.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: deny-exec-by-pod-name
  annotations:
    policies.kyverno.io/title: Block Pod Exec by Pod Name
    policies.kyverno.io/category: Sample
    policies.kyverno.io/minversion: 1.15.0
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: The `exec` command may be used to gain shell access, or run other commands, in a Pod's container. While this can be useful for troubleshooting purposes, it could represent an attack vector and is discouraged. This policy blocks Pod exec commands to Pods beginning with the name `myapp-maintenance-`.
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
        Exec'ing into Pods called "myapp-maintenance" is not allowed.
      expression: |
        !request.name.startsWith("myapp-maintenance-")

```
