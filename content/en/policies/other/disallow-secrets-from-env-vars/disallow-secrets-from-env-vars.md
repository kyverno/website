---
title: "Disallow Secrets from Env Vars"
category: Sample, EKS Best Practices
version: 
subject: Pod, Secret
policyType: "validate"
description: >
    Secrets used as environment variables containing sensitive information may, if not carefully controlled,  be printed in log output which could be visible to unauthorized people and captured in forwarding applications. This policy disallows using Secrets as environment variables.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/disallow-secrets-from-env-vars/disallow-secrets-from-env-vars.yaml" target="-blank">/other/disallow-secrets-from-env-vars/disallow-secrets-from-env-vars.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: secrets-not-from-env-vars
  annotations:
    policies.kyverno.io/title: Disallow Secrets from Env Vars
    policies.kyverno.io/category: Sample, EKS Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod, Secret
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/description: >-
      Secrets used as environment variables containing sensitive information may, if not carefully controlled, 
      be printed in log output which could be visible to unauthorized people and captured in forwarding
      applications. This policy disallows using Secrets as environment variables.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: secrets-not-from-env-vars
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Secrets must be mounted as volumes, not as environment variables."
      pattern:
        spec:
          containers:
          - name: "*"
            =(env):
            - =(valueFrom):
                X(secretKeyRef): "null"
  - name: secrets-not-from-envfrom
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Secrets must not come from envFrom statements."
      pattern:
        spec:
          containers:
          - name: "*"
            =(envFrom):
            - X(secretRef): "null"
```
