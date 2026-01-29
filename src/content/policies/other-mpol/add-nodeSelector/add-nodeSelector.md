---
title: 'Add nodeSelector'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.15.0
description: 'The nodeSelector field uses labels to select the node on which a Pod can be scheduled. This can be useful when Pods have specific needs that only certain nodes in a cluster can provide. This policy adds the nodeSelector field to a Pod spec and configures it with labels `foo` and `color`.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/add-nodeSelector/add-nodeSelector.yaml" target="-blank">/other-mpol/add-nodeSelector/add-nodeSelector.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-nodeselector
  annotations:
    policies.kyverno.io/title: Add nodeSelector
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.15.0
    policies.kyverno.io/description: The nodeSelector field uses labels to select the node on which a Pod can be scheduled. This can be useful when Pods have specific needs that only certain nodes in a cluster can provide. This policy adds the nodeSelector field to a Pod spec and configures it with labels `foo` and `color`.
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
      - apiGroups:
          - apps
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - deployments
          - daemonsets
          - statefulsets
      - apiGroups:
          - batch
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - jobs
          - cronjobs
  mutations:
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          !has(object.spec.nodeSelector) ?
          [
            JSONPatch{
              op: "add",
              path: "/spec/nodeSelector",
              value: dyn({"foo": "bar", "color": "orange"})
            }
          ] : 
          [
            JSONPatch{
              op: "add",
              path: "/spec/nodeSelector/foo",
              value: "bar"
            },
            JSONPatch{
              op: "add",
              path: "/spec/nodeSelector/color",
              value: "orange"
            }
          ]
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          has(object.spec.template) ?
          (!has(object.spec.template.spec.nodeSelector) ?
            [
              JSONPatch{
                op: "add",
                path: "/spec/template/spec/nodeSelector",
                value: dyn({"foo": "bar", "color": "orange"})
              }
            ] : 
            [
              JSONPatch{
                op: "add",
                path: "/spec/template/spec/nodeSelector/foo",
                value: "bar"
              },
              JSONPatch{
                op: "add",
                path: "/spec/template/spec/nodeSelector/color",
                value: "orange"
              }
            ]
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          has(object.spec.jobTemplate) ?
          (!has(object.spec.jobTemplate.spec.template.spec.nodeSelector) ?
            [
              JSONPatch{
                op: "add",
                path: "/spec/jobTemplate/spec/template/spec/nodeSelector",
                value: dyn({"foo": "bar", "color": "orange"})
              }
            ] : 
            [
              JSONPatch{
                op: "add",
                path: "/spec/jobTemplate/spec/template/spec/nodeSelector/foo",
                value: "bar"
              },
              JSONPatch{
                op: "add",
                path: "/spec/jobTemplate/spec/template/spec/nodeSelector/color",
                value: "orange"
              }
            ]
          ) : []

```
