---
title: "Require Limits and Requests"
category: Multi-Tenancy
version: 
subject: Pod
policyType: "validate"
description: >
    As application workloads share cluster resources, it is important to limit resources  requested and consumed by each Pod. It is recommended to require resource requests and limits per Pod, especially for memory and CPU. If a Namespace level request or limit is specified,  defaults will automatically be applied to each Pod based on the 'LimitRange' configuration. This policy validates that all containers have something specified for memory and cpu requests and memory limits.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/require_pod_requests_limits/require_pod_requests_limits.yaml" target="-blank">/best-practices/require_pod_requests_limits/require_pod_requests_limits.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-requests-limits
  annotations:
    policies.kyverno.io/title: Require Limits and Requests 
    policies.kyverno.io/category: Multi-Tenancy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      As application workloads share cluster resources, it is important to limit resources 
      requested and consumed by each Pod. It is recommended to require resource requests and
      limits per Pod, especially for memory and CPU. If a Namespace level request or limit is specified, 
      defaults will automatically be applied to each Pod based on the 'LimitRange' configuration.
      This policy validates that all containers have something specified for memory and cpu
      requests and memory limits.
spec:
  validationFailureAction: audit
  rules:
  - name: validate-resources
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "CPU and memory resource requests and limits are required."
      pattern:
        spec:
          containers:
          - resources:
              requests:
                memory: "?*"
                cpu: "?*"
              limits:
                memory: "?*"
```
