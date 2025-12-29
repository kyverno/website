---
title: 'Enforce Resources as Ratio'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/enforce-resources-as-ratio/enforce-resources-as-ratio.yaml" target="-blank">/other/enforce-resources-as-ratio/enforce-resources-as-ratio.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-resources-as-ratio
  annotations:
    policies.kyverno.io/title: Enforce Resources as Ratio
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: '1.23'
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Resource requests often need to be tailored to the type of workload in the container/Pod. With many different types of applications in a cluster, enforcing hard limits on requests or limits may not work and a ratio may be better suited instead. This policy checks every container in a Pod and ensures that memory limits are no more than 2.5x its requests.
spec:
  validationFailureAction: Audit
  rules:
    - name: check-memory-requests-limits
      match:
        any:
          - resources:
              kinds:
                - Pod
      preconditions:
        any:
          - key: "{{ request.operation || 'BACKGROUND' }}"
            operator: AnyIn
            value:
              - CREATE
              - UPDATE
      validate:
        message: Limits may not exceed 2.5x the requests.
        foreach:
          - list: request.object.spec.containers
            deny:
              conditions:
                any:
                  - key: "{{ divide('{{ element.resources.limits.memory || '0' }}', '{{ element.resources.requests.memory || '1m' }}') }}"
                    operator: GreaterThan
                    value: 2.5
```
