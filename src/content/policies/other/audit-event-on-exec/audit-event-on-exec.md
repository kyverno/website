---
title: 'Audit Event on Pod Exec'
category: generate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Other
version: 1.10.0
description: 'Kubernetes Events are limited in that the circumstances under which they are created cannot be changed and with what they are associated is fixed. It may be advantageous in many cases to augment these out-of-the-box Events with custom Events which can be custom designed to your needs. This policy generates an Event on a Pod when an exec has been made to it. It lists the userInfo of the actor performing the exec along with the command used in the exec.'
createdAt: "2023-04-26T15:16:40.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/audit-event-on-exec/audit-event-on-exec.yaml" target="-blank">/other/audit-event-on-exec/audit-event-on-exec.yaml</a>

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: audit-event-on-exec
  annotations:
    policies.kyverno.io/title: Audit Event on Pod Exec
    policies.kyverno.io/category: Other
    kyverno.io/kyverno-version: 1.10.0
    policies.kyverno.io/minversion: 1.10.0
    kyverno.io/kubernetes-version: "1.26"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Kubernetes Events are limited in that the circumstances under which they are created cannot be changed and with what they are associated is fixed. It may be advantageous in many cases to augment these out-of-the-box Events with custom Events which can be custom designed to your needs. This policy generates an Event on a Pod when an exec has been made to it. It lists the userInfo of the actor performing the exec along with the command used in the exec.
spec:
  background: false
  rules:
    - name: generate-event-on-exec
      match:
        any:
          - resources:
              kinds:
                - Pod/exec
      context:
        - name: parentPodUID
          apiCall:
            urlPath: /api/v1/namespaces/{{request.namespace}}/pods/{{request.name}}
            jmesPath: metadata.uid
      generate:
        apiVersion: v1
        kind: Event
        name: exec.{{ random('[a-z0-9]{6}') }}
        namespace: "{{request.namespace}}"
        synchronize: false
        data:
          firstTimestamp: "{{ time_now_utc() }}"
          involvedObject:
            apiVersion: v1
            kind: Pod
            name: "{{ request.name }}"
            namespace: "{{ request.namespace }}"
            uid: "{{ parentPodUID }}"
          lastTimestamp: "{{ time_now_utc() }}"
          message: An exec was performed by {{ request.userInfo | to_string(@) }} running commands {{ request.object.command }}
          reason: Exec
          source:
            component: kyverno
          type: Warning

```
