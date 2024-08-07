---
title: "Block Ephemeral Containers in CEL expressions"
category: Other in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    Ephemeral containers, enabled by default in Kubernetes 1.23, allow users to use the `kubectl debug` functionality and attach a temporary container to an existing Pod. This may potentially be used to gain access to unauthorized information executing inside one or more containers in that Pod. This policy blocks the use of ephemeral containers.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/block-ephemeral-containers/block-ephemeral-containers.yaml" target="-blank">/other-cel/block-ephemeral-containers/block-ephemeral-containers.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-ephemeral-containers
  annotations:
    policies.kyverno.io/title: Block Ephemeral Containers in CEL expressions
    policies.kyverno.io/category: Other in CEL 
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Ephemeral containers, enabled by default in Kubernetes 1.23, allow users to use the
      `kubectl debug` functionality and attach a temporary container to an existing Pod.
      This may potentially be used to gain access to unauthorized information executing inside
      one or more containers in that Pod. This policy blocks the use of ephemeral containers.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: block-ephemeral-containers
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
          - expression: "!has(object.spec.ephemeralContainers)"
            message: "Ephemeral (debug) containers are not permitted."


```
