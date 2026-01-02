---
title: 'Ensure Read Only hostPath'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/ensure-readonly-hostpath/ensure-readonly-hostpath.yaml" target="-blank">/other/ensure-readonly-hostpath/ensure-readonly-hostpath.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: ensure-readonly-hostpath
  annotations:
    policies.kyverno.io/title: Ensure Read Only hostPath
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kyverno-version: 1.6.2
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Pods which are allowed to mount hostPath volumes in read/write mode pose a security risk even if confined to a "safe" file system on the host and may escape those confines (see https://blog.aquasec.com/kubernetes-security-pod-escape-log-mounts). The only true way to ensure safety is to enforce that all Pods mounting hostPath volumes do so in read only mode. This policy checks all containers for any hostPath volumes and ensures they are explicitly mounted in readOnly mode.
spec:
  background: false
  validationFailureAction: Audit
  rules:
    - name: ensure-hostpaths-readonly
      match:
        any:
          - resources:
              kinds:
                - Pod
      preconditions:
        all:
          - key: "{{ request.operation || 'BACKGROUND' }}"
            operator: AnyIn
            value:
              - CREATE
              - UPDATE
      validate:
        message: All hostPath volumes must be mounted as readOnly.
        foreach:
          - list: request.object.spec.volumes[?hostPath][]
            deny:
              conditions:
                any:
                  - key: "{{ request.object.spec.[containers, initContainers, ephemeralContainers][].volumeMounts[?name == '{{element.name}}'][] | length(@) }}"
                    operator: NotEquals
                    value: "{{ request.object.spec.[containers, initContainers, ephemeralContainers][].volumeMounts[?name == '{{element.name}}' && readOnly] [] | length(@) }}"

```
