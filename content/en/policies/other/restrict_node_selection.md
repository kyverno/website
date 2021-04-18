---
type: "docs"
title: Restrict Node Selection
linkTitle: Restrict Node Selection
weight: 35
description: >
    This policy prevents users from targeting specific nodes for scheduling of Pods by prohibiting the use of the `nodeSelector` and `nodeName` fields in a Pod spec.     
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict_node_selection.yaml" target="-blank">/other/restrict_node_selection.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-node-selection
  annotations:
    policies.kyverno.io/title: Restrict node selection
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      This policy prevents users from targeting specific nodes
      for scheduling of Pods by prohibiting the use of the `nodeSelector`
      and `nodeName` fields in a Pod spec.     
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: restrict-nodeselector
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: Setting the nodeSelector field is prohibited.
      pattern:
        spec:
          X(nodeSelector): "null"
  - name: restrict-nodename
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: Setting the nodeName field is prohibited.
      pattern:
        spec:
          X(nodeName): "null"
```
