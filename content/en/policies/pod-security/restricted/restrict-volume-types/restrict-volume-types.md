---
title: "Restrict Volume Types"
category: Pod Security Standards (Restricted)
version: 1.6.0
subject: Pod,Volume
policyType: "validate"
description: >
    In addition to restricting HostPath volumes, the restricted pod security profile limits usage of non-core volume types to those defined through PersistentVolumes. This policy blocks any other type of volume other than those in the allow list.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/restricted/restrict-volume-types/restrict-volume-types.yaml" target="-blank">/pod-security/restricted/restrict-volume-types/restrict-volume-types.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-volume-types
  annotations:
    policies.kyverno.io/title: Restrict Volume Types
    policies.kyverno.io/category: Pod Security Standards (Restricted)
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod,Volume
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/description: >-
      In addition to restricting HostPath volumes, the restricted pod security profile
      limits usage of non-core volume types to those defined through PersistentVolumes.
      This policy blocks any other type of volume other than those in the allow list.
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: restricted-volumes
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: >-
          Only the following types of volumes may be used: configMap, csi, downwardAPI,
          emptyDir, ephemeral, persistentVolumeClaim, projected, and secret.
        deny:
          conditions:
            all:
            - key: "{{ request.object.spec.volumes[].keys(@)[] || '' }}"
              operator: AnyNotIn
              value:
              - name
              - configMap
              - csi
              - downwardAPI
              - emptyDir
              - ephemeral
              - persistentVolumeClaim
              - projected
              - secret
              - ''
```
