---
title: "Prevent Bare Pods in CEL expressions"
category: Other, EKS Best Practices in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    Pods not created by workload controllers such as Deployments have no self-healing or scaling abilities and are unsuitable for production. This policy prevents such "bare" Pods from being created unless they originate from a higher-level workload controller of some sort.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/prevent-bare-pods/prevent-bare-pods.yaml" target="-blank">/other-cel/prevent-bare-pods/prevent-bare-pods.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: prevent-bare-pods
  annotations:
    policies.kyverno.io/title: Prevent Bare Pods in CEL expressions
    pod-policies.kyverno.io/autogen-controllers: none
    policies.kyverno.io/category: Other, EKS Best Practices in CEL 
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Pods not created by workload controllers such as Deployments
      have no self-healing or scaling abilities and are unsuitable for production.
      This policy prevents such "bare" Pods from being created unless they originate
      from a higher-level workload controller of some sort.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: bare-pods
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
          - expression: "'ownerReferences' in object.metadata"
            message: "Bare Pods are not allowed. They must be created by Pod controllers."


```
