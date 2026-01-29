---
title: 'Disallow hostPath in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
  - Volume
tags:
  - Pod Security Standards (Baseline) in ValidatingPolicy
version: 1.14.0
description: 'HostPath volumes let Pods use host directories and volumes in containers. Using host resources can be used to access shared data or escalate privileges and should not be allowed. This policy ensures no hostPath volumes are in use.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-vpol/baseline/disallow-host-path/disallow-host-path.yaml" target="-blank">/pod-security-vpol/baseline/disallow-host-path/disallow-host-path.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-host-path
  annotations:
    policies.kyverno.io/title: Disallow hostPath in ValidatingPolicy
    policies.kyverno.io/category: Pod Security Standards (Baseline) in ValidatingPolicy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod,Volume
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: 1.30+
    policies.kyverno.io/description: HostPath volumes let Pods use host directories and volumes in containers. Using host resources can be used to access shared data or escalate privileges and should not be allowed. This policy ensures no hostPath volumes are in use.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
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
  validations:
    - expression: object.spec.?volumes.orValue([]).all(volume, !has(volume.hostPath))
      message: HostPath volumes are forbidden. The field spec.volumes[*].hostPath must be unset

```
