---
type: "docs"
title: Deployment Has Multiple Replicas
linkTitle: Deployment Has Multiple Replicas
weight: 23
description: >
    
---

## Category


## Definition
[/other/require_deployments_have_multiple_replicas.yaml](https://github.com/kyverno/policies/raw/main//other/require_deployments_have_multiple_replicas.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deployment-has-multiple-replicas
spec:
  validationFailureAction: audit
  rules:
    - name: deployment-has-multiple-replicas
      match:
        resources:
          kinds:
            - Deployment
      exclude:
        resources:
          namespaces:
          - kyverno
          - kube-system
          - kube-node-lease
          - kube-public
      validate:
        message: "Deployments must have more than one replica to ensure availability."
        pattern:
          spec:
            replicas: ">1"
```
