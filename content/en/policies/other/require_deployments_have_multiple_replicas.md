---
type: "docs"
title: Require Multiple Replicas
linkTitle: Require Multiple Replicas
weight: 22
description: >
    Sample policy that requires more than one replica for deployments.    
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/require_deployments_have_multiple_replicas.yaml" target="-blank">/other/require_deployments_have_multiple_replicas.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deployment-has-multiple-replicas
  annotations:
    policies.kyverno.io/title: Require Multiple Replicas
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Sample policy that requires more than one replica for deployments.    
spec:
  validationFailureAction: audit
  rules:
    - name: deployment-has-multiple-replicas
      match:
        resources:
          kinds:
          - Deployment
      validate:
        message: "Deployments should have more than one replica to ensure availability."
        pattern:
          spec:
            replicas: ">1"
```
