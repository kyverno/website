---
title: "Add runtimeClassName"
category: PSP Migration
version: 
subject: Pod
policyType: "mutate"
description: >
    In the earlier Pod Security Policy controller, it was possible to configure a policy to add a Pod's runtimeClassName. This was beneficial in that various container runtimes could be specified according to a policy. This Kyverno policies mutates Pods to add a runtimeClassName of `prodclass`.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//psp-migration/add-runtimeClassName/add-runtimeClassName.yaml" target="-blank">/psp-migration/add-runtimeClassName/add-runtimeClassName.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-runtimeclassname
  annotations:
    policies.kyverno.io/title: Add runtimeClassName
    policies.kyverno.io/category: PSP Migration
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.10.0
    kyverno.io/kubernetes-version: "1.24"
    pod-policies.kyverno.io/autogen-controllers: none
    policies.kyverno.io/description: >-
      In the earlier Pod Security Policy controller, it was possible to configure a policy to add
      a Pod's runtimeClassName. This was beneficial in that various container runtimes could be
      specified according to a policy. This Kyverno policies mutates Pods to add a runtimeClassName
      of `prodclass`.
spec:
  rules:
  - name: add-prodclass
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      all:
      - key: "{{request.operation || 'BACKGROUND'}}"
        operator: AnyIn
        value:
          - CREATE
          - UPDATE
    mutate:
      patchStrategicMerge:
        spec:
          runtimeClassName: prodclass
```
