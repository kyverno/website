---
title: 'add-default-resources'
category: mutate
severity: medium
type: MutatingPolicy
subjects: []
tags: []
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/add-default-resources/add-default-resources.yaml" target="-blank">/other-mpol/add-default-resources/add-default-resources.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-default-resources
spec:
  autogen:
    podControllers:
      controllers:
        - deployments
        - cronjobs
        - jobs
        - statefulsets
        - daemonsets
  evaluation:
    mutateExisting:
      enabled: false
    admission:
      enabled: true
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
        expression: |-
          Object{
            spec: Object.spec{
              containers: object.spec.containers.map(c,
                Object.spec.containers{
                  name: c.name,
                  resources: Object.spec.containers.resources{
                    requests: Object.spec.containers.resources.requests{
                      cpu: has(c.resources) && has(c.resources.requests) && has(c.resources.requests.cpu)
                           ? c.resources.requests.cpu
                           : "100m",
                      memory: has(c.resources) && has(c.resources.requests) && has(c.resources.requests.memory)
                            ? c.resources.requests.memory
                            : "100Mi"
                    }
                  }
                }
              )
            }
          }

```
