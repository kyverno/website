---
title: 'Disallow Localhost ExternalName Services in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Service
tags:
  - Sample in Vpol
version: 1.19.1
description: 'A Service of type ExternalName which points back to localhost can potentially be used to exploit vulnerabilities in some Ingress controllers. This policy audits Services of type ExternalName if the externalName field refers to localhost.'
createdAt: "2025-09-04T05:15:25.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/disallow-localhost-services/disallow-localhost-services.yaml" target="_blank" rel="noopener noreferrer">/other-vpol/disallow-localhost-services/disallow-localhost-services.yaml</a>

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
    policies.kyverno.io/minversion: 1.19.1
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
    - expression: object.spec.type != 'ExternalName' || object.spec.externalName != 'localhost' || exceptions.allowedValues.exists(value, value == 'externalName:' + object.spec.externalName)
      message: Service of type ExternalName cannot point to localhost.

```
