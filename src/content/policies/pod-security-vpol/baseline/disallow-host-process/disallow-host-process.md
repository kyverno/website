---
title: 'Disallow hostProcess in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Pod Security Standards (Baseline) in ValidatingPolicy
version: 1.14.0
description: 'Windows pods offer the ability to run HostProcess containers which enables privileged access to the Windows node. Privileged access to the host is disallowed in the baseline policy. HostProcess pods are an alpha feature as of Kubernetes v1.22. This policy ensures the `hostProcess` field, if present, is set to `false`.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-vpol/baseline/disallow-host-process/disallow-host-process.yaml" target="-blank">/pod-security-vpol/baseline/disallow-host-process/disallow-host-process.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-host-process
  annotations:
    policies.kyverno.io/title: Disallow hostProcess in ValidatingPolicy
    policies.kyverno.io/category: Pod Security Standards (Baseline) in ValidatingPolicy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: 1.30+
    policies.kyverno.io/description: Windows pods offer the ability to run HostProcess containers which enables privileged access to the Windows node. Privileged access to the host is disallowed in the baseline policy. HostProcess pods are an alpha feature as of Kubernetes v1.22. This policy ensures the `hostProcess` field, if present, is set to `false`.
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
  variables:
    - name: allContainers
      expression: |-
        object.spec.containers + 
          object.spec.?initContainers.orValue([]) + 
          object.spec.?ephemeralContainers.orValue([])
  validations:
    - expression: variables.allContainers.all(container, container.?securityContext.?windowsOptions.?hostProcess.orValue(false) == false)
      message: "HostProcess containers are disallowed. The field spec.containers[*].securityContext.windowsOptions.hostProcess, spec.initContainers[*].securityContext.windowsOptions.hostProcess, and spec.ephemeralContainers[*].securityContext.windowsOptions.hostProcess must either be undefined or set to `false`. "

```
