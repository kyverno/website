---
title: "Add Node Affinity"
category: Other
version: 
subject: Deployment
policyType: "mutate"
description: >
    Node affinity, similar to node selection, is a way to specify which node(s) on which Pods will be scheduled but based on more complex conditions. This policy will add node affinity to a Deployment and if one already exists an expression will be added to it.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/add-node-affinity/add-node-affinity.yaml" target="-blank">/other/add-node-affinity/add-node-affinity.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-node-affinity
  annotations:
    policies.kyverno.io/title: Add Node Affinity
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Deployment
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: "1.21"
    policies.kyverno.io/description: >-
      Node affinity, similar to node selection, is a way to specify which node(s) on which Pods will be scheduled
      but based on more complex conditions. This policy will add node affinity to a Deployment and if one already
      exists an expression will be added to it.
spec:
  background: false
  rules:
  - name: add-node-affinity-deployment
    match:
      any:
      - resources:
          kinds:
          - Deployment
    mutate:
      patchesJson6902: |-
        - path: "/spec/template/spec/affinity/nodeAffinity/requiredDuringSchedulingIgnoredDuringExecution/nodeSelectorTerms/-1/matchExpressions/-1"
          op: add
          value:
            key: zone_weight
            operator: Lt
            values:
            - "400"

```
