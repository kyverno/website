---
title: 'Add Pod Proxies'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.6.0
description: 'In restricted environments, Pods may not be allowed to egress directly to all destinations and some overrides to specific addresses may need to go through a corporate proxy. This policy adds proxy information to Pods in the form of environment variables. It will add the `env` array if not present. If any Pods have any of these env vars, they will be overwritten with the value(s) in this policy.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/add-pod-proxies/add-pod-proxies.yaml" target="-blank">/other-mpol/add-pod-proxies/add-pod-proxies.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-pod-proxies
  annotations:
    policies.kyverno.io/title: Add Pod Proxies
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/category: Sample
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: In restricted environments, Pods may not be allowed to egress directly to all destinations and some overrides to specific addresses may need to go through a corporate proxy. This policy adds proxy information to Pods in the form of environment variables. It will add the `env` array if not present. If any Pods have any of these env vars, they will be overwritten with the value(s) in this policy.
    kyverno.io/kyverno-version: 1.15.0
    kyverno.io/kubernetes-version: "1.21"
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
          object.spec.containers.map(container,
            object.spec.containers.indexOf(container)
          ).map(idx,
            JSONPatch{
              op: has(object.spec.containers[idx].env) ? "replace" : "add",
              path: "/spec/containers/" + string(idx) + "/env",
              value: [
                {"name": "HTTP_PROXY", "value": "http://proxy.corp.domain:8080"},
                {"name": "HTTPS_PROXY", "value": "https://secureproxy.corp.domain:8080"},
                {"name": "NO_PROXY", "value": "localhost,*.example.com"}
              ] + (has(object.spec.containers[idx].env) ?
                object.spec.containers[idx].env.filter(e, 
                  e.name != "HTTP_PROXY" && 
                  e.name != "HTTPS_PROXY" && 
                  e.name != "NO_PROXY"
                ) :
                []
              )
            }
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind in ["Deployment", "DaemonSet", "StatefulSet"] ?
          object.spec.template.spec.containers.map(container,
            object.spec.template.spec.containers.indexOf(container)
          ).map(idx,
            JSONPatch{
              op: has(object.spec.template.spec.containers[idx].env) ? "replace" : "add",
              path: "/spec/template/spec/containers/" + string(idx) + "/env",
              value: [
                {"name": "HTTP_PROXY", "value": "http://proxy.corp.domain:8080"},
                {"name": "HTTPS_PROXY", "value": "https://secureproxy.corp.domain:8080"},
                {"name": "NO_PROXY", "value": "localhost,*.example.com"}
              ] + (has(object.spec.template.spec.containers[idx].env) ?
                object.spec.template.spec.containers[idx].env.filter(e, 
                  e.name != "HTTP_PROXY" && 
                  e.name != "HTTPS_PROXY" && 
                  e.name != "NO_PROXY"
                ) :
                []
              )
            }
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "Job" ?
          object.spec.template.spec.containers.map(container,
            object.spec.template.spec.containers.indexOf(container)
          ).map(idx,
            JSONPatch{
              op: has(object.spec.template.spec.containers[idx].env) ? "replace" : "add",
              path: "/spec/template/spec/containers/" + string(idx) + "/env",
              value: [
                {"name": "HTTP_PROXY", "value": "http://proxy.corp.domain:8080"},
                {"name": "HTTPS_PROXY", "value": "https://secureproxy.corp.domain:8080"},
                {"name": "NO_PROXY", "value": "localhost,*.example.com"}
              ] + (has(object.spec.template.spec.containers[idx].env) ?
                object.spec.template.spec.containers[idx].env.filter(e, 
                  e.name != "HTTP_PROXY" && 
                  e.name != "HTTPS_PROXY" && 
                  e.name != "NO_PROXY"
                ) :
                []
              )
            }
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "CronJob" ?
          object.spec.jobTemplate.spec.template.spec.containers.map(container,
            object.spec.jobTemplate.spec.template.spec.containers.indexOf(container)
          ).map(idx,
            JSONPatch{
              op: has(object.spec.jobTemplate.spec.template.spec.containers[idx].env) ? "replace" : "add",
              path: "/spec/jobTemplate/spec/template/spec/containers/" + string(idx) + "/env",
              value: [
                {"name": "HTTP_PROXY", "value": "http://proxy.corp.domain:8080"},
                {"name": "HTTPS_PROXY", "value": "https://secureproxy.corp.domain:8080"},
                {"name": "NO_PROXY", "value": "localhost,*.example.com"}
              ] + (has(object.spec.jobTemplate.spec.template.spec.containers[idx].env) ?
                object.spec.jobTemplate.spec.template.spec.containers[idx].env.filter(e, 
                  e.name != "HTTP_PROXY" && 
                  e.name != "HTTPS_PROXY" && 
                  e.name != "NO_PROXY"
                ) :
                []
              )
            }
          ) : []

```
