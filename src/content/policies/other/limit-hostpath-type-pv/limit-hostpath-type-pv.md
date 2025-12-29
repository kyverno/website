---
title: 'Limit hostPath PersistentVolumes to Specific Directories'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - PersistentVolume
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/limit-hostpath-type-pv/limit-hostpath-type-pv.yaml" target="-blank">/other/limit-hostpath-type-pv/limit-hostpath-type-pv.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: limit-hostpath-type-pv
  annotations:
    policies.kyverno.io/title: Limit hostPath PersistentVolumes to Specific Directories
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: PersistentVolume
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: hostPath persistentvolumes consume the underlying node's file system. If hostPath volumes are not to be universally disabled, they should be restricted to only certain host paths so as not to allow access to sensitive information. This policy ensures the only directory that can be mounted as a hostPath volume is /data.
spec:
  background: false
  validationFailureAction: Audit
  rules:
    - name: limit-hostpath-type-pv-to-slash-data
      match:
        any:
          - resources:
              kinds:
                - PersistentVolume
      preconditions:
        all:
          - key: "{{request.operation || 'BACKGROUND'}}"
            operator: AnyIn
            value:
              - CREATE
              - UPDATE
      validate:
        message: hostPath type persistent volumes are confined to /data.
        pattern:
          spec:
            '=(hostPath)':
              path: /data*
```
