---
title: 'Disallow all Secrets in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
  - Secret
tags:
  - Other in CEL
version: 1.11.0
description: 'Secrets often contain sensitive information which not all Pods need consume. This policy disables the use of all Secrets in a Pod definition. In order to work effectively, this Policy needs a separate Policy or rule to require `automountServiceAccountToken=false` at the Pod level or ServiceAccount level since this would otherwise result in a Secret being mounted.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-cel/disallow-all-secrets/disallow-all-secrets.yaml" target="-blank">/other-cel/disallow-all-secrets/disallow-all-secrets.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: no-secrets
  annotations:
    policies.kyverno.io/title: Disallow all Secrets in CEL expressions
    policies.kyverno.io/category: Other in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod, Secret
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/description: Secrets often contain sensitive information which not all Pods need consume. This policy disables the use of all Secrets in a Pod definition. In order to work effectively, this Policy needs a separate Policy or rule to require `automountServiceAccountToken=false` at the Pod level or ServiceAccount level since this would otherwise result in a Secret being mounted.
spec:
  validationFailureAction: Audit
  rules:
    - name: secrets-not-from-env-envFrom-and-volumes
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
          variables:
            - name: allContainers
              expression: object.spec.containers +  object.spec.?initContainers.orValue([]) +  object.spec.?ephemeralContainers.orValue([])
          expressions:
            - expression: variables.allContainers.all(container,  container.?env.orValue([]).all(env, env.?valueFrom.?secretKeyRef.orValue(true)))
              message: No Secrets from env.
            - expression: variables.allContainers.all(container,  container.?envFrom.orValue([]).all(envFrom, !has(envFrom.secretRef)))
              message: No Secrets from envFrom.
            - expression: object.spec.?volumes.orValue([]).all(volume, !has(volume.secret))
              message: No Secrets from volumes.

```
