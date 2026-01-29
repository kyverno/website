---
title: 'Restrict Ingress defaultBackend in ValidatingPolicy'
category: validate
severity: high
type: ValidatingPolicy
subjects:
  - Ingress
tags:
  - Best Practices in vpol
version: 1.14.0
description: 'An Ingress with no rules sends all traffic to a single default backend. The defaultBackend is conventionally a configuration option of the Ingress controller and is not specified in your Ingress resources. If none of the hosts or paths match the HTTP request in the Ingress objects, the traffic is routed to your default backend. In a multi-tenant environment, you want users to use explicit hosts, they should not be able to overwrite the global default backend service. This policy prohibits the use of the defaultBackend field.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/restrict-ingress-defaultbackend/restrict-ingress-defaultbackend.yaml" target="-blank">/other-vpol/restrict-ingress-defaultbackend/restrict-ingress-defaultbackend.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-ingress-defaultbackend
  annotations:
    policies.kyverno.io/title: Restrict Ingress defaultBackend in ValidatingPolicy
    policies.kyverno.io/category: Best Practices in vpol
    policies.kyverno.io/severity: high
    kyverno.io/kyverno-version: 1.14.0
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/subject: Ingress
    policies.kyverno.io/description: An Ingress with no rules sends all traffic to a single default backend. The defaultBackend is conventionally a configuration option of the Ingress controller and is not specified in your Ingress resources. If none of the hosts or paths match the HTTP request in the Ingress objects, the traffic is routed to your default backend. In a multi-tenant environment, you want users to use explicit hosts, they should not be able to overwrite the global default backend service. This policy prohibits the use of the defaultBackend field.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - networking.k8s.io
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - ingresses
  validations:
    - expression: "!has(object.spec.defaultBackend)"
      message: Setting the defaultBackend field is prohibited.

```
