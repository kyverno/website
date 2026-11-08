---
title: 'Require Images Use Checksums in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Sample in Vpol
version: 1.19.1
description: 'Use of a SHA checksum when pulling an image is often preferable because tags are mutable and can be overwritten. This policy checks to ensure that all images use SHA checksums rather than tags.'
createdAt: "2025-09-04T05:15:25.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/require-image-checksum/require-image-checksum.yaml" target="_blank" rel="noopener noreferrer">/other-vpol/require-image-checksum/require-image-checksum.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-image-checksum
  annotations:
    policies.kyverno.io/title: Require Images Use Checksums in ValidatingPolicy
    policies.kyverno.io/category: Sample in Vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.19.1
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: Use of a SHA checksum when pulling an image is often preferable because tags are mutable and can be overwritten. This policy checks to ensure that all images use SHA checksums rather than tags.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  variables:
    - name: allContainers
      expression: object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  validations:
    - expression: variables.allContainers.all(container, container.image.contains('@') || (has(exceptions.allowedImages) && exceptions.allowedImages.exists(image, image == container.image)))
      message: Images must use checksums rather than tags.

```
