---
title: 'Add Safe To Evict'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
  - Annotation
tags:
  - Other
version: 1.6.0
description: 'The Kubernetes cluster autoscaler does not evict pods that  use hostPath or emptyDir volumes. To allow eviction of these pods, the annotation  cluster-autoscaler.kubernetes.io/safe-to-evict=true must be added to the pods. '
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices/add-safe-to-evict/add-safe-to-evict.yaml" target="-blank">/best-practices/add-safe-to-evict/add-safe-to-evict.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-safe-to-evict
  annotations:
    policies.kyverno.io/title: Add Safe To Evict
    policies.kyverno.io/category: Other
    policies.kyverno.io/subject: Pod,Annotation
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: 'The Kubernetes cluster autoscaler does not evict pods that  use hostPath or emptyDir volumes. To allow eviction of these pods, the annotation  cluster-autoscaler.kubernetes.io/safe-to-evict=true must be added to the pods. '
spec:
  rules:
    - name: annotate-empty-dir
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          metadata:
            annotations:
              +(cluster-autoscaler.kubernetes.io/safe-to-evict): 'true'
          spec:
            volumes:
              - <(emptyDir): {}
    - name: annotate-host-path
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          metadata:
            annotations:
              +(cluster-autoscaler.kubernetes.io/safe-to-evict): 'true'
          spec:
            volumes:
              - hostPath:
                  <(path): '*'
```
