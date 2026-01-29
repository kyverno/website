---
title: 'Enforce ReadWriteOncePod in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - PersistentVolumeClaim
tags:
  - Sample in Vpol
version: 1.14.0
description: 'Some stateful workloads with multiple replicas only allow a single Pod to write to a given volume at a time. Beginning in Kubernetes 1.22 and enabled by default in 1.27, a new setting called ReadWriteOncePod, available for CSI volumes only, allows volumes to be writable from only a single Pod. For more information see the blog https://kubernetes.io/blog/2023/04/20/read-write-once-pod-access-mode-beta/. This policy enforces that the accessModes for a PersistentVolumeClaim be set to ReadWriteOncePod.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/enforce-readwriteonce-pod/enforce-readwriteonce-pod.yaml" target="-blank">/other-vpol/enforce-readwriteonce-pod/enforce-readwriteonce-pod.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: readwriteonce-pod
  annotations:
    policies.kyverno.io/title: Enforce ReadWriteOncePod in ValidatingPolicy
    policies.kyverno.io/category: Sample in Vpol
    policies.kyverno.io/subject: PersistentVolumeClaim
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: 1.27-1.28
    policies.kyverno.io/description: Some stateful workloads with multiple replicas only allow a single Pod to write to a given volume at a time. Beginning in Kubernetes 1.22 and enabled by default in 1.27, a new setting called ReadWriteOncePod, available for CSI volumes only, allows volumes to be writable from only a single Pod. For more information see the blog https://kubernetes.io/blog/2023/04/20/read-write-once-pod-access-mode-beta/. This policy enforces that the accessModes for a PersistentVolumeClaim be set to ReadWriteOncePod.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        resources:
          - persistentvolumeclaims
        operations:
          - CREATE
          - UPDATE
  validations:
    - expression: "'ReadWriteOncePod' in object.spec.accessModes"
      message: The accessMode must be set to ReadWriteOncePod.

```
