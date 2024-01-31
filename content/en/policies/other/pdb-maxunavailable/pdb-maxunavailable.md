---
title: "PodDisruptionBudget maxUnavailable Non-Zero"
category: Other
version: 
subject: PodDisruptionBudget
policyType: "validate"
description: >
    A PodDisruptionBudget which sets its maxUnavailable value to zero prevents all voluntary evictions including Node drains which may impact maintenance tasks. This policy enforces that if a PodDisruptionBudget specifies the maxUnavailable field it must be greater than zero.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/pdb-maxunavailable/pdb-maxunavailable.yaml" target="-blank">/other/pdb-maxunavailable/pdb-maxunavailable.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: pdb-maxunavailable
  annotations:
    policies.kyverno.io/title: PodDisruptionBudget maxUnavailable Non-Zero
    policies.kyverno.io/category: Other
    kyverno.io/kyverno-version: 1.9.0
    kyverno.io/kubernetes-version: "1.24"
    policies.kyverno.io/subject: PodDisruptionBudget
    policies.kyverno.io/description: >-
      A PodDisruptionBudget which sets its maxUnavailable value to zero prevents
      all voluntary evictions including Node drains which may impact maintenance tasks.
      This policy enforces that if a PodDisruptionBudget specifies the maxUnavailable field
      it must be greater than zero.
spec:
  validationFailureAction: audit
  background: false
  rules:
    - name: pdb-maxunavailable
      match:
        any:
          - resources:
              kinds:
                - PodDisruptionBudget
      validate:
        message: "The value of maxUnavailable must be greater than zero."
        pattern:
          spec:
            =(maxUnavailable): ">0"
```
