---
type: "docs"
title: Spread Pods
linkTitle: Spread Pods
weight: 20
description: >
    
---

## Category


## Definition
[/other/spread_pods_across_topology.yaml](https://github.com/kyverno/policies/raw/main//other/spread_pods_across_topology.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: spread-pods
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
