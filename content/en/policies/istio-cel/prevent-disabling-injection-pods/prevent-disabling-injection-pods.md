---
title: "Prevent Disabling Istio Sidecar Injection in CEL expressions"
category: Istio in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    One way sidecar injection in an Istio service mesh may be accomplished is by defining an annotation at the Pod level. Pods not receiving a sidecar cannot participate in the mesh thereby reducing visibility. This policy ensures that Pods cannot set the annotation `sidecar.istio.io/inject` to a value of `false`.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//istio-cel/prevent-disabling-injection-pods/prevent-disabling-injection-pods.yaml" target="-blank">/istio-cel/prevent-disabling-injection-pods/prevent-disabling-injection-pods.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: prevent-disabling-injection-pods
  annotations:
    policies.kyverno.io/title: Prevent Disabling Istio Sidecar Injection in CEL expressions
    policies.kyverno.io/category: Istio in CEL 
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      One way sidecar injection in an Istio service mesh may be accomplished is by defining
      an annotation at the Pod level. Pods not receiving a sidecar cannot participate in the mesh
      thereby reducing visibility. This policy ensures that Pods cannot set the annotation
      `sidecar.istio.io/inject` to a value of `false`.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: prohibit-inject-annotation
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
          - expression: >-
              object.metadata.?annotations[?'sidecar.istio.io/inject'].orValue('') != 'false'
            message: "Pods may not disable sidecar injection by setting the annotation sidecar.istio.io/inject to a value of false."


```
