---
type: "docs"
title: Drop All Capabilities
linkTitle: Drop All Capabilities
weight: 21
description: >
    
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/require_drop_all.yaml" target="-blank">/other/require_drop_all.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: drop-all-capabilities
spec:
  validationFailureAction: audit
  rules:
  - name: drop-all-containers
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Drop all must be defined for every container in the Pod."
      pattern:
        spec:
          containers:
          - securityContext:
              capabilities:
                drop: ["ALL"]
  - name: drop-all-initcontainers
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Drop all must be defined for every container in the Pod."
      pattern:
        spec:
          initContainers:
          - securityContext:
              capabilities:
                drop: ["ALL"]
```
