---
type: "docs"
title: Add Safe To Evict
linkTitle: Add Safe To Evict
weight: 10
description: >
    The Kubernetes cluster autoscaler does not evict pods that use hostPath or emptyDir volumes. To allow eviction of these pods, the annotation cluster-autoscaler.kubernetes.io/safe-to-evict=true must be added to the pods.
---

## Category
Workload Management

## Definition
[/best-practices/add_safe_to_evict.yaml](https://github.com/kyverno/policies/raw/main//best-practices/add_safe_to_evict.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata: 
  name: add-safe-to-evict
  annotations:
    policies.kyverno.io/category: Workload Management
    policies.kyverno.io/description: The Kubernetes cluster autoscaler does not evict pods that 
      use hostPath or emptyDir volumes. To allow eviction of these pods, the annotation 
      cluster-autoscaler.kubernetes.io/safe-to-evict=true must be added to the pods. 
spec: 
  rules: 
  - name: annotate-empty-dir
    match: 
      resources: 
        kinds: 
        - Pod
    mutate: 
      patchStrategicMerge:
        metadata:
          annotations:
            +(cluster-autoscaler.kubernetes.io/safe-to-evict): "true"
        spec:          
          volumes: 
          - (emptyDir): {}
  - name: annotate-host-path
    match: 
      resources: 
        kinds: 
        - Pod
    mutate: 
      patchStrategicMerge:
        metadata:
          annotations:
            +(cluster-autoscaler.kubernetes.io/safe-to-evict): "true"
        spec:          
          volumes: 
          - (hostPath):
              path: "*"

```
