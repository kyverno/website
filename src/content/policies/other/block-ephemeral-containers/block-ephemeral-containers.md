---
title: 'Block Ephemeral Containers'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Other
version: 1.6.0
description: 'Ephemeral containers, enabled by default in Kubernetes 1.23, allow users to use the `kubectl debug` functionality and attach a temporary container to an existing Pod. This may potentially be used to gain access to unauthorized information executing inside one or more containers in that Pod. This policy blocks the use of ephemeral containers.'
createdAt: "2023-04-04T23:03:22.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/block-ephemeral-containers/block-ephemeral-containers.yaml" target="-blank">/other/block-ephemeral-containers/block-ephemeral-containers.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-ephemeral-containers
  annotations:
    policies.kyverno.io/title: Block Ephemeral Containers
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Ephemeral containers, enabled by default in Kubernetes 1.23, allow users to use the `kubectl debug` functionality and attach a temporary container to an existing Pod. This may potentially be used to gain access to unauthorized information executing inside one or more containers in that Pod. This policy blocks the use of ephemeral containers.
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
      validate:
        message: Ephemeral (debug) containers are not permitted.
        pattern:
          spec:
            X(ephemeralContainers): "null"

```
