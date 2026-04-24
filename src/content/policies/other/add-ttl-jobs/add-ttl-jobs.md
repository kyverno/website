---
title: 'Add TTL to Jobs'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Job
tags:
  - Other
version: 1.6.0
description: 'Jobs which are user created can often pile up and consume excess space in the cluster. In Kubernetes 1.23, the TTL-after-finished controller is stable and will automatically clean up these Jobs if the ttlSecondsAfterFinished is specified. This policy adds the ttlSecondsAfterFinished field to an Job that does not have an ownerReference set if not already specified.'
createdAt: "2022-07-09T23:26:05.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/add-ttl-jobs/add-ttl-jobs.yaml" target="-blank">/other/add-ttl-jobs/add-ttl-jobs.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-ttl-jobs
  annotations:
    policies.kyverno.io/title: Add TTL to Jobs
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Job
    kyverno.io/kyverno-version: 1.7.1
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/description: Jobs which are user created can often pile up and consume excess space in the cluster. In Kubernetes 1.23, the TTL-after-finished controller is stable and will automatically clean up these Jobs if the ttlSecondsAfterFinished is specified. This policy adds the ttlSecondsAfterFinished field to an Job that does not have an ownerReference set if not already specified.
spec:
  rules:
    - name: add-ttlSecondsAfterFinished
      match:
        any:
          - resources:
              kinds:
                - Job
      preconditions:
        any:
          - key: "{{ request.object.metadata.ownerReferences || `[]` }}"
            operator: Equals
            value: []
      mutate:
        patchStrategicMerge:
          spec:
            +(ttlSecondsAfterFinished): 900

```
