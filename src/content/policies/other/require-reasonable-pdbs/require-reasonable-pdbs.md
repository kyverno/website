---
title: 'Require Reasonable PodDisruptionBudgets'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - PodDisruptionBudget
tags: []
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/require-reasonable-pdbs/require-reasonable-pdbs.yaml" target="-blank">/other/require-reasonable-pdbs/require-reasonable-pdbs.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-reasonable-pdbs
  annotations:
    policies.kyverno.io/title: Require Reasonable PodDisruptionBudgets
    policies.kyverno.io/category: Other
    policies.kyverno.io/subject: PodDisruptionBudget
    kyverno.io/kyverno-version: 1.11.4
    kyverno.io/kubernetes-version: '1.27'
    policies.kyverno.io/description: PodDisruptionBudget resources are useful to ensuring minimum availability is maintained at all times. Achieving a balance between availability and maintainability is important. This policy validates that a PodDisruptionBudget, specified as percentages, allows 50% of the replicas to be out of service in that minAvailable should be no higher than 50% and maxUnavailable should be no lower than 50%.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: require-reasonable-pdb-percentage
      match:
        any:
          - resources:
              kinds:
                - PodDisruptionBudget
      preconditions:
        any:
          - key: "{{ regex_match('^[0-9]+%$', '{{ request.object.spec.minAvailable || ''}}') }}"
            operator: Equals
            value: true
          - key: "{{ regex_match('^[0-9]+%$', '{{ request.object.spec.maxUnavailable || ''}}') }}"
            operator: Equals
            value: true
      validate:
        message: PodDisruptionBudget percentages should allow 50% out of service. minAvailable should be no higher than 50% and maxUnavailable should be no lower than 50%.
        deny:
          conditions:
            any:
              - key: "{{ regex_match('^([1-9]|[1-4][0-9]|5[0])%$', '{{ request.object.spec.minAvailable || '50%'}}') }}"
                operator: Equals
                value: false
              - key: "{{ regex_match('^([5-9][0-9]|100)%$', '{{ request.object.spec.maxUnavailable || '50%'}}') }}"
                operator: Equals
                value: false
```
