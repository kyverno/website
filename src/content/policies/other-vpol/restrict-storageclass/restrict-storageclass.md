---
title: 'Restrict StorageClass in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - StorageClass
tags:
  - Other
  - Multi-Tenancy in vpol
description: 'StorageClasses allow description of custom "classes" of storage offered by the cluster, based on quality-of-service levels, backup policies, or custom policies determined by the cluster administrators. For shared StorageClasses in a multi-tenancy environment, a reclaimPolicy of `Delete` should be used to ensure a PersistentVolume cannot be reused across Namespaces. This policy requires StorageClasses set a reclaimPolicy of `Delete`.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/restrict-storageclass/restrict-storageclass.yaml" target="-blank">/other-vpol/restrict-storageclass/restrict-storageclass.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-storageclass
  annotations:
    policies.kyverno.io/title: Restrict StorageClass in ValidatingPolicy
    policies.kyverno.io/category: Other, Multi-Tenancy in vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: StorageClass
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: StorageClasses allow description of custom "classes" of storage offered by the cluster, based on quality-of-service levels, backup policies, or custom policies determined by the cluster administrators. For shared StorageClasses in a multi-tenancy environment, a reclaimPolicy of `Delete` should be used to ensure a PersistentVolume cannot be reused across Namespaces. This policy requires StorageClasses set a reclaimPolicy of `Delete`.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - storage.k8s.io
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - storageclasses
  validations:
    - expression: object.reclaimPolicy == 'Delete'
      message: StorageClass must define a reclaimPolicy of Delete.

```
