---
type: "docs"
title: Disallow Latest Tag
linkTitle: Disallow Latest Tag
weight: 7
description: >
    The ':latest' tag is mutable and can lead to unexpected errors if the  image changes. A best practice is to use an immutable tag that maps to  a specific version of an application pod.
category: Best Practices
rules:
  - name: require-image-tag
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "An image tag is required."  
      pattern:
        spec:
          containers:
          - image: "*:*"
  - name: validate-image-tag
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Using a mutable image tag e.g. 'latest' is not allowed."
      pattern:
        spec:
          containers:
          - image: "!*:latest"
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/disallow_latest_tag.yaml" target="-blank">/best-practices/disallow_latest_tag.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
  annotations:
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: >-
      The ':latest' tag is mutable and can lead to unexpected errors if the 
      image changes. A best practice is to use an immutable tag that maps to 
      a specific version of an application pod.
spec:
  validationFailureAction: audit
  rules:
  - name: require-image-tag
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "An image tag is required."  
      pattern:
        spec:
          containers:
          - image: "*:*"
  - name: validate-image-tag
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Using a mutable image tag e.g. 'latest' is not allowed."
      pattern:
        spec:
          containers:
          - image: "!*:latest"
```
