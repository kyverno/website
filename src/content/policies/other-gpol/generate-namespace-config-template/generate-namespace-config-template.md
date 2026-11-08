---
title: 'Generate Namespace Configuration from a Template'
category: generate
severity: medium
type: GeneratingPolicy
subjects:
  - Namespace
  - ConfigMap
tags:
  - Other
version: 1.20.0
description: 'Generate a ConfigMap using a YAML template with CEL interpolation for namespaces labeled platform.example.com/environment. Process existing namespaces on policy installation as well as future namespace admissions. Synchronize the generated environment value when the namespace label changes.'
createdAt: "2026-11-08T02:12:54.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-gpol/generate-namespace-config-template/generate-namespace-config-template.yaml" target="_blank" rel="noopener noreferrer">/other-gpol/generate-namespace-config-template/generate-namespace-config-template.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: generate-namespace-config-template
  annotations:
    policies.kyverno.io/title: Generate Namespace Configuration from a Template
    policies.kyverno.io/category: Other
    policies.kyverno.io/subject: Namespace, ConfigMap
    policies.kyverno.io/minversion: 1.20.0
    policies.kyverno.io/description: Generate a ConfigMap using a YAML template with CEL interpolation for namespaces labeled platform.example.com/environment. Process existing namespaces on policy installation as well as future namespace admissions. Synchronize the generated environment value when the namespace label changes.
spec:
  evaluation:
    generateExisting:
      enabled: true
    synchronize:
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
          - namespaces
    objectSelector:
      matchExpressions:
        - key: platform.example.com/environment
          operator: Exists
  generate:
    - template:
        interpolate: cel
        value: |
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: environment-config
            namespace: (( object.metadata.name ))
          data:
            environment: (( object.metadata.labels['platform.example.com/environment'] ))
            namespace: (( object.metadata.name ))

```
