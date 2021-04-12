---
title: "Add Volume"
linkTitle: "Add Volume"
weight: 16
repo: "https://github.com/kyverno/policies/blob/main/other/add_volume_deployment.yaml"
description: >
    Sample policy to add a volume and volumeMount. 
category: Sample
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
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/add_volume_deployment.yaml" target="-blank">/other/add_volume_deployment.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-volume
  annotations:
    policies.kyverno.io/title: Add Volume to Deployment
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Sample policy to add a volume and volumeMount to a Deployment resource. This checks for the presence of an annotation called
      "vault.k8s.corp.net/inject=enabled" and adds an emptyDir volume using the memory medium.
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
