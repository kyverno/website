---
title: 'Restrict issuer'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Certificate
tags:
  - Cert-Manager
description: 'Certificates for trusted domains should always be steered to a controlled issuer to ensure the chain of trust is appropriate for that application. Users may otherwise be able to create their own issuers and sign certificates for other domains. This policy ensures that a certificate request for a specific domain uses a designated ClusterIssuer.'
createdAt: "2021-08-18T18:17:53.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/cert-manager/restrict-issuer/restrict-issuer.yaml" target="-blank">/cert-manager/restrict-issuer/restrict-issuer.yaml</a>

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
    policies.kyverno.io/description: Certificates for trusted domains should always be steered to a controlled issuer to ensure the chain of trust is appropriate for that application. Users may otherwise be able to create their own issuers and sign certificates for other domains. This policy ensures that a certificate request for a specific domain uses a designated ClusterIssuer.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: restrict-corp-cert-issuer
      match:
        any:
          - resources:
              kinds:
                - Certificate
      validate:
        message: When requesting a cert for this domain, you must use our corporate issuer.
        pattern:
          spec:
            (dnsNames):
              - "*.corp.com"
            issuerRef:
              name: our-corp-issuer
              kind: ClusterIssuer
              group: cert-manager.io

```
