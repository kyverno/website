---
title: "Disallow NodePort in CEL expressions"
category: Best Practices in CEL
version: 1.11.0
subject: Service
policyType: "validate"
description: >
    A Kubernetes Service of type NodePort uses a host port to receive traffic from any source. A NetworkPolicy cannot be used to control traffic to host ports. Although NodePort Services can be useful, their use must be limited to Services with additional upstream security checks. This policy validates that any new Services do not use the `NodePort` type.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices-cel/restrict-node-port/restrict-node-port.yaml" target="-blank">/best-practices-cel/restrict-node-port/restrict-node-port.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-nodeport
  annotations:
    policies.kyverno.io/title: Disallow NodePort in CEL expressions
    policies.kyverno.io/category: Best Practices in CEL 
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/description: >-
      A Kubernetes Service of type NodePort uses a host port to receive traffic from
      any source. A NetworkPolicy cannot be used to control traffic to host ports.
      Although NodePort Services can be useful, their use must be limited to Services
      with additional upstream security checks. This policy validates that any new Services
      do not use the `NodePort` type.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: validate-nodeport
    match:
      any:
      - resources:
          kinds:
          - Service
          operations:
          - CREATE
          - UPDATE
    validate:
      cel:
        expressions:
          - expression: "has(object.spec.type) ? (object.spec.type != 'NodePort') : true"
            message: "Services of type NodePort are not allowed."


```
