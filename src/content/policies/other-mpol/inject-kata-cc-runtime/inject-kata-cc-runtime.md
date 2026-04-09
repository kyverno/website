---
title: 'Inject Kata Containers Runtime for Confidential Computing'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Confidential Computing
description: 'Automatically injects the runtimeClassName kata-cc to pods that have the label coco=enabled for running workloads in confidential containers using Kata Containers. Pods without the coco=enabled label are not modified.'
createdAt: "2026-04-09T07:23:52.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/inject-kata-cc-runtime/inject-kata-cc-runtime.yaml" target="-blank">/other-mpol/inject-kata-cc-runtime/inject-kata-cc-runtime.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  annotations:
    policies.kyverno.io/category: Confidential Computing
    policies.kyverno.io/description: Automatically injects the runtimeClassName kata-cc to pods that have the label coco=enabled for running workloads in confidential containers using Kata Containers. Pods without the coco=enabled label are not modified.
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/title: Inject Kata Containers Runtime for Confidential Computing
  name: inject-kata-cc-runtime
spec:
  autogen:
    podControllers:
      controllers:
        - deployments
        - statefulsets
        - daemonsets
        - replicasets
        - jobs
        - cronjobs
  matchConditions:
    - expression: has(object.metadata.labels) && 'coco' in object.metadata.labels && object.metadata.labels['coco'] == 'enabled'
      name: has-coco-enabled-label
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
    - applyConfiguration:
        expression: |
          Object{
            spec: Object.spec{
              runtimeClassName: "kata-cc"
            }
          }
      patchType: ApplyConfiguration

```
