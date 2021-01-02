---
type: "docs"
title: Spread Pods Across Nodes
linkTitle: Spread Pods Across Nodes
weight: 27
description: >
    Sample policy to spread pods matching a label across nodes.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/spread_pods_across_topology.yaml" target="-blank">/other/spread_pods_across_topology.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: spread-pods
  annotations:
    policies.kyverno.io/title: Spread Pods Across Nodes 
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Sample policy to spread pods matching a label across nodes.
spec:
  rules:
    - name: spread-pods-across-nodes
      # Matches any Deployment with the label `distributed=required`
      match:
        resources:
          kinds:
          - Deployment
          selector:
            matchLabels:
              distributed: required
      # Mutates the incoming Deployment.
      mutate:
        patchStrategicMerge:
          spec:
            template:
              spec:
                # Adds the topologySpreadConstraints field if non-existent in the request.
                +(topologySpreadConstraints):
                - maxSkew: 1
                  topologyKey: zone
                  whenUnsatisfiable: DoNotSchedule
                  labelSelector:
                    matchLabels:
                      distributed: required
```
