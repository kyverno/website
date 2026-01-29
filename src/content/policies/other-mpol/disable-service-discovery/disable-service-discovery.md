---
title: 'Disable Service Discovery'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Other
  - EKS Best Practices
version: 1.15.0
description: 'Not all Pods require communicating with other Pods or resolving in-cluster Services. For those, disabling service discovery can increase security as the Pods are limited to what they can see. This policy mutates Pods to set dnsPolicy to `Default` and enableServiceLinks to `false`.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/disable-service-discovery/disable-service-discovery.yaml" target="-blank">/other-mpol/disable-service-discovery/disable-service-discovery.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: disable-service-discovery
  annotations:
    policies.kyverno.io/title: Disable Service Discovery
    policies.kyverno.io/category: Other, EKS Best Practices
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.15.0
    kyverno.io/kubernetes-version: "1.24"
    policies.kyverno.io/minversion: 1.15.0
    policies.kyverno.io/description: Not all Pods require communicating with other Pods or resolving in-cluster Services. For those, disabling service discovery can increase security as the Pods are limited to what they can see. This policy mutates Pods to set dnsPolicy to `Default` and enableServiceLinks to `false`.
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
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            spec: Object.spec{
              dnsPolicy: "Default",
              enableServiceLinks: false
            }
          }
  reinvocationPolicy: Never

```
