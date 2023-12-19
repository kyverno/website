---
title: "Restrict Service Port Range"
category: Other
version: 1.6.0
subject: Service
policyType: "validate"
description: >
    Services which are allowed to expose any port number may be able to impact other applications running on the Node which require them, or may make specifying security policy externally more challenging. This policy enforces that only the port range 32000 to 33000 may be used for Service resources.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict-service-port-range/restrict-service-port-range.yaml" target="-blank">/other/restrict-service-port-range/restrict-service-port-range.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-service-port-range
  annotations:
    policies.kyverno.io/title: Restrict Service Port Range
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Service
    policies.kyverno.io/description: >-
      Services which are allowed to expose any port number may be able
      to impact other applications running on the Node which require them,
      or may make specifying security policy externally more challenging.
      This policy enforces that only the port range 32000 to 33000 may
      be used for Service resources.
spec:
  validationFailureAction: audit
  rules:
  - name: restrict-port-range
    match:
      any:
      - resources:
          kinds:
          - Service
    validate:
      message: Ports must be between 32000-33000
      pattern:
        spec:
          ports:
          - port: 32000-33000
```
