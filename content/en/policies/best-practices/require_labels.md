---
type: "docs"
title: Require Labels
linkTitle: Require Labels
weight: 9
description: >
    The ':latest' tag is mutable and can lead to unexpected errors if the  image changes. A best practice is to use an immutable tag that maps to  a specific version of an application pod.  
category: Best Practices
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
            # You can add more labels if you wish the policy to validate more 
            # than just one is present. Uncomment the below line, or add new ones.
            #app.kubernetes.io/component: "?*
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/require_labels.yaml" target="-blank">/best-practices/require_labels.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
  annotations:
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: >-
      The ':latest' tag is mutable and can lead to unexpected errors if the 
      image changes. A best practice is to use an immutable tag that maps to 
      a specific version of an application pod.  
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
            # You can add more labels if you wish the policy to validate more 
            # than just one is present. Uncomment the below line, or add new ones.
            #app.kubernetes.io/component: "?*
```
