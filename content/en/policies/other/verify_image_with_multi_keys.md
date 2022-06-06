---
title: "Verify Image with Multiple Keys"
category: Sample
version: 1.5.0
subject: Pod
policyType: "verifyImages"
description: >
    There may be multiple keys used to sign images based on the parties involved in the creation process. This image verification policy looks like a global key in a ConfigMap and also an image-specific key in the same ConfigMap.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/verify_image_with_multi_keys.yaml" target="-blank">/other/verify_image_with_multi_keys.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image-with-multi-keys
  annotations:
    policies.kyverno.io/title: Verify Image with Multiple Keys
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.5.0
    policies.kyverno.io/description: >-
      There may be multiple keys used to sign images based on
      the parties involved in the creation process. This image
      verification policy looks like a global key in a ConfigMap
      and also an image-specific key in the same ConfigMap.
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: check-image-with-two-keys
      match:
        any:
        - resources:
            kinds:
              - Pod
      context:
      - name: keys
        configMap:
          name: keys
          namespace: default 
      verifyImages:
        # check global key
        - image: "*"
          key: "{{ keys.data.org }}"
        # check image specific key - lookup via image name
        - image: "ghcr.io/kyverno/*"
          key: "{{ keys.data.{{ images.name }} }}"
```
