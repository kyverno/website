---
title: 'Disallow Localhost ExternalName Services'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Service
tags:
  - Sample
version: 1.6.0
description: 'A Service of type ExternalName which points back to localhost can potentially be used to exploit vulnerabilities in some Ingress controllers. This policy audits Services of type ExternalName if the externalName field refers to localhost.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/disallow-localhost-services/disallow-localhost-services.yaml" target="-blank">/other/disallow-localhost-services/disallow-localhost-services.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: no-localhost-service
  annotations:
    policies.kyverno.io/title: Disallow Localhost ExternalName Services
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/minversion: 1.6.0
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
      validate:
        message: Service of type ExternalName cannot point to localhost.
        pattern:
          spec:
            (type): ExternalName
            externalName: '!localhost'
```
