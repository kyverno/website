---
type: "docs"
title: Secrets Not From Env Vars
linkTitle: Secrets Not From Env Vars
weight: 27
description: >
    
---

## Category


## Definition
[/other/disallow_secrets_from_env_vars.yaml](https://github.com/kyverno/policies/raw/main//other/disallow_secrets_from_env_vars.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: secrets-not-from-env-vars
spec:
  background: false
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
```
