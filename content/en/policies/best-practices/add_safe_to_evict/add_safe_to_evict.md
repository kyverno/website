---
title: "Add Safe To Evict"
category: Other
version: 1.4.3
subject: Pod,Annotation
policyType: "mutate"
description: >
    The Kubernetes cluster autoscaler does not evict pods that  use hostPath or emptyDir volumes. To allow eviction of these pods, the annotation  cluster-autoscaler.kubernetes.io/safe-to-evict=true must be added to the pods. 
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/add_safe_to_evict/add_safe_to_evict.yaml" target="-blank">/best-practices/add_safe_to_evict/add_safe_to_evict.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-safe-to-evict
  annotations:
    policies.kyverno.io/category: Other
    policies.kyverno.io/subject: Pod,Annotation
    policies.kyverno.io/minversion: 1.4.3
    policies.kyverno.io/description: >-
      The Kubernetes cluster autoscaler does not evict pods that 
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
          - <(emptyDir): {}
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
          - hostPath:
              <(path): "*"

```
