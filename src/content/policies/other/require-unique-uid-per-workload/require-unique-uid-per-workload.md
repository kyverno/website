---
title: 'Require Unique UID per Workload'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Other
description: 'Two distinct workloads should not share a UID so that in a multitenant environment, applications  from different projects never run as the same user ID. When using persistent storage,  any files created by applications will also have different ownership in the file system. Running processes for applications as different user IDs means that if a security  vulnerability were ever discovered in the underlying container runtime, and an application  were able to break out of the container to the host, they would not be able to interact  with processes owned by other users, or from other applications, in other projects.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/require-unique-uid-per-workload/require-unique-uid-per-workload.yaml" target="-blank">/other/require-unique-uid-per-workload/require-unique-uid-per-workload.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-unique-uid-per-workload
  annotations:
    policies.kyverno.io/title: Require Unique UID per Workload
    policies.kyverno.io/category: Other
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Two distinct workloads should not share a UID so that in a multitenant environment, applications  from different projects never run as the same user ID. When using persistent storage,  any files created by applications will also have different ownership in the file system. Running processes for applications as different user IDs means that if a security  vulnerability were ever discovered in the underlying container runtime, and an application  were able to break out of the container to the host, they would not be able to interact  with processes owned by other users, or from other applications, in other projects.
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: '1.20'
spec:
  background: false
  validationFailureAction: Audit
  rules:
    - name: require-unique-uid
      match:
        any:
          - resources:
              kinds:
                - Pod
      context:
        - name: uidsAllPodsExceptSameOwnerAsRequestObject
          apiCall:
            urlPath: /api/v1/pods
            jmesPath: items[?@.metadata.ownerReferences == false || metadata.ownerReferences[?uid != '{{ request.object.metadata.keys(@).contains(@, 'ownerReferences') && request.object.metadata.ownerReferences[0].uid }}']].spec.containers[].securityContext.to_string(runAsUser)
      preconditions:
        all:
          - key: "{{ request.operation || 'BACKGROUND' }}"
            operator: Equals
            value: CREATE
      validate:
        message: Only cluster-unique UIDs are allowed
        deny:
          conditions:
            all:
              - key: '{{ request.object.spec.containers[].securityContext.to_string(runAsUser) }}'
                operator: AnyIn
                value: '{{ uidsAllPodsExceptSameOwnerAsRequestObject }}'
```
