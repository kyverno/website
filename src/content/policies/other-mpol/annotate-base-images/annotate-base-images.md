---
title: 'Annotate Base Images'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Other
version: 1.7.0
description: 'A base image used to construct a container image is not accessible by any Kubernetes component and not a field in a Pod spec as it must be fetched from a registry. Having this information available in the resource referencing the containers helps to provide a clearer understanding of its contents. This policy adds an annotation to a Pod or its controllers with the base image used for each container if present in an OCI annotation.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/annotate-base-images/annotate-base-images.yaml" target="-blank">/other-mpol/annotate-base-images/annotate-base-images.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: annotate-base-images
  annotations:
    policies.kyverno.io/title: Annotate Base Images
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    pod-policies.kyverno.io/autogen-controllers: none
    policies.kyverno.io/minversion: 1.7.0
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: A base image used to construct a container image is not accessible by any Kubernetes component and not a field in a Pod spec as it must be fetched from a registry. Having this information available in the resource referencing the containers helps to provide a clearer understanding of its contents. This policy adds an annotation to a Pod or its controllers with the base image used for each container if present in an OCI annotation.
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
  variables:
    - name: imageMetadata
      expression: object.spec.containers.map(c, image.GetMetadata(c.image))
  mutations:
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          !has(object.metadata.annotations) ?
          [
            JSONPatch{
              op: "add",
              path: "/metadata/annotations",
              value: {}
            }
          ] : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          variables.imageMetadata.map(img, variables.imageMetadata.indexOf(img)).map(idx,
            has(variables.imageMetadata[idx].manifest) && 
            has(variables.imageMetadata[idx].manifest.annotations) &&
            "org.opencontainers.image.base.name" in variables.imageMetadata[idx].manifest.annotations ?
            JSONPatch{
              op: "add",
              path: "/metadata/annotations/" + jsonpatch.escapeKey("kyverno.io/baseimages" + string(idx)),
              value: variables.imageMetadata[idx].manifest.annotations["org.opencontainers.image.base.name"]
            } : null
          ).filter(p, p != null)

```
