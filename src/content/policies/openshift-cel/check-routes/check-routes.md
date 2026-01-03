---
title: 'Require TLS routes in OpenShift in CEL expressions'
category: validate
severity: high
type: ClusterPolicy
subjects:
  - Route
tags:
  - OpenShift in CEL expressions
version: 1.11.0
description: 'HTTP traffic is not encrypted and hence insecure. This policy prevents configuration of OpenShift HTTP routes.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/openshift-cel/check-routes/check-routes.yaml" target="-blank">/openshift-cel/check-routes/check-routes.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-routes
  annotations:
    policies.kyverno.io/title: Require TLS routes in OpenShift in CEL expressions
    policies.kyverno.io/category: OpenShift in CEL expressions
    policies.kyverno.io/severity: high
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/subject: Route
    policies.kyverno.io/description: HTTP traffic is not encrypted and hence insecure. This policy prevents configuration of OpenShift HTTP routes.
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: require-tls-routes
      match:
        any:
          - resources:
              kinds:
                - route.openshift.io/v1/Route
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: has(object.spec.tls)
              message: HTTP routes are not allowed. Configure TLS for secure routes.

```
