---
title: 'Disallow Localhost ExternalName Services in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Service
tags:
  - Sample in Vpol
version: 1.14.0
description: 'A Service of type ExternalName which points back to localhost can potentially be used to exploit vulnerabilities in some Ingress controllers. This policy audits Services of type ExternalName if the externalName field refers to localhost.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/disallow-localhost-services/disallow-localhost-services.yaml" target="-blank">/other-vpol/disallow-localhost-services/disallow-localhost-services.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: no-localhost-service
  annotations:
    policies.kyverno.io/title: Disallow Localhost ExternalName Services in ValidatingPolicy
    policies.kyverno.io/category: Sample in Vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: A Service of type ExternalName which points back to localhost can potentially be used to exploit vulnerabilities in some Ingress controllers. This policy audits Services of type ExternalName if the externalName field refers to localhost.
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
          - services
  validations:
    - expression: object.spec.type != 'ExternalName' || object.spec.externalName != 'localhost'
      message: Service of type ExternalName cannot point to localhost.

```
