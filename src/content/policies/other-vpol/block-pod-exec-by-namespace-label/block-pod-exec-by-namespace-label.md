---
title: 'Block Pod Exec by Namespace Label'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.14.0
description: 'The `exec` command may be used to gain shell access, or run other commands, in a Pod''s container. While this can be useful for troubleshooting purposes, it could represent an attack vector and is discouraged. This policy blocks Pod exec commands based upon a Namespace label `exec=false`.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/block-pod-exec-by-namespace-label/block-pod-exec-by-namespace-label.yaml" target="-blank">/other-vpol/block-pod-exec-by-namespace-label/block-pod-exec-by-namespace-label.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: deny-exec-by-namespace-label
  annotations:
    policies.kyverno.io/title: Block Pod Exec by Namespace Label
    policies.kyverno.io/category: Sample
    policies.kyverno.io/minversion: 1.14.0
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: The `exec` command may be used to gain shell access, or run other commands, in a Pod's container. While this can be useful for troubleshooting purposes, it could represent an attack vector and is discouraged. This policy blocks Pod exec commands based upon a Namespace label `exec=false`.
spec:
  validationActions:
    - Deny
  variables:
    - name: namespaceData
      expression: resource.Get('v1', 'namespaces', '', request.namespace)
    - name: execLabelValue
      expression: variables.namespaceData.metadata.?labels.?exec.orValue('')
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
    - messageExpression: "'Exec operations are not allowed in namespace \"' + request.namespace + '\" due to exec=false label'"
      expression: variables.execLabelValue != 'false'

```
