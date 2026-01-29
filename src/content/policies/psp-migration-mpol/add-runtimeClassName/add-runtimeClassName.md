---
title: 'Add runtimeClassName'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - PSP Migration
description: 'In the earlier Pod Security Policy controller, it was possible to configure a policy to add a Pod''s runtimeClassName. This was beneficial in that various container runtimes could be specified according to a policy. This Kyverno policy mutates Pods to add a runtimeClassName of `prodclass`.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/psp-migration-mpol/add-runtimeClassName/add-runtimeClassName.yaml" target="-blank">/psp-migration-mpol/add-runtimeClassName/add-runtimeClassName.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-runtimeclassname
  annotations:
    policies.kyverno.io/title: Add runtimeClassName
    policies.kyverno.io/category: PSP Migration
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.10.0
    kyverno.io/kubernetes-version: "1.24"
    pod-policies.kyverno.io/autogen-controllers: none
    policies.kyverno.io/description: In the earlier Pod Security Policy controller, it was possible to configure a policy to add a Pod's runtimeClassName. This was beneficial in that various container runtimes could be specified according to a policy. This Kyverno policy mutates Pods to add a runtimeClassName of `prodclass`.
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
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            spec: Object.spec{
              runtimeClassName: "prodclass"
            }
          }

```
