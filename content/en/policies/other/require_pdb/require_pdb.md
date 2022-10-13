---
title: "Require PodDisruptionBudget"
category: Sample
version: 1.3.6
subject: Deployment, PodDisruptionBudget
policyType: "validate"
description: >
    PodDisruptionBudget resources are useful to ensuring minimum availability is maintained at all times. This policy checks all incoming Deployments to ensure they have a matching, preexisting PodDisruptionBudget.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/require_pdb/require_pdb.yaml" target="-blank">/other/require_pdb/require_pdb.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-pdb
  annotations:
    policies.kyverno.io/title: Require PodDisruptionBudget
    policies.kyverno.io/category: Sample
    policies.kyverno.io/minversion: 1.3.6
    kyverno.io/kyverno-version: 1.6.2
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Deployment, PodDisruptionBudget
    policies.kyverno.io/description: >-
      PodDisruptionBudget resources are useful to ensuring minimum availability
      is maintained at all times. This policy checks all incoming Deployments
      to ensure they have a matching, preexisting PodDisruptionBudget.
spec:
  validationFailureAction: audit
  background: false
  rules:
  - name: require-pdb
    match:
      resources:
        kinds:
        - Deployment
    preconditions:
      any:
      - key: "{{request.operation || 'BACKGROUND'}}"
        operator: Equals
        value: CREATE
    context:
    - name: pdb_count
      apiCall:
        urlPath: "/apis/policy/v1/namespaces/{{request.namespace}}/poddisruptionbudgets"
        jmesPath: "items[?label_match(spec.selector.matchLabels, `{{request.object.spec.template.metadata.labels}}`)] | length(@)"
    validate:
      message: "There is no corresponding PodDisruptionBudget found for this Deployment."
      deny:
        conditions:
          any:
          - key: "{{pdb_count}}"
            operator: LessThan
            value: 1
```
