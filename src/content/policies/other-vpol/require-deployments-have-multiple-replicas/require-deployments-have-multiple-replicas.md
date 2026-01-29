---
title: 'Require Multiple Replicas in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Deployment
tags:
  - Sample in Vpol
version: 1.14.0
description: 'Deployments with a single replica cannot be highly available and thus the application may suffer downtime if that one replica goes down. This policy validates that Deployments have more than one replica.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/require-deployments-have-multiple-replicas/require-deployments-have-multiple-replicas.yaml" target="-blank">/other-vpol/require-deployments-have-multiple-replicas/require-deployments-have-multiple-replicas.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: deployment-has-multiple-replicas
  annotations:
    policies.kyverno.io/title: Require Multiple Replicas in ValidatingPolicy
    policies.kyverno.io/category: Sample in Vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Deployment
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: Deployments with a single replica cannot be highly available and thus the application may suffer downtime if that one replica goes down. This policy validates that Deployments have more than one replica.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - apps
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - deployments
  validations:
    - expression: object.spec.replicas > 1
      message: Deployments should have more than one replica to ensure availability.

```
