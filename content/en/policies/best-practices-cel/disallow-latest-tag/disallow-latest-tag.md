---
title: "Disallow Latest Tag in CEL expressions"
category: Best Practices in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    The ':latest' tag is mutable and can lead to unexpected errors if the image changes. A best practice is to use an immutable tag that maps to a specific version of an application Pod. This policy validates that the image specifies a tag and that it is not called `latest`.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices-cel/disallow-latest-tag/disallow-latest-tag.yaml" target="-blank">/best-practices-cel/disallow-latest-tag/disallow-latest-tag.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
  annotations:
    policies.kyverno.io/title: Disallow Latest Tag in CEL expressions
    policies.kyverno.io/category: Best Practices in CEL 
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      The ':latest' tag is mutable and can lead to unexpected errors if the
      image changes. A best practice is to use an immutable tag that maps to
      a specific version of an application Pod. This policy validates that the image
      specifies a tag and that it is not called `latest`.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: require-and-validate-image-tag
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
          - expression: "object.spec.containers.all(container, container.image.contains(':'))"
            message: "An image tag is required."
          - expression: "object.spec.containers.all(container, !container.image.endsWith(':latest'))"
            message: "Using a mutable image tag e.g. 'latest' is not allowed."


```
