---
title: 'Set Kasten Policy Minimum Backup Retention'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Policy
tags: []
version: 1.6.2
description: "Example Kyverno policy to enforce common compliance retention standards by modifying Kasten Policy backup retention settings. Based on regulation/compliance standard requirements, uncomment (1) of the desired GFS retention schedules to mutate existing and future Kasten Policies. Alternatively, this policy can be used to reduce retention lengths to enforce cost optimization. NOTE: This example only applies to Kasten Policies with an '@hourly' frequency. Refer to Kasten documentation for Policy API specification if modifications are necessary: https://docs.kasten.io/latest/api/policies.html#policy-api-type"
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/kasten/kasten-minimum-retention/kasten-minimum-retention.yaml" target="-blank">/kasten/kasten-minimum-retention/kasten-minimum-retention.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: kasten-minimum-retention
  annotations:
    policies.kyverno.io/title: Set Kasten Policy Minimum Backup Retention
    policies.kyverno.io/category: Veeam Kasten
    kyverno.io/kyverno-version: 1.12.1
    policies.kyverno.io/minversion: 1.6.2
    kyverno.io/kubernetes-version: 1.24-1.30
    policies.kyverno.io/subject: Policy
    policies.kyverno.io/description: "Example Kyverno policy to enforce common compliance retention standards by modifying Kasten Policy backup retention settings. Based on regulation/compliance standard requirements, uncomment (1) of the desired GFS retention schedules to mutate existing and future Kasten Policies. Alternatively, this policy can be used to reduce retention lengths to enforce cost optimization. NOTE: This example only applies to Kasten Policies with an '@hourly' frequency. Refer to Kasten documentation for Policy API specification if modifications are necessary: https://docs.kasten.io/latest/api/policies.html#policy-api-type"
spec:
  rules:
    - name: kasten-minimum-retention
      match:
        any:
          - resources:
              kinds:
                - config.kio.kasten.io/v1alpha1/Policy
      preconditions:
        all:
          - key: "{{ request.object.spec.frequency || ''}}"
            operator: Equals
            value: '@hourly'
      mutate:
        patchesJson6902: |-
          - path: "/spec/retention"
            op: replace
            value:
              hourly: 24
              daily: 30
              weekly: 4
              monthly: 3
```
