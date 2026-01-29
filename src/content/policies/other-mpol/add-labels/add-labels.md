---
title: 'Add Labels'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Label
tags:
  - Sample
version: 1.6.0
description: 'Labels are used as an important source of metadata describing objects in various ways or triggering other functionality. Labels are also a very basic concept and should be used throughout Kubernetes. This policy performs a simple mutation which adds a label `foo=bar` to Pods, Services, ConfigMaps, and Secrets.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/add-labels/add-labels.yaml" target="-blank">/other-mpol/add-labels/add-labels.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-labels
  annotations:
    policies.kyverno.io/title: Add Labels
    policies.kyverno.io/category: Sample
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Label
    policies.kyverno.io/description: Labels are used as an important source of metadata describing objects in various ways or triggering other functionality. Labels are also a very basic concept and should be used throughout Kubernetes. This policy performs a simple mutation which adds a label `foo=bar` to Pods, Services, ConfigMaps, and Secrets.
spec:
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
          - services
          - configmaps
          - secrets
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                foo: "bar"
              }
            }
          }

```
