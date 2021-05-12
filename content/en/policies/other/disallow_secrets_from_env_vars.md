---
title: "Disallow Secrets from Env Vars"
category: Sample
version: 
subject: Pod, Secret
policyType: "validate"
description: >
    Sample policy to disallow using secrets from environment variables  which are visible in resource definitions. 
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/disallow_secrets_from_env_vars.yaml" target="-blank">/other/disallow_secrets_from_env_vars.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: secrets-not-from-env-vars
  annotations:
    policies.kyverno.io/title: Disallow Secrets from Env Vars
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod, Secret
    policies.kyverno.io/description: >-
      Sample policy to disallow using secrets from environment variables 
      which are visible in resource definitions. 
spec:
  validationFailureAction: audit
  rules:
  - name: secrets-not-from-env-vars
    match:
      resources:
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
      resources:
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
