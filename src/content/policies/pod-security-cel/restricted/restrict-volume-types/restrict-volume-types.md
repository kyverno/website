---
title: 'Restrict Volume Types in CEL'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
  - Volume
tags: []
version: 1.11.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-cel/restricted/restrict-volume-types/restrict-volume-types.yaml" target="-blank">/pod-security-cel/restricted/restrict-volume-types/restrict-volume-types.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-volume-types
  annotations:
    policies.kyverno.io/title: Restrict Volume Types in CEL
    policies.kyverno.io/category: Pod Security Standards (Restricted) in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod,Volume
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/description: In addition to restricting HostPath volumes, the restricted pod security profile limits usage of non-core volume types to those defined through PersistentVolumes. This policy blocks any other type of volume other than those in the allow list.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: restricted-volumes
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
            - expression: "!has(object.spec.volumes) || object.spec.volumes.all(vol, has(vol.configMap) || has(vol.csi) || has(vol.downwardAPI) || has(vol.emptyDir) || has(vol.ephemeral) || has(vol.persistentVolumeClaim) || has(vol.projected) || has(vol.secret))"
              message: "Only the following types of volumes may be used: configMap, csi, downwardAPI, emptyDir, ephemeral, persistentVolumeClaim, projected, and secret."

```
