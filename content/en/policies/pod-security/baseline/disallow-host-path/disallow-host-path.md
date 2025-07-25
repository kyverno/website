---
title: "Disallow hostPath"
category: Pod Security Standards (Baseline)
version: 
subject: Pod,Volume
policyType: "validate"
description: >
    HostPath volumes let Pods use host directories and volumes in containers. Using host resources can be used to access shared data or escalate privileges and should not be allowed. This policy ensures no hostPath volumes are in use.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/baseline/disallow-host-path/disallow-host-path.yaml" target="-blank">/pod-security/baseline/disallow-host-path/disallow-host-path.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-path
  annotations:
    policies.kyverno.io/title: Disallow hostPath
    policies.kyverno.io/category: Pod Security Standards (Baseline)
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod,Volume
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    policies.kyverno.io/description: >-
      HostPath volumes let Pods use host directories and volumes in containers.
      Using host resources can be used to access shared data or escalate privileges
      and should not be allowed. This policy ensures no hostPath volumes are in use.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: host-path
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: >-
          HostPath volumes are forbidden. The field spec.volumes[*].hostPath must be unset.
        pattern:
          spec:
            =(volumes):
              - X(hostPath): "null"

```
