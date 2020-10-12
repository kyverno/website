
---
title: "Mutate pods with emptyDir and hostPath with safe-to-evict"
linkTitle: "Mutate pods with emptyDir and hostPath with safe-to-evict"
weight: 3
description: >

---


The Kubernetes cluster autoscaler does not evict pods that use `hostPath` or `emptyDir` volumes. To allow eviction of these pods, the following annotation must be added to the pods:

````yaml
cluster-autoscaler.kubernetes.io/safe-to-evict: true
````

This policy matches and mutates pods with `emptyDir` and `hostPath` volumes, to add the `safe-to-evict` annotation if it is not specified.


## Additional Information

## Policy YAML 

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata: 
  name: add-safe-to-evict
spec: 
  rules: 
  - name: "annotate-empty-dir"
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
````

## Install Policy

```bash
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/samples/best_practices/add_safe_to_evict.yaml
```

## Test Policy

```bash
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/test/resources/pod-with-emptydir.yaml
```