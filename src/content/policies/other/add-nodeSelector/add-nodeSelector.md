---
title: 'Add nodeSelector'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.6.0
description: 'The nodeSelector field uses labels to select the node on which a Pod can be scheduled. This can be useful when Pods have specific needs that only certain nodes in a cluster can provide. This policy adds the nodeSelector field to a Pod spec and configures it with labels `foo` and `color`.'
createdAt: "2023-04-04T23:03:22.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/add-nodeSelector/add-nodeSelector.yaml" target="-blank">/other/add-nodeSelector/add-nodeSelector.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-nodeselector
  annotations:
    policies.kyverno.io/title: Add nodeSelector
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: The nodeSelector field uses labels to select the node on which a Pod can be scheduled. This can be useful when Pods have specific needs that only certain nodes in a cluster can provide. This policy adds the nodeSelector field to a Pod spec and configures it with labels `foo` and `color`.
spec:
  rules:
    - name: add-nodeselector
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          spec:
            nodeSelector:
              foo: bar
              color: orange

```
