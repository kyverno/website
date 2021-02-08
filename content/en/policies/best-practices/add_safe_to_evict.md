---
type: "docs"
title: Add safe-to-evict
linkTitle: Add safe-to-evict
weight: 3
description: >
    The Kubernetes cluster autoscaler does not evict pods that use hostPath  or emptyDir volumes. To allow eviction of these pods, the annotation  cluster-autoscaler.kubernetes.io/safe-to-evict=true must be added to pods. 
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/add_safe_to_evict.yaml" target="-blank">/best-practices/add_safe_to_evict.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata: 
  name: add-safe-to-evict
  annotations:
    policies.kyverno.io/title: Add safe-to-evict 
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: >-
      The Kubernetes cluster autoscaler does not evict pods that use hostPath 
      or emptyDir volumes. To allow eviction of these pods, the annotation 
      cluster-autoscaler.kubernetes.io/safe-to-evict=true must be added to pods. 
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
