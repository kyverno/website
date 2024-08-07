---
title: "Require Limits and Requests in CEL expressions"
category: Best Practices, EKS Best Practices in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    As application workloads share cluster resources, it is important to limit resources requested and consumed by each Pod. It is recommended to require resource requests and limits per Pod, especially for memory and CPU. If a Namespace level request or limit is specified, defaults will automatically be applied to each Pod based on the LimitRange configuration. This policy validates that all containers have something specified for memory and CPU requests and memory limits.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices-cel/require-pod-requests-limits/require-pod-requests-limits.yaml" target="-blank">/best-practices-cel/require-pod-requests-limits/require-pod-requests-limits.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-requests-limits
  annotations:
    policies.kyverno.io/title: Require Limits and Requests in CEL expressions
    policies.kyverno.io/category: Best Practices, EKS Best Practices in CEL 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      As application workloads share cluster resources, it is important to limit resources
      requested and consumed by each Pod. It is recommended to require resource requests and
      limits per Pod, especially for memory and CPU. If a Namespace level request or limit is specified,
      defaults will automatically be applied to each Pod based on the LimitRange configuration.
      This policy validates that all containers have something specified for memory and CPU
      requests and memory limits.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: validate-resources
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
        expressions:
          - expression: >-
              object.spec.containers.all(container,
              has(container.resources) &&
              has(container.resources.requests) &&
              has(container.resources.requests.memory) &&
              has(container.resources.requests.cpu) &&
              has(container.resources.limits) &&
              has(container.resources.limits.memory))
            message: "CPU and memory resource requests and limits are required."


```
