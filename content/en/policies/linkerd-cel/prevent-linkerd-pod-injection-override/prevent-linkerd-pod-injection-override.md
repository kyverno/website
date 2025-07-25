---
title: "Prevent Linkerd Pod Injection Override in CEL expressions"
category: Linkerd in CEL
version: 
subject: Pod
policyType: "validate"
description: >
    Setting the annotation on a Pod (or its controller) `linkerd.io/inject` to `disabled` may effectively disable mesh participation for that workload reducing security and visibility. This policy prevents setting the annotation `linkerd.io/inject` to `disabled` for Pods.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//linkerd-cel/prevent-linkerd-pod-injection-override/prevent-linkerd-pod-injection-override.yaml" target="-blank">/linkerd-cel/prevent-linkerd-pod-injection-override/prevent-linkerd-pod-injection-override.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: prevent-linkerd-pod-injection-override
  annotations:
    policies.kyverno.io/title: Prevent Linkerd Pod Injection Override in CEL expressions
    policies.kyverno.io/category: Linkerd in CEL 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      Setting the annotation on a Pod (or its controller) `linkerd.io/inject` to
      `disabled` may effectively disable mesh participation for that workload reducing
      security and visibility. This policy prevents setting the annotation `linkerd.io/inject`
      to `disabled` for Pods.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: pod-injection-override
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
          - expression: "object.metadata.?annotations[?'linkerd.io/inject'].orValue('') != 'disabled'"
            message: "Pods may not disable sidecar injection."


```
