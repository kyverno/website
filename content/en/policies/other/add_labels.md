---
title: "Add Labels"
category: Sample
policyType: "mutate"
description: >
    Simple mutation which adds a label `foo=bar` to different resource kinds.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/add_labels.yaml" target="-blank">/other/add_labels.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-labels
  annotations:
    policies.kyverno.io/title: Add Labels
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/description: >-
      Simple mutation which adds a label `foo=bar` to different resource kinds.
spec:
    rules:
    - name: add-labels
      match:
        resources:
          kinds:
          - Pod
          - Service
          - ConfigMap
          - Secret
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              foo: bar
```
