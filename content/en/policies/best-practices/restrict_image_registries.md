---
type: "docs"
title: Restrict Image Registries
linkTitle: Restrict Image Registries
weight: 14
description: >
    Images from unknown registries may not be scanned and secured.  Requiring use of known registries helps reduce threat exposure.
category: Best Practices
rules:
  - name: validate-registries
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Unknown image registry."
      pattern:
        spec:
          containers:
          - image: "k8s.gcr.io/* | gcr.io/*"
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/restrict_image_registries.yaml" target="-blank">/best-practices/restrict_image_registries.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-image-registries
  annotations:
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: >-
      Images from unknown registries may not be scanned and secured. 
      Requiring use of known registries helps reduce threat exposure.
spec:
  validationFailureAction: audit
  rules:
  - name: validate-registries
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Unknown image registry."
      pattern:
        spec:
          containers:
          - image: "k8s.gcr.io/* | gcr.io/*"
```
