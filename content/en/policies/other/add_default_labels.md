---
type: "docs"
title: Add Default Labels
linkTitle: Add Default Labels
weight: 34
description: >
    
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/add_default_labels.yaml" target="-blank">/other/add_default_labels.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-default-labels
spec:
  background: false
  rules:
  - name: add-default-labels
    match:
      resources:
        kinds:
        - Pod
        - Service
        - Namespace
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            custom-foo-label: my-bar-default
```
