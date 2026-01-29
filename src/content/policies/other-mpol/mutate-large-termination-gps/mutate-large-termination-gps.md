---
title: 'Mutate termination Grace Periods Seconds'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
tags:
  - Sample
version: 1.15.0
description: 'Pods with large terminationGracePeriodSeconds (tGPS) might prevent cluster nodes from getting drained, ultimately making the whole cluster unstable. This policy mutates all incoming Pods to set their tGPS under 50s. If the user creates a pod without specifying tGPS, then the Kubernetes default of 30s is maintained.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-mpol/mutate-large-termination-gps/mutate-large-termination-gps.yaml" target="-blank">/other-mpol/mutate-large-termination-gps/mutate-large-termination-gps.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: mutate-termination-grace-period-seconds
  annotations:
    policies.kyverno.io/title: Mutate termination Grace Periods Seconds
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.15.0
    policies.kyverno.io/minversion: 1.15.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Pods with large terminationGracePeriodSeconds (tGPS) might prevent cluster nodes from getting drained, ultimately making the whole cluster unstable. This policy mutates all incoming Pods to set their tGPS under 50s. If the user creates a pod without specifying tGPS, then the Kubernetes default of 30s is maintained.
spec:
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  evaluation:
    admission:
      enabled: true
    mutateExisting:
      enabled: false
  matchConditions:
    - name: tgps-greater-than-50
      expression: has(object.spec.terminationGracePeriodSeconds) &&  object.spec.terminationGracePeriodSeconds > 50
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            spec: Object.spec{
              terminationGracePeriodSeconds: 50
            }
          }

```
