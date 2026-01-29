---
title: 'Add Image as Environment Variable'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Other
description: 'The Kubernetes downward API only has the ability to express so many options as environment variables. The image consumed in a Pod is commonly needed to make the application aware of some logic it must take. This policy takes the value of the `image` field and adds it as an environment variable to Pods.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/add-image-as-env-var/add-image-as-env-var.yaml" target="-blank">/other-mpol/add-image-as-env-var/add-image-as-env-var.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-image-as-env-var
  annotations:
    policies.kyverno.io/title: Add Image as Environment Variable
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: The Kubernetes downward API only has the ability to express so many options as environment variables. The image consumed in a Pod is commonly needed to make the application aware of some logic it must take. This policy takes the value of the `image` field and adds it as an environment variable to Pods.
spec:
  autogen:
    podControllers:
      controllers: []
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
    - patchType: JSONPatch
      jsonPatch:
        expression: |-
          object.spec.containers.map(c, 
            !has(c.env) ? 
            JSONPatch{
              op: "add",
              path: "/spec/containers/" + string(object.spec.containers.indexOf(c)) + "/env",
              value: [{"name": "K8S_IMAGE", "value": string(c.image)}]
            } :
            JSONPatch{
              op: "add",
              path: "/spec/containers/" + string(object.spec.containers.indexOf(c)) + "/env/-",
              value: {"name": "K8S_IMAGE", "value": string(c.image)}
            }
          )

```
