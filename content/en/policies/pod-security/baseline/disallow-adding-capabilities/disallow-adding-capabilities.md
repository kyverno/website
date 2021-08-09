---
title: "Disallow Add Capabilities"
category: Pod Security Standards (Baseline)
version: 
subject: Pod
policyType: "validate"
description: >
    Capabilities permit privileged actions without giving full root access. Adding capabilities beyond the default set must not be allowed. This policy ensures users cannot add any additional capabilities to a Pod.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/baseline/disallow-adding-capabilities/disallow-adding-capabilities.yaml" target="-blank">/pod-security/baseline/disallow-adding-capabilities/disallow-adding-capabilities.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-add-capabilities
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Baseline)
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Capabilities permit privileged actions without giving full root access.
      Adding capabilities beyond the default set must not be allowed. This policy
      ensures users cannot add any additional capabilities to a Pod.
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: capabilities
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: >-
          Adding of additional capabilities beyond the default set is not allowed.
          The fields spec.containers[*].securityContext.capabilities.add and 
          spec.initContainers[*].securityContext.capabilities.add must be empty.
        pattern:
          spec:
            containers:
              - =(securityContext):
                  =(capabilities):
                    X(add): "null"
            =(initContainers):
              - =(securityContext):
                  =(capabilities):
                    X(add): "null"

```
