---
title: 'Remove hostPath Volumes'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
  - Volume
tags:
  - Other
version: 1.10.0
description: 'Pods which mount hostPath volumes are provided access to the underlying filesystem of the Node on which they run. In most scenarios, this should be forbidden. In others, it may be useful to silently remove those hostPath volumes rather than blocking the Pod. This policy removes all hostPath volumes and their volumeMount references from all containers within a Pod.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/remove-hostpath-volumes/remove-hostpath-volumes.yaml" target="-blank">/other/remove-hostpath-volumes/remove-hostpath-volumes.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: remove-hostpath-volumes
  annotations:
    policies.kyverno.io/title: Remove hostPath Volumes
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod,Volume
    kyverno.io/kyverno-version: 1.10.0
    policies.kyverno.io/minversion: 1.10.0
    kyverno.io/kubernetes-version: "1.25"
    policies.kyverno.io/description: Pods which mount hostPath volumes are provided access to the underlying filesystem of the Node on which they run. In most scenarios, this should be forbidden. In others, it may be useful to silently remove those hostPath volumes rather than blocking the Pod. This policy removes all hostPath volumes and their volumeMount references from all containers within a Pod.
spec:
  background: false
  rules:
    - name: remove-hostpath-all
      match:
        any:
          - resources:
              kinds:
                - Pod
      context:
        - name: hostpathvolnames
          variable:
            jmesPath: request.object.spec.volumes[?hostPath].name
      preconditions:
        all:
          - key: "{{ length(hostpathvolnames) }}"
            operator: GreaterThan
            value: 0
      mutate:
        foreach:
          - list: request.object.spec.volumes[]
            order: Descending
            preconditions:
              all:
                - key: hostPath
                  operator: AnyIn
                  value: "{{ element.keys(@) }}"
            patchesJson6902: |-
              - path: /spec/volumes/{{elementIndex}}
                op: remove
          - list: request.object.spec.containers[]
            foreach:
              - list: " element.volumeMounts || `[]` "
                order: Descending
                preconditions:
                  all:
                    - key: "{{element.name}}"
                      operator: AnyIn
                      value: "{{ hostpathvolnames }}"
                patchesJson6902: |-
                  - path: /spec/containers/{{elementIndex0}}/volumeMounts/{{elementIndex1}}
                    op: remove

```
