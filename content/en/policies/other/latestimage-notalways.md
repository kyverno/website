---
type: "docs"
title: Latestimage Notalways
linkTitle: Latestimage Notalways
weight: 30
description: >
    
---

## Category


## Definition
[/other/latestimage-notalways.yaml](https://github.com/kyverno/policies/raw/main//other/latestimage-notalways.yaml)

```yaml
### This policy requires Kyverno v1.3.0+ ###
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: latestimage-notalways
spec:
  validationFailureAction: audit
  background: false
  rules:
  - name: latestimage-notalways
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "When using the `latest` tag, the `imagePullPolicy` must not use `Always`."  
      pattern:
        spec:
          containers:
          - (image): "*:latest | !*:*"
            imagePullPolicy: "!Always"
```
