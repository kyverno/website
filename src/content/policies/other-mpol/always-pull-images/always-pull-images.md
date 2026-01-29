---
title: 'Always Pull Images'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.15.0
description: 'By default, images that have already been pulled can be accessed by other Pods without re-pulling them if the name and tag are known. In multi-tenant scenarios, this may be undesirable. This policy mutates all incoming Pods to set their imagePullPolicy to Always. An alternative to the Kubernetes admission controller AlwaysPullImages.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/always-pull-images/always-pull-images.yaml" target="-blank">/other-mpol/always-pull-images/always-pull-images.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: always-pull-images
  annotations:
    policies.kyverno.io/title: Always Pull Images
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.15.0
    policies.kyverno.io/description: By default, images that have already been pulled can be accessed by other Pods without re-pulling them if the name and tag are known. In multi-tenant scenarios, this may be undesirable. This policy mutates all incoming Pods to set their imagePullPolicy to Always. An alternative to the Kubernetes admission controller AlwaysPullImages.
spec:
  autogen:
    podControllers:
      controllers:
        - deployments
        - daemonsets
        - statefulsets
        - jobs
        - cronjobs
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
              containers: object.spec.containers.map(container, 
                Object.spec.containers{
                  name: container.name,
                  imagePullPolicy: "Always"
                }
              )
            }
          }

```
