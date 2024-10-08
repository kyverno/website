---
title: "Require Images Use Checksums in CEL expressions"
category: Sample in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    Use of a SHA checksum when pulling an image is often preferable because tags are mutable and can be overwritten. This policy checks to ensure that all images use SHA checksums rather than tags.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/require-image-checksum/require-image-checksum.yaml" target="-blank">/other-cel/require-image-checksum/require-image-checksum.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-image-checksum
  annotations:
    policies.kyverno.io/title: Require Images Use Checksums in CEL expressions
    policies.kyverno.io/category: Sample in CEL 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      Use of a SHA checksum when pulling an image is often preferable because tags
      are mutable and can be overwritten. This policy checks to ensure that all images
      use SHA checksums rather than tags.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: require-image-checksum
    match:
      any:
      - resources:
          kinds:
          - Pod
          operations:
          - CREATE
          - UPDATE
    validate:
      cel:
        expressions:
          - expression: "object.spec.containers.all(container, container.image.contains('@'))"
            message: "Images must use checksums rather than tags."


```
