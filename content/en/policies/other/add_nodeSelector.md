---
title: "Add nodeSelector"
category: Sample
policyType: "mutate"
description: >
    Adds the nodeSelector field to a Pod spec.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/add_nodeSelector.yaml" target="-blank">/other/add_nodeSelector.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-nodeselector
  annotations:
    policies.kyverno.io/title: Add nodeSelector
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Adds the nodeSelector field to a Pod spec.
spec:
  background: false
  rules:
  - name: add-nodeselector
    match:
      resources:
        kinds:
        - Pod
    # Adds the `nodeSelector` field to any Pod with two labels.
    mutate:
      patchStrategicMerge:
        spec:
          nodeSelector:
            foo: bar
            color: orange
```
