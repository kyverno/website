---
type: "docs"
title: Add Volume
linkTitle: Add Volume
weight: 16
description: >
    Sample policy to add a volume and volumeMount. 
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/add_volume_deployment.yaml" target="-blank">/other/add_volume_deployment.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-volume
  annotations:
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Sample policy to add a volume and volumeMount. 
spec:
  background: false
  rules:
  - name: add-volume
    match:
      resources:
        kinds:
        - Deployment
    preconditions:
    - key: "{{request.object.spec.template.metadata.annotations.\"vault.k8s.corp.net/inject\"}}"
      operator: Equals
      value: "enabled"
    mutate:
      patchesJson6902: |-
        - op: add
          path: /spec/template/spec/volumes
          value: [{"name": "vault-secret","emptyDir": {"medium": "Memory"}}]
        - op: add
          path: /spec/template/spec/containers/0/volumeMounts
          value: [{"mountPath": "/secret","name": "vault-secret"}]
```
