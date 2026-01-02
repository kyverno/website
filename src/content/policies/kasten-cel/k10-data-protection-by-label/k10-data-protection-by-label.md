---
title: 'Check Data Protection By Label in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Deployment
  - StatefulSet
tags: []
version: 1.11.0
description: "Check the 'dataprotection' label that production Deployments and StatefulSet have a named K10 Policy. Use in combination with 'generate' ClusterPolicy to 'generate' a specific K10 Policy by name."
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/kasten-cel/k10-data-protection-by-label/k10-data-protection-by-label.yaml" target="-blank">/kasten-cel/k10-data-protection-by-label/k10-data-protection-by-label.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: k10-data-protection-by-label
  annotations:
    policies.kyverno.io/title: Check Data Protection By Label in CEL expressions
    policies.kyverno.io/category: Kasten K10 by Veeam in CEL
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/subject: Deployment, StatefulSet
    policies.kyverno.io/description: Check the 'dataprotection' label that production Deployments and StatefulSet have a named K10 Policy. Use in combination with 'generate' ClusterPolicy to 'generate' a specific K10 Policy by name.
spec:
  validationFailureAction: Audit
  rules:
    - name: k10-data-protection-by-label
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - StatefulSet
              operations:
                - CREATE
                - UPDATE
              selector:
                matchLabels:
                  purpose: production
      validate:
        cel:
          expressions:
            - expression: object.metadata.?labels.?dataprotection.orValue('').startsWith('k10-')
              message: "Deployments and StatefulSets that specify 'dataprotection' label must have a valid k10-?* name (use labels: dataprotection: k10-<policyname>)"
```
