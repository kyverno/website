---
title: 'Prepend Image Registry'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Other
version: 1.19.1
description: 'Prepends ''registry.io/'' to all container and initContainer images in Pods.'
createdAt: "2025-11-14T18:23:14.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/prepend-image-registry/prepend-image-registry.yaml" target="-blank">/other-mpol/prepend-image-registry/prepend-image-registry.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: prepend-registry
  annotations:
    policies.kyverno.io/title: Prepend Image Registry
    policies.kyverno.io/minversion: 1.19.1
    policies.kyverno.io/category: Other
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Prepends 'registry.io/' to all container and initContainer images in Pods.
spec:
  evaluation:
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
        expression: |
          Object{
            spec: Object.spec{
              containers: object.spec.containers.map(container,
                exceptions.allowedImages.exists(image, image == container.image) ? container :
                Object.spec.containers{
                  name: container.name,
                  image: container.image.startsWith("registry.io/") ? container.image : "registry.io/" + container.image
                }
              ),
              initContainers: has(object.spec.initContainers) ?
                object.spec.initContainers.map(container,
                  exceptions.allowedImages.exists(image, image == container.image) ? container :
                  Object.spec.initContainers{
                    name: container.name,
                    image: container.image.startsWith("registry.io/") ? container.image : "registry.io/" + container.image
                  }
                ) : []
            }
          }

```
