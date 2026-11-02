---
title: 'Disallow Secrets from Env Vars in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
  - Secret
tags:
  - Sample
  - EKS Best Practices in vpol
version: 1.19.1
description: 'Secrets used as environment variables containing sensitive information may, if not carefully controlled,  be printed in log output which could be visible to unauthorized people and captured in forwarding applications. This policy disallows using Secrets as environment variables.'
createdAt: "2025-09-04T05:15:25.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/disallow-secrets-from-env-vars/disallow-secrets-from-env-vars.yaml" target="-blank">/other-vpol/disallow-secrets-from-env-vars/disallow-secrets-from-env-vars.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: secrets-not-from-env-vars
  annotations:
    policies.kyverno.io/title: Disallow Secrets from Env Vars in ValidatingPolicy
    policies.kyverno.io/category: Sample, EKS Best Practices in vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod, Secret
    policies.kyverno.io/minversion: 1.19.1
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: Secrets used as environment variables containing sensitive information may, if not carefully controlled,  be printed in log output which could be visible to unauthorized people and captured in forwarding applications. This policy disallows using Secrets as environment variables.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  variables:
    - name: allContainers
      expression: object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  validations:
    - expression: |-
        variables.allContainers.all(container,
          container.?env.orValue([]).all(env,
          (!has(env.valueFrom) || !has(env.valueFrom.secretKeyRef)) || exceptions.allowedValues.exists(value, value == 'env.secretKeyRef:' + env.valueFrom.secretKeyRef.name)))
      message: Secrets must be mounted as volumes, not as environment variables.
    - expression: variables.allContainers.all(container, container.?envFrom.orValue([]).all(envFrom, !has(envFrom.secretRef) || exceptions.allowedValues.exists(value, value == 'envFrom.secretRef:' + envFrom.secretRef.name)))
      message: Secrets must not come from envFrom statements.

```
