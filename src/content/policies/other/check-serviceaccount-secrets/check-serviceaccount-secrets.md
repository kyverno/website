---
title: 'Check Long-Lived Secrets in ServiceAccounts'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Secret
  - ServiceAccount
tags: []
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/check-serviceaccount-secrets/check-serviceaccount-secrets.yaml" target="-blank">/other/check-serviceaccount-secrets/check-serviceaccount-secrets.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-serviceaccount-secrets
  annotations:
    policies.kyverno.io/title: Check Long-Lived Secrets in ServiceAccounts
    policies.kyverno.io/category: Security
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.1
    kyverno.io/kubernetes-version: '1.27'
    policies.kyverno.io/subject: Secret,ServiceAccount
    policies.kyverno.io/description: Before version 1.24, Kubernetes automatically generated Secret-based tokens  for ServiceAccounts. To distinguish between automatically generated tokens  and manually created ones, Kubernetes checks for a reference from the  ServiceAccount's secrets field. If the Secret is referenced in the secrets  field, it is considered an auto-generated legacy token. These legacy Tokens can be of security concern and should be audited.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: deny-secrets
      match:
        any:
          - resources:
              kinds:
                - ServiceAccount
      validate:
        message: Long-lived API tokens are not allowed.
        pattern:
          X(secrets): null
```
