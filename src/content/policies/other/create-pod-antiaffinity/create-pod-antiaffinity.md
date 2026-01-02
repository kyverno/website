---
title: 'Add Pod Anti-Affinity'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Deployment
  - Pod
tags: []
version: 1.6.0
description: 'Applications may involve multiple replicas of the same Pod for availability as well as scale purposes, yet Kubernetes does not by default provide a solution for availability. This policy sets a Pod anti-affinity configuration on Deployments which contain an `app` label if it is not already present.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/create-pod-antiaffinity/create-pod-antiaffinity.yaml" target="-blank">/other/create-pod-antiaffinity/create-pod-antiaffinity.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: insert-pod-antiaffinity
  annotations:
    policies.kyverno.io/title: Add Pod Anti-Affinity
    policies.kyverno.io/category: Sample
    policies.kyverno.io/subject: Deployment, Pod
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: Applications may involve multiple replicas of the same Pod for availability as well as scale purposes, yet Kubernetes does not by default provide a solution for availability. This policy sets a Pod anti-affinity configuration on Deployments which contain an `app` label if it is not already present.
spec:
  rules:
    - name: insert-pod-antiaffinity
      match:
        any:
          - resources:
              kinds:
                - Deployment
      preconditions:
        all:
          - key: "{{request.object.spec.template.metadata.labels.app || ''}}"
            operator: NotEquals
            value: ''
      mutate:
        patchStrategicMerge:
          spec:
            template:
              spec:
                +(affinity):
                  +(podAntiAffinity):
                    +(preferredDuringSchedulingIgnoredDuringExecution):
                      - weight: 1
                        podAffinityTerm:
                          topologyKey: kubernetes.io/hostname
                          labelSelector:
                            matchExpressions:
                              - key: app
                                operator: In
                                values:
                                  - '{{request.object.spec.template.metadata.labels.app}}'
```
