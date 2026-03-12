---
title: 'Require Read-Only Root Filesystem'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Pod Security Standards
description: 'Containers must have a read-only root filesystem to prevent unauthorized modifications. This policy ensures readOnlyRootFilesystem is set to true in the securityContext of all containers.'
createdAt: "2026-02-12T12:56:39.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices-vpol/require-ro-rootfs/require-ro-rootfs.yaml" target="-blank">/best-practices-vpol/require-ro-rootfs/require-ro-rootfs.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  annotations:
    policies.kyverno.io/category: Pod Security Standards
    policies.kyverno.io/description: Containers must have a read-only root filesystem to prevent unauthorized modifications. This policy ensures readOnlyRootFilesystem is set to true in the securityContext of all containers.
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/title: Require Read-Only Root Filesystem
  name: require-ro-rootfs
spec:
  evaluation:
    background:
      enabled: true
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
  validationActions:
    - Audit
  validations:
    - expression: variables.allContainers.all(container, has(container.securityContext) && has(container.securityContext.readOnlyRootFilesystem) && container.securityContext.readOnlyRootFilesystem == true)
      message: Root filesystem must be read-only.
  variables:
    - expression: object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])
      name: allContainers

```
