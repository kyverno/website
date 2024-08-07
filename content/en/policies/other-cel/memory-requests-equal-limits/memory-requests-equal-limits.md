---
title: "Memory Requests Equal Limits in CEL expressions"
category: Sample in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    Pods which have memory limits equal to requests could be given a QoS class of Guaranteed if they also set CPU limits equal to requests. Guaranteed is the highest schedulable class.  This policy checks that all containers in a given Pod have memory requests equal to limits.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/memory-requests-equal-limits/memory-requests-equal-limits.yaml" target="-blank">/other-cel/memory-requests-equal-limits/memory-requests-equal-limits.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: memory-requests-equal-limits
  annotations:
    policies.kyverno.io/title: Memory Requests Equal Limits in CEL expressions
    policies.kyverno.io/category: Sample in CEL 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      Pods which have memory limits equal to requests could be given a QoS class of Guaranteed if
      they also set CPU limits equal to requests. Guaranteed is the highest schedulable class. 
      This policy checks that all containers in a given Pod have memory requests equal to limits.
spec:
  validationFailureAction: Audit
  background: false
  rules:
  - name: memory-requests-equal-limits
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
        variables:
          - name: containersWithResources
            expression: object.spec.containers.filter(container, has(container.resources))
        expressions:
        - expression: >-
            variables.containersWithResources.all(container, 
            !has(container.resources.requests) ||
            !has(container.resources.requests.memory) ||
            container.resources.requests.memory == container.resources.?limits.?memory.orValue('-1'))
          message: "resources.requests.memory must be equal to resources.limits.memory"


```
