---
title: "Deny Creation and Updating of Resources"
category: Other
version: 1.9.0
subject: Pod
policyType: "validate"
description: >
    This policy denies the creation and updating of resources specifically for Deployment  and Pod kinds during a specified time window. The policy is designed to enhance control  over resource modifications during critical periods, ensuring stability and consistency  within the Kubernetes environment.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/resource-creation-updating-denied/resource-creation-updating-denied.yaml" target="-blank">/other/resource-creation-updating-denied/resource-creation-updating-denied.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: resource-creation-updating-denied
  annotations:
    policies.kyverno.io/title: Deny Creation and Updating of Resources
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.1
    policies.kyverno.io/minversion: 1.9.0
    kyverno.io/kubernetes-version: "1.27"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      This policy denies the creation and updating of resources specifically for Deployment 
      and Pod kinds during a specified time window. The policy is designed to enhance control 
      over resource modifications during critical periods, ensuring stability and consistency 
      within the Kubernetes environment.
spec:
  validationFailureAction: Audit
  background: false
  rules:
  - name: deny-creation-updating-of-resources
    match:
      any:
      - resources:
          kinds:
            - Deployment
    preconditions:
      all:
      - key: '{{ time_now_utc().time_to_cron(@).split(@,'' '') | [1].to_number(@)  }}'
        operator: AnyIn
        value: 8-10
    validate:
      message: Creating and updating resources is not allowed at this time.
      deny:
        conditions:
          all:
          - key: '{{request.operation}}'
            operator: AnyIn
            value:
            - CREATE
            - UPDATE

```
