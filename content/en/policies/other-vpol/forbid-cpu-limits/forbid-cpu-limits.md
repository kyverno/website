---
title: "Forbid CPU Limits in ValidatingPolicy"
category: Other in Vpol
version: 
subject: Pod
policyType: "validate"
description: >
    Setting of CPU limits is a debatable poor practice as it can result, when defined, in potentially starving applications of much-needed CPU cycles even when they are available. Ensuring that CPU limits are not set may ensure apps run more effectively. This policy forbids any container in a Pod from defining CPU limits.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-vpol/forbid-cpu-limits/forbid-cpu-limits.yaml" target="-blank">/other-vpol/forbid-cpu-limits/forbid-cpu-limits.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: forbid-cpu-limits
  annotations:
    policies.kyverno.io/title: Forbid CPU Limits in ValidatingPolicy
    policies.kyverno.io/category: Other in Vpol 
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: >-
      Setting of CPU limits is a debatable poor practice as it can result, when defined, in potentially starving
      applications of much-needed CPU cycles even when they are available. Ensuring that CPU limits are not
      set may ensure apps run more effectively. This policy forbids any container in a Pod from defining CPU limits.
spec:
  evaluation:
    background:
      enabled: true  
  validationActions: 
    - Audit
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["pods"]
  validations:
     - expression: >-
              !object.spec.containers.exists(container, 
              container.?resources.?limits.?cpu.hasValue())
       message: Containers may not define CPU limits.


```
