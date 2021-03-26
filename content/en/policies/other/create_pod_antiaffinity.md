---
type: "docs"
title: Insert Pod Antiaffinity
linkTitle: Insert Pod Antiaffinity
weight: 28
description: >
    Sample policy to add Pod anti-affinity
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/create_pod_antiaffinity.yaml" target="-blank">/other/create_pod_antiaffinity.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: insert-pod-antiaffinity
  annotations:
    policies.kyverno.io/title: Add Pod Anti-Affinity
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Sample policy to add Pod anti-affinity
spec:
  rules:
    - name: insert-pod-antiaffinity
      match:
        resources:
          kinds:
            - Deployment
      preconditions:
        # This precondition selects Pods with the label `app`
      - key: "{{request.object.spec.template.metadata.labels.app}}"
        operator: NotEquals
        value: ""
      # Mutates the Deployment resource to add fields.
      mutate:
        patchStrategicMerge:
          spec:
            template:
              spec:
                # Add the `affinity`if not already specified.
                +(affinity):
                  +(podAntiAffinity):
                    +(preferredDuringSchedulingIgnoredDuringExecution):
                      - weight: 1
                        podAffinityTerm:
                          topologyKey: "kubernetes.io/hostname"
                          labelSelector:
                            matchExpressions:
                            - key: app
                              operator: In
                              values:
                              - "{{request.object.metadata.labels.app}}"
```
