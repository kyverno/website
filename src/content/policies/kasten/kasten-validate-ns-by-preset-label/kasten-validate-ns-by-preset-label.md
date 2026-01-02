---
title: 'Validate Data Protection with Kasten Preset Label'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Namespace
tags: []
version: 1.9.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/kasten/kasten-validate-ns-by-preset-label/kasten-validate-ns-by-preset-label.yaml" target="-blank">/kasten/kasten-validate-ns-by-preset-label/kasten-validate-ns-by-preset-label.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: kasten-validate-ns-by-preset-label
  annotations:
    policies.kyverno.io/title: Validate Data Protection with Kasten Preset Label
    policies.kyverno.io/category: Veeam Kasten
    policies.kyverno.io/subject: Namespace
    kyverno.io/kyverno-version: 1.12.1
    policies.kyverno.io/minversion: 1.9.0
    kyverno.io/kubernetes-version: 1.24-1.30
    policies.kyverno.io/description: Kubernetes applications are typically deployed into a single, logical namespace.  Veeam Kasten policies will discover and protect all resources within the selected namespace(s).  This policy ensures all new namespaces include a label referencing a valid Kasten SLA  (Policy Preset) for data protection.This policy can be used in combination with /Users/the `kasten-generate-policy-by-preset-label` ClusterPolicy to automatically create a Kasten policy based on the specified SLA.  The combination ensures that new applications are not inadvertently left unprotected.
spec:
  validationFailureAction: Audit
  rules:
    - name: kasten-validate-ns-by-preset-label
      match:
        any:
          - resources:
              kinds:
                - Namespace
      validate:
        message: |-
          Namespaces must specify a "dataprotection" label with a value corresponding to a Kasten Policy Preset:

            "gold" - <Insert human readable settings of each preset option>
            "silver" - <For example, hourly backups, exported to immutable S3 storage>
            "bronze" - <Or, daily local snapshots, NOT exported to external storage>
            "none" - No local snapshots or backups
        pattern:
          metadata:
            labels:
              dataprotection: gold|silver|bronze|none

```
