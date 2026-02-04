---
title: 'Add ndots'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.6.0
description: 'The ndots value controls where DNS lookups are first performed in a cluster and needs to be set to a lower value than the default of 5 in some cases. This policy mutates all Pods to add the ndots option with a value of 1.'
createdAt: "2023-04-04T23:03:22.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/add-ndots/add-ndots.yaml" target="-blank">/other/add-ndots/add-ndots.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-ndots
  annotations:
    policies.kyverno.io/title: Add ndots
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: The ndots value controls where DNS lookups are first performed in a cluster and needs to be set to a lower value than the default of 5 in some cases. This policy mutates all Pods to add the ndots option with a value of 1.
spec:
  rules:
    - name: add-ndots
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          spec:
            dnsConfig:
              options:
                - name: ndots
                  value: "1"

```
