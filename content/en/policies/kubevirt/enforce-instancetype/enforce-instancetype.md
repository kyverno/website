---
title: "Enforce instanceTypes"
category: KubeVirt
version: 
subject: VirtualMachine
policyType: "validate"
description: >
    Check VirtualMachines and validate that they are not using a domain template (`.spec.template.domain`) but instead are based on instaceTypes and preferences only.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//kubevirt/enforce-instancetype/enforce-instancetype.yaml" target="-blank">/kubevirt/enforce-instancetype/enforce-instancetype.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: k6t-enforce-instancetype
  annotations:
    policies.kyverno.io/title: Enforce instanceTypes
    policies.kyverno.io/category: KubeVirt
    policies.kyverno.io/subject: VirtualMachine
    policies.kyverno.io/description: >-
      Check VirtualMachines and validate that they are not using a domain template (`.spec.template.domain`)
      but instead are based on instaceTypes and preferences only.
    kyverno.io/kyverno-version: "1.8.0-rc2"
    kyverno.io/kubernetes-version: "1.24-1.25"
spec:
  validationFailureAction: enforce
  rules:
  - name: k6t-dont-allow-domain-template
    match:
      any: 
      - resources:
          kinds:
          - VirtualMachine
    validate:
      message: "VirtualMachines must only use instanceTypes and preferences, a domain template is not allowed."
      pattern:
        spec:
          template:
            spec:
              domain: null

```
