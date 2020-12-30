---
type: "docs"
title: Imagepullpolicy Always
linkTitle: Imagepullpolicy Always
weight: 29
description: >
    
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/imagepullpolicy-always.yaml" target="-blank">/other/imagepullpolicy-always.yaml</a>

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: imagepullpolicy-always
spec:
  validationFailureAction: audit
  background: false
  rules:
  - name: imagepullpolicy-always
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "The imagePullPolicy must be set to `Always` for all containers when a tag other than `latest` is used."  
      pattern:
        spec:
          containers:
          - imagePullPolicy: Always
```
