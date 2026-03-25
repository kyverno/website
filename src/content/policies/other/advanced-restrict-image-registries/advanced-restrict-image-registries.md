---
title: 'Advanced Restrict Image Registries'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Other
version: 1.6.0
description: 'In instances where a ClusterPolicy defines all the approved image registries is insufficient, more granular control may be needed to set permitted registries, especially in multi-tenant use cases where some registries may be based on the Namespace. This policy shows an advanced version of the Restrict Image Registries policy which gets a global approved registry from a ConfigMap and, based upon an annotation at the Namespace level, gets the registry approved for that Namespace.'
createdAt: "2023-04-04T23:03:22.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/advanced-restrict-image-registries/advanced-restrict-image-registries.yaml" target="-blank">/other/advanced-restrict-image-registries/advanced-restrict-image-registries.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: advanced-restrict-image-registries
  annotations:
    policies.kyverno.io/title: Advanced Restrict Image Registries
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: In instances where a ClusterPolicy defines all the approved image registries is insufficient, more granular control may be needed to set permitted registries, especially in multi-tenant use cases where some registries may be based on the Namespace. This policy shows an advanced version of the Restrict Image Registries policy which gets a global approved registry from a ConfigMap and, based upon an annotation at the Namespace level, gets the registry approved for that Namespace.
spec:
  validationFailureAction: Audit
  background: false
  rules:
    - name: validate-corp-registries
      match:
        any:
          - resources:
              kinds:
                - Pod
      context:
        - name: nsregistries
          apiCall:
            urlPath: /api/v1/namespaces/{{request.namespace}}
            jmesPath: metadata.annotations."corp.com/allowed-registries" || ''
        - name: clusterregistries
          configMap:
            name: clusterregistries
            namespace: default
      preconditions:
        any:
          - key: "{{request.operation || 'BACKGROUND'}}"
            operator: AnyIn
            value:
              - CREATE
              - UPDATE
      validate:
        message: This Pod names an image that is not from an approved registry.
        foreach:
          - list: request.object.spec.[initContainers, ephemeralContainers, containers][]
            deny:
              conditions:
                all:
                  - key: "{{element.image}}"
                    operator: NotEquals
                    value: "{{nsregistries}}"
                  - key: "{{element.image}}"
                    operator: NotEquals
                    value: "{{clusterregistries.data.registries}}"

```
