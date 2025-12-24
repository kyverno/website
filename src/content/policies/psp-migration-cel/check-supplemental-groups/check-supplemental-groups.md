---
title: 'Check supplementalGroups in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
version: 1.11.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/psp-migration-cel/check-supplemental-groups/check-supplemental-groups.yaml" target="-blank">/psp-migration-cel/check-supplemental-groups/check-supplemental-groups.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psp-check-supplemental-groups
  annotations:
    policies.kyverno.io/title: Check supplementalGroups in CEL expressions
    policies.kyverno.io/category: PSP Migration in CEL
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Supplemental groups control which group IDs containers add and can coincide with restricted groups on the host. Pod Security Policies (PSP) allowed a range of these group IDs to be specified which were allowed. This policy ensures any Pod may only specify supplementalGroup IDs between 100-200 or 500-600.
spec:
  background: false
  validationFailureAction: Audit
  rules:
    - name: supplementalgroup-ranges
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
            - expression: object.spec.?securityContext.?supplementalGroups.orValue([]).all(supplementalGroup, (supplementalGroup >= 100 && supplementalGroup <= 200) || (supplementalGroup >= 500 && supplementalGroup <= 600))
              message: Any supplementalGroup ID must be within the range 100-200 or 500-600.
```
