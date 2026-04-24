---
title: 'Spread Pods Across Nodes'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Deployment
  - Pod
tags:
  - Sample
version: 1.6.0
description: 'Deployments to a Kubernetes cluster with multiple availability zones often need to distribute those replicas to align with those zones to ensure site-level failures do not impact availability. This policy matches Deployments with the label `distributed=required` and mutates them to spread Pods across zones.'
createdAt: "2023-04-04T23:03:22.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/spread-pods-across-topology/spread-pods-across-topology.yaml" target="-blank">/other/spread-pods-across-topology/spread-pods-across-topology.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: spread-pods
  annotations:
    policies.kyverno.io/title: Spread Pods Across Nodes
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Deployment, Pod
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: Deployments to a Kubernetes cluster with multiple availability zones often need to distribute those replicas to align with those zones to ensure site-level failures do not impact availability. This policy matches Deployments with the label `distributed=required` and mutates them to spread Pods across zones.
spec:
  rules:
    - name: spread-pods-across-nodes
      match:
        any:
          - resources:
              kinds:
                - Deployment
              selector:
                matchLabels:
                  distributed: required
      mutate:
        patchStrategicMerge:
          spec:
            template:
              spec:
                +(topologySpreadConstraints):
                  - maxSkew: 1
                    topologyKey: zone
                    whenUnsatisfiable: DoNotSchedule
                    labelSelector:
                      matchLabels:
                        distributed: required

```
