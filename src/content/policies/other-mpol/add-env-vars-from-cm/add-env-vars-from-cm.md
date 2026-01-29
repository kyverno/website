---
title: 'Add Environment Variables from ConfigMap'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Other
version: 1.15.0
description: 'Instead of defining a common set of environment variables multiple times either in manifests or separate policies, Pods can reference entire collections stored in a ConfigMap. This policy mutates all initContainers (if present) and containers in a Pod with environment variables defined in a ConfigMap named `nsenvvars` that must exist in the destination Namespace.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/add-env-vars-from-cm/add-env-vars-from-cm.yaml" target="-blank">/other-mpol/add-env-vars-from-cm/add-env-vars-from-cm.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-env-vars-from-cm
  annotations:
    policies.kyverno.io/title: Add Environment Variables from ConfigMap
    policies.kyverno.io/minversion: 1.15.0
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/category: Other
    policies.kyverno.io/description: Instead of defining a common set of environment variables multiple times either in manifests or separate policies, Pods can reference entire collections stored in a ConfigMap. This policy mutates all initContainers (if present) and containers in a Pod with environment variables defined in a ConfigMap named `nsenvvars` that must exist in the destination Namespace.
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
          object.kind == "Pod" ?
          (
            (has(object.spec.initContainers) ?
              object.spec.initContainers.map(container, 
                object.spec.initContainers.indexOf(container)
              ).map(idx,
                JSONPatch{
                  op: "add",
                  path: "/spec/initContainers/" + string(idx) + "/envFrom",
                  value: [{"configMapRef": {"name": "nsenvvars"}}]
                }
              ) : []
            ) +
            object.spec.containers.map(container,
              object.spec.containers.indexOf(container)
            ).map(idx,
              JSONPatch{
                op: "add",
                path: "/spec/containers/" + string(idx) + "/envFrom",
                value: [{"configMapRef": {"name": "nsenvvars"}}]
              }
            )
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind in ["Deployment", "DaemonSet", "StatefulSet"] ?
          (
            (has(object.spec.template.spec.initContainers) ?
              object.spec.template.spec.initContainers.map(container, 
                object.spec.template.spec.initContainers.indexOf(container)
              ).map(idx,
                JSONPatch{
                  op: "add",
                  path: "/spec/template/spec/initContainers/" + string(idx) + "/envFrom",
                  value: [{"configMapRef": {"name": "nsenvvars"}}]
                }
              ) : []
            ) +
            object.spec.template.spec.containers.map(container,
              object.spec.template.spec.containers.indexOf(container)
            ).map(idx,
              JSONPatch{
                op: "add",
                path: "/spec/template/spec/containers/" + string(idx) + "/envFrom",
                value: [{"configMapRef": {"name": "nsenvvars"}}]
              }
            )
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "Job" ?
          (
            (has(object.spec.template.spec.initContainers) ?
              object.spec.template.spec.initContainers.map(container, 
                object.spec.template.spec.initContainers.indexOf(container)
              ).map(idx,
                JSONPatch{
                  op: "add",
                  path: "/spec/template/spec/initContainers/" + string(idx) + "/envFrom",
                  value: [{"configMapRef": {"name": "nsenvvars"}}]
                }
              ) : []
            ) +
            object.spec.template.spec.containers.map(container,
              object.spec.template.spec.containers.indexOf(container)
            ).map(idx,
              JSONPatch{
                op: "add",
                path: "/spec/template/spec/containers/" + string(idx) + "/envFrom",
                value: [{"configMapRef": {"name": "nsenvvars"}}]
              }
            )
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "CronJob" ?
          (
            (has(object.spec.jobTemplate.spec.template.spec.initContainers) ?
              object.spec.jobTemplate.spec.template.spec.initContainers.map(container, 
                object.spec.jobTemplate.spec.template.spec.initContainers.indexOf(container)
              ).map(idx,
                JSONPatch{
                  op: "add",
                  path: "/spec/jobTemplate/spec/template/spec/initContainers/" + string(idx) + "/envFrom",
                  value: [{"configMapRef": {"name": "nsenvvars"}}]
                }
              ) : []
            ) +
            object.spec.jobTemplate.spec.template.spec.containers.map(container,
              object.spec.jobTemplate.spec.template.spec.containers.indexOf(container)
            ).map(idx,
              JSONPatch{
                op: "add",
                path: "/spec/jobTemplate/spec/template/spec/containers/" + string(idx) + "/envFrom",
                value: [{"configMapRef": {"name": "nsenvvars"}}]
              }
            )
          ) : []

```
