---
type: "docs"
title: Require Certain Labels
linkTitle: Require Certain Labels
weight: 7
description: >
    
---

## Category


## Definition
[/best-practices/require_certain_labels.yaml](https://github.com/kyverno/policies/raw/main//best-practices/require_certain_labels.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-certain-labels
spec:
  validationFailureAction: audit
  rules:
  - name: validate-certain-labels
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "The label `app.kubernetes.io/name` or `app.kubernetes.io/component` is required."
      anyPattern:
      - metadata:
          labels:
            app.kubernetes.io/name: "?*"
      - metadata:
          labels:
            app.kubernetes.io/component: "?*"
```
