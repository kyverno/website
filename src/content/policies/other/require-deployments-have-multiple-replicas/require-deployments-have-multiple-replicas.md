---
title: 'Require Multiple Replicas'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Deployment
tags:
  - Sample
version: 1.6.0
description: 'Deployments with a single replica cannot be highly available and thus the application may suffer downtime if that one replica goes down. This policy validates that Deployments have more than one replica.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/require-deployments-have-multiple-replicas/require-deployments-have-multiple-replicas.yaml" target="-blank">/other/require-deployments-have-multiple-replicas/require-deployments-have-multiple-replicas.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deployment-has-multiple-replicas
  annotations:
    policies.kyverno.io/title: Require Multiple Replicas
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Deployment
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: Deployments with a single replica cannot be highly available and thus the application may suffer downtime if that one replica goes down. This policy validates that Deployments have more than one replica.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: deployment-has-multiple-replicas
      match:
        any:
          - resources:
              kinds:
                - Deployment
      validate:
        message: Deployments should have more than one replica to ensure availability.
        pattern:
          spec:
            replicas: ">1"

```
