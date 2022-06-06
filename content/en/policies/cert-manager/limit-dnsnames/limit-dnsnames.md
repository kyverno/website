---
title: "Limit dnsNames"
category: Cert-Manager
version: 1.3.6
subject: Certificate
policyType: "validate"
description: >
    Some applications will not accept certificates containing more than a single name. This policy ensures that each certificate request contains only one DNS name entry.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//cert-manager/limit-dnsnames/limit-dnsnames.yaml" target="-blank">/cert-manager/limit-dnsnames/limit-dnsnames.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cert-manager-limit-dnsnames
  annotations:
    policies.kyverno.io/title: Limit dnsNames
    policies.kyverno.io/category: Cert-Manager
    policies.kyverno.io/severity: medium
    policies.kyverno.io/minversion: 1.3.6
    policies.kyverno.io/subject: Certificate
    policies.kyverno.io/description: >-
      Some applications will not accept certificates containing more than a single name.
      This policy ensures that each certificate request contains
      only one DNS name entry.
spec:
  validationFailureAction: audit
  background: false
  rules:
  - name: limit-dnsnames
    match:
      resources:
        kinds:
        - Certificate
    validate:
      message: Only one dnsNames entry allowed per certificate request.
      deny:
        conditions:
        - key: "{{request.object.spec.dnsNames || `[]` | length(@)}}"
          operator: GreaterThan
          value: "1"
```
