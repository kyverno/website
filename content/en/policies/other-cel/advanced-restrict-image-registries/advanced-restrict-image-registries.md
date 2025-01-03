---
title: "Advanced Restrict Image Registries in CEL expressions"
category: Other in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    In instances where a ClusterPolicy defines all the approved image registries is insufficient, more granular control may be needed to set permitted registries, especially in multi-tenant use cases where some registries may be based on the Namespace. This policy shows an advanced version of the Restrict Image Registries policy which gets a global approved registry from a ConfigMap and, based upon an annotation at the Namespace level, gets the registry approved for that Namespace.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/advanced-restrict-image-registries/advanced-restrict-image-registries.yaml" target="-blank">/other-cel/advanced-restrict-image-registries/advanced-restrict-image-registries.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: advanced-restrict-image-registries
  annotations:
    policies.kyverno.io/title: Advanced Restrict Image Registries in CEL expressions
    policies.kyverno.io/category: Other in CEL 
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      In instances where a ClusterPolicy defines all the approved image registries
      is insufficient, more granular control may be needed to set permitted registries,
      especially in multi-tenant use cases where some registries may be based on
      the Namespace. This policy shows an advanced version of the Restrict Image Registries
      policy which gets a global approved registry from a ConfigMap and, based upon an
      annotation at the Namespace level, gets the registry approved for that Namespace.
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
            operations:
            - CREATE
            - UPDATE
      validate:
        cel:
          paramKind: 
            apiVersion: v1
            kind: ConfigMap
          paramRef: 
            name: clusterregistries
            namespace: default
            parameterNotFoundAction: Deny
          variables:
            - name: allContainers
              expression: "object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])"
            - name: nsregistries
              expression: >-
                namespaceObject.metadata.?annotations[?'corp.com/allowed-registries'].orValue(' ')
            - name: clusterregistries
              expression: "params.data[?'registries'].orValue(' ')"
          expressions:
            - expression: "variables.allContainers.all(container, container.image.startsWith(variables.nsregistries) || container.image.startsWith(variables.clusterregistries))"
              message: This Pod names an image that is not from an approved registry.


```
