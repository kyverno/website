---
title: 'Disallow Localhost ExternalName Services in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Service
tags:
  - Sample in CEL
version: 1.11.0
description: 'A Service of type ExternalName which points back to localhost can potentially be used to exploit vulnerabilities in some Ingress controllers. This policy audits Services of type ExternalName if the externalName field refers to localhost.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-cel/disallow-localhost-services/disallow-localhost-services.yaml" target="-blank">/other-cel/disallow-localhost-services/disallow-localhost-services.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: no-localhost-service
  annotations:
    policies.kyverno.io/title: Disallow Localhost ExternalName Services in CEL expressions
    policies.kyverno.io/category: Sample in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/description: A Service of type ExternalName which points back to localhost can potentially be used to exploit vulnerabilities in some Ingress controllers. This policy audits Services of type ExternalName if the externalName field refers to localhost.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: no-localhost-service
      match:
        any:
          - resources:
              kinds:
                - Service
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: object.spec.type != 'ExternalName' || object.spec.externalName != 'localhost'
              message: Service of type ExternalName cannot point to localhost.

```
