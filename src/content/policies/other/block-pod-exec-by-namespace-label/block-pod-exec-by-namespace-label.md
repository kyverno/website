---
title: 'Block Pod Exec by Namespace Label'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/block-pod-exec-by-namespace-label/block-pod-exec-by-namespace-label.yaml" target="-blank">/other/block-pod-exec-by-namespace-label/block-pod-exec-by-namespace-label.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-exec-by-namespace-label
  annotations:
    policies.kyverno.io/title: Block Pod Exec by Namespace Label
    policies.kyverno.io/category: Sample
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: The `exec` command may be used to gain shell access, or run other commands, in a Pod's container. While this can be useful for troubleshooting purposes, it could represent an attack vector and is discouraged. This policy blocks Pod exec commands based upon a Namespace label `exec=false`.
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: deny-exec-by-ns-label
      match:
        any:
          - resources:
              kinds:
                - Pod/exec
      context:
        - name: nslabelexec
          apiCall:
            urlPath: /api/v1/namespaces/{{request.namespace}}
            jmesPath: metadata.labels.exec || ''
      preconditions:
        all:
          - key: "{{ request.operation || 'BACKGROUND' }}"
            operator: Equals
            value: CONNECT
      validate:
        message: Executing a command in a container is forbidden for Pods running in Namespaces protected with the label "exec=false".
        deny:
          conditions:
            any:
              - key: "{{ nslabelexec }}"
                operator: Equals
                value: "false"

```
