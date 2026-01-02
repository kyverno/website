---
title: 'Validate Data Protection by Preset Label in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Namespace
tags:
  - Kasten K10 by Veeam in CEL
version: 1.11.0
description: 'Kubernetes applications are typically deployed into a single, logical namespace.  Kasten K10 policies will discover and protect all resources within the selected namespace(s).  This policy ensures all new namespaces include a label referencing a valid K10 SLA  (Policy Preset) for data protection.This policy can be used in combination with generate  ClusterPolicy to automatically create a K10 policy based on the specified SLA.  The combination ensures that new applications are not inadvertently left unprotected.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/kasten-cel/k10-validate-ns-by-preset-label/k10-validate-ns-by-preset-label.yaml" target="-blank">/kasten-cel/k10-validate-ns-by-preset-label/k10-validate-ns-by-preset-label.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: k10-validate-ns-by-preset-label
  annotations:
    policies.kyverno.io/title: Validate Data Protection by Preset Label in CEL expressions
    policies.kyverno.io/category: Kasten K10 by Veeam in CEL
    policies.kyverno.io/subject: Namespace
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/description: Kubernetes applications are typically deployed into a single, logical namespace.  Kasten K10 policies will discover and protect all resources within the selected namespace(s).  This policy ensures all new namespaces include a label referencing a valid K10 SLA  (Policy Preset) for data protection.This policy can be used in combination with generate  ClusterPolicy to automatically create a K10 policy based on the specified SLA.  The combination ensures that new applications are not inadvertently left unprotected.
spec:
  validationFailureAction: Audit
  rules:
    - name: k10-validate-ns-by-preset-label
      match:
        any:
          - resources:
              kinds:
                - Namespace
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: object.metadata.?labels.?dataprotection.orValue('') in ['gold', 'silver', 'bronze', 'none']
              message: |-
                Namespaces must specify a "dataprotection" label with a value corresponding to a Kasten K10 SLA:

                  "gold" - <Insert human readable settings of each preset option>
                  "silver" - <For example, hourly backups, exported to immutable S3 storage>
                  "bronze" - <Or, daily local snapshots, NOT exported to external storage>
                  "none" - No local snapshots or backups
```
