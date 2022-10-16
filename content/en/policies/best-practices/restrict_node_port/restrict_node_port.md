---
title: "Disallow NodePort"
category: Best Practices
version: 
subject: Service
policyType: "validate"
description: >
    A Kubernetes Service of type NodePort uses a host port to receive traffic from any source. A NetworkPolicy cannot be used to control traffic to host ports. Although NodePort Services can be useful, their use must be limited to Services with additional upstream security checks. This policy validates that any new Services do not use the `NodePort` type.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/restrict_node_port/restrict_node_port.yaml" target="-blank">/best-practices/restrict_node_port/restrict_node_port.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-nodeport
  annotations:
    policies.kyverno.io/title: Disallow NodePort
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/description: >-
      A Kubernetes Service of type NodePort uses a host port to receive traffic from
      any source. A NetworkPolicy cannot be used to control traffic to host ports.
      Although NodePort Services can be useful, their use must be limited to Services
      with additional upstream security checks. This policy validates that any new Services
      do not use the `NodePort` type.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: validate-nodeport
    match:
      resources:
        kinds:
        - Service
    validate:
      message: "Services of type NodePort are not allowed."
      pattern:
        spec:
          =(type): "!NodePort"

```
