---
type: "docs"
title: Require Labels
linkTitle: Require Labels
weight: 1
description: >
    
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/require_labels.yaml" target="-blank">/best-practices/require_labels.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: audit
  rules:
  - name: check-for-labels
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "The label `app.kubernetes.io/name` is required."
      pattern:
        metadata:
          labels:
            app.kubernetes.io/name: "?*"
            # You can add more labels if you wish the policy to validate more than just one is present. Uncomment the below line, or add new ones.
            #app.kubernetes.io/component: "?*
```
