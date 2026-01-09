---
title: 'Check Data Protection By Label'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Deployment
  - StatefulSet
tags:
  - Veeam Kasten
version: 1.6.2
description: 'Check the ''dataprotection'' label for production Deployments and StatefulSet workloads. Use in combination with ''kasten-generate-example-backup-policy'' policy to generate a Kasten policy for the workload namespace, if it doesn''t already exist.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/kasten/kasten-data-protection-by-label/kasten-data-protection-by-label.yaml" target="-blank">/kasten/kasten-data-protection-by-label/kasten-data-protection-by-label.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: kasten-data-protection-by-label
  annotations:
    policies.kyverno.io/title: Check Data Protection By Label
    policies.kyverno.io/category: Veeam Kasten
    kyverno.io/kyverno-version: 1.12.1
    policies.kyverno.io/minversion: 1.6.2
    kyverno.io/kubernetes-version: 1.24-1.30
    policies.kyverno.io/subject: Deployment, StatefulSet
    policies.kyverno.io/description: Check the 'dataprotection' label for production Deployments and StatefulSet workloads. Use in combination with 'kasten-generate-example-backup-policy' policy to generate a Kasten policy for the workload namespace, if it doesn't already exist.
spec:
  validationFailureAction: Audit
  rules:
    - name: kasten-data-protection-by-label
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - StatefulSet
              selector:
                matchLabels:
                  purpose: production
      validate:
        message: |-
          "Deployments and StatefulSets with 'purpose=production' label must specify a valid 'dataprotection' label:
          "dataprotection=kasten-example" - <Insert human readable settings for each option> "dataprotection=none" - No local snapshots or backups
        pattern:
          metadata:
            labels:
              dataprotection: kasten-example|none

```
