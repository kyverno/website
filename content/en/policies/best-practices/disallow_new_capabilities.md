---
type: "docs"
title: Disallow New Capabilities
linkTitle: Disallow New Capabilities
weight: 12
description: >
    Linux allows defining fine-grained permissions using capabilities. With Kubernetes, it is possible to add capabilities that escalate the level of kernel access and allow other potentially dangerous behaviors. This policy enforces that containers cannot add new capabilities. Other policies can be used to set default capabilities.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/disallow_new_capabilities.yaml" target="-blank">/best-practices/disallow_new_capabilities.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-new-capabilities
  annotations:
    pod-policies.kyverno.io/autogen-controllers: none
    policies.kyverno.io/category: Security
    policies.kyverno.io/description: Linux allows defining fine-grained permissions using
      capabilities. With Kubernetes, it is possible to add capabilities that escalate the
      level of kernel access and allow other potentially dangerous behaviors. This policy 
      enforces that containers cannot add new capabilities. Other policies can be used to set
      default capabilities. 
spec:
  validationFailureAction: audit
  rules:
  - name: validate-add-capabilities
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "New capabilities cannot be added"
      pattern:
        spec:
          containers:
            - name: "*"
              =(securityContext):
                =(capabilities):
                  X(add): null

```
