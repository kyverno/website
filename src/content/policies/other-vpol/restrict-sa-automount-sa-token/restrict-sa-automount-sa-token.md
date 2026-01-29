---
title: 'Restrict Auto-Mount of Service Account Tokens in Service Account in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Secret
  - ServiceAccount
tags:
  - Security in vpol
description: 'Kubernetes automatically mounts ServiceAccount credentials in each ServiceAccount. The ServiceAccount may be assigned roles allowing Pods to access API resources. Blocking this ability is an extension of the least privilege best practice and should be followed if Pods do not need to speak to the API server to function. This policy ensures that mounting of these ServiceAccount tokens is blocked.      '
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/restrict-sa-automount-sa-token/restrict-sa-automount-sa-token.yaml" target="-blank">/other-vpol/restrict-sa-automount-sa-token/restrict-sa-automount-sa-token.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-sa-automount-sa-token
  annotations:
    policies.kyverno.io/title: Restrict Auto-Mount of Service Account Tokens in Service Account in ValidatingPolicy
    policies.kyverno.io/category: Security in vpol
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Secret,ServiceAccount
    policies.kyverno.io/description: "Kubernetes automatically mounts ServiceAccount credentials in each ServiceAccount. The ServiceAccount may be assigned roles allowing Pods to access API resources. Blocking this ability is an extension of the least privilege best practice and should be followed if Pods do not need to speak to the API server to function. This policy ensures that mounting of these ServiceAccount tokens is blocked.      "
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - serviceaccounts
  validations:
    - expression: object.?automountServiceAccountToken.orValue(true) == false
      message: ServiceAccounts must set automountServiceAccountToken to false.

```
