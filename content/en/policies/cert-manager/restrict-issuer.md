---
title: "Restrict issuer"
category: Cert-Manager
version: 
subject: Certificate
policyType: "validate"
description: >
    Ensures that a certificate request for a specific domain uses a designated ClusterIssuer.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//cert-manager/restrict-issuer.yaml" target="-blank">/cert-manager/restrict-issuer.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cert-manager-restrict-issuer
  annotations:
    policies.kyverno.io/title: Restrict issuer
    policies.kyverno.io/category: Cert-Manager
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Certificate
    policies.kyverno.io/description: >-
      Ensures that a certificate request for a specific domain uses a designated ClusterIssuer.
spec:
  validationFailureAction: audit
  background: false
  rules:
  - name: restrict-corp-cert-issuer
    match:
      resources:
        kinds:
        - Certificate
    validate:
      message: When requesting a cert for this domain, you must use our corporate issuer.
      pattern:
        spec:
          (dnsNames): ["*.corp.com"]
          issuerRef:
            name: our-corp-issuer
            kind: ClusterIssuer
            group: cert-manager.io
```
