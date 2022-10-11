---
title: "Prevent Linkerd Pod Injection Override"
category: Linkerd
version: 
subject: Pod
policyType: "validate"
description: >
    Setting the annotation on a Pod (or its controller) `linkerd.io/inject` to `disabled` may effectively disable mesh participation for that workload reducing security and visibility. This policy prevents setting the annotation `linkerd.io/inject` to `disabled` for Pods.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//linkerd/prevent-linkerd-pod-injection-override/prevent-linkerd-pod-injection-override.yaml" target="-blank">/linkerd/prevent-linkerd-pod-injection-override/prevent-linkerd-pod-injection-override.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: prevent-linkerd-pod-injection-override
  annotations:
    policies.kyverno.io/title: Prevent Linkerd Pod Injection Override
    policies.kyverno.io/category: Linkerd
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Setting the annotation on a Pod (or its controller) `linkerd.io/inject` to
      `disabled` may effectively disable mesh participation for that workload reducing
      security and visibility. This policy prevents setting the annotation `linkerd.io/inject`
      to `disabled` for Pods.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: pod-injection-override
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Pods may not disable sidecar injection."
      pattern:
        metadata:
          =(annotations):
            =(linkerd.io/inject): "!disabled"
```
