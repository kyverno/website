---
title: 'Add ndots'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.6.0
description: 'The ndots value controls where DNS lookups are first performed in a cluster and needs to be set to a lower value than the default of 5 in some cases. This policy mutates all Pods to set the ndots option to a value of 1, replacing any existing value.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/add-ndots/add-ndots.yaml" target="-blank">/other-mpol/add-ndots/add-ndots.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-ndots
  annotations:
    policies.kyverno.io/title: Add ndots
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: The ndots value controls where DNS lookups are first performed in a cluster and needs to be set to a lower value than the default of 5 in some cases. This policy mutates all Pods to set the ndots option to a value of 1, replacing any existing value.
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
          object.kind == "Pod" && 
          has(object.spec.dnsConfig) && 
          has(object.spec.dnsConfig.options) && 
          object.spec.dnsConfig.options.exists(opt, opt.name == "ndots") ?
          [JSONPatch{
            op: "remove",
            path: "/spec/dnsConfig/options/" + string(object.spec.dnsConfig.options.map(opt, opt.name).indexOf("ndots"))
          }] : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "Pod" ?
          (has(object.spec.dnsConfig) && has(object.spec.dnsConfig.options) ?
            [JSONPatch{
              op: "add",
              path: "/spec/dnsConfig/options/-",
              value: {"name": "ndots", "value": "1"}
            }] :
            (has(object.spec.dnsConfig) ?
              [JSONPatch{
                op: "add",
                path: "/spec/dnsConfig/options",
                value: [{"name": "ndots", "value": "1"}]
              }] :
              [JSONPatch{
                op: "add",
                path: "/spec/dnsConfig",
                value: {"options": [{"name": "ndots", "value": "1"}]}
              }]
            )
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind in ["Deployment", "DaemonSet", "StatefulSet"] && 
          has(object.spec.template.spec.dnsConfig) && 
          has(object.spec.template.spec.dnsConfig.options) && 
          object.spec.template.spec.dnsConfig.options.exists(opt, opt.name == "ndots") ?
          [JSONPatch{
            op: "remove",
            path: "/spec/template/spec/dnsConfig/options/" + string(object.spec.template.spec.dnsConfig.options.map(opt, opt.name).indexOf("ndots"))
          }] : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind in ["Deployment", "DaemonSet", "StatefulSet"] ?
          (has(object.spec.template.spec.dnsConfig) && has(object.spec.template.spec.dnsConfig.options) ?
            [JSONPatch{
              op: "add",
              path: "/spec/template/spec/dnsConfig/options/-",
              value: {"name": "ndots", "value": "1"}
            }] :
            (has(object.spec.template.spec.dnsConfig) ?
              [JSONPatch{
                op: "add",
                path: "/spec/template/spec/dnsConfig/options",
                value: [{"name": "ndots", "value": "1"}]
              }] :
              [JSONPatch{
                op: "add",
                path: "/spec/template/spec/dnsConfig",
                value: {"options": [{"name": "ndots", "value": "1"}]}
              }]
            )
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "Job" && 
          has(object.spec.template.spec.dnsConfig) && 
          has(object.spec.template.spec.dnsConfig.options) && 
          object.spec.template.spec.dnsConfig.options.exists(opt, opt.name == "ndots") ?
          [JSONPatch{
            op: "remove",
            path: "/spec/template/spec/dnsConfig/options/" + string(object.spec.template.spec.dnsConfig.options.map(opt, opt.name).indexOf("ndots"))
          }] : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "Job" ?
          (has(object.spec.template.spec.dnsConfig) && has(object.spec.template.spec.dnsConfig.options) ?
            [JSONPatch{
              op: "add",
              path: "/spec/template/spec/dnsConfig/options/-",
              value: {"name": "ndots", "value": "1"}
            }] :
            (has(object.spec.template.spec.dnsConfig) ?
              [JSONPatch{
                op: "add",
                path: "/spec/template/spec/dnsConfig/options",
                value: [{"name": "ndots", "value": "1"}]
              }] :
              [JSONPatch{
                op: "add",
                path: "/spec/template/spec/dnsConfig",
                value: {"options": [{"name": "ndots", "value": "1"}]}
              }]
            )
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "CronJob" && 
          has(object.spec.jobTemplate.spec.template.spec.dnsConfig) && 
          has(object.spec.jobTemplate.spec.template.spec.dnsConfig.options) && 
          object.spec.jobTemplate.spec.template.spec.dnsConfig.options.exists(opt, opt.name == "ndots") ?
          [JSONPatch{
            op: "remove",
            path: "/spec/jobTemplate/spec/template/spec/dnsConfig/options/" + string(object.spec.jobTemplate.spec.template.spec.dnsConfig.options.map(opt, opt.name).indexOf("ndots"))
          }] : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "CronJob" ?
          (has(object.spec.jobTemplate.spec.template.spec.dnsConfig) && has(object.spec.jobTemplate.spec.template.spec.dnsConfig.options) ?
            [JSONPatch{
              op: "add",
              path: "/spec/jobTemplate/spec/template/spec/dnsConfig/options/-",
              value: {"name": "ndots", "value": "1"}
            }] :
            (has(object.spec.jobTemplate.spec.template.spec.dnsConfig) ?
              [JSONPatch{
                op: "add",
                path: "/spec/jobTemplate/spec/template/spec/dnsConfig/options",
                value: [{"name": "ndots", "value": "1"}]
              }] :
              [JSONPatch{
                op: "add",
                path: "/spec/jobTemplate/spec/template/spec/dnsConfig",
                value: {"options": [{"name": "ndots", "value": "1"}]}
              }]
            )
          ) : []

```
