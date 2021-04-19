---
title: "Restrict Image Registries"
category: Best Practices
policyType: "validate"
description: >
    Images from unknown registries may not be scanned and secured.  Requiring use of known registries helps reduce threat exposure.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/restrict_image_registries/restrict_image_registries.yaml" target="-blank">/best-practices/restrict_image_registries/restrict_image_registries.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-image-registries
  annotations:
    policies.kyverno.io/title: Restrict Image Registries
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/minversion: 1.3.0
    policies.kyverno.io/description: >-
      Images from unknown registries may not be scanned and secured. 
      Requiring use of known registries helps reduce threat exposure.
spec:
  background: false
  validationFailureAction: enforce
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
