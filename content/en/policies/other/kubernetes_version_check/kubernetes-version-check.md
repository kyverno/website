---
title: "Kubernetes Version Check"
category: Other
version: 1.8.0
subject: Secret
policyType: "mutate"
description: >
    It is often needed to make decisions for resources based upon the version of the Kubernetes API server in the cluster. This policy serves as an example for how to retrieve the minor version of the Kubernetes API server and subsequently use in a policy behavior. It will mutate a Secret upon its creation with a label called `apiminorversion` the value of which is the minor version of the API server.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/kubernetes_version_check/kubernetes-version-check.yaml" target="-blank">/other/kubernetes_version_check/kubernetes-version-check.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: kubernetes-version-check
  annotations:
    policies.kyverno.io/title: Kubernetes Version Check
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Secret
    kyverno.io/kyverno-version: 1.8.0-rc2
    policies.kyverno.io/minversion: 1.8.0
    kyverno.io/kubernetes-version: "1.24"
    policies.kyverno.io/description: >-
      It is often needed to make decisions for resources based upon the version
      of the Kubernetes API server in the cluster. This policy serves as an example
      for how to retrieve the minor version of the Kubernetes API server and subsequently
      use in a policy behavior. It will mutate a Secret upon its creation with a label
      called `apiminorversion` the value of which is the minor version of the API server.
spec:
  rules:
  - name: test-ver-ver
    match:
      any:
      - resources:
          kinds:
          - Secret
    preconditions:
      all:
      - key: "{{request.operation || 'BACKGROUND'}}"
        operator: In
        value:
        - CREATE
    context:
    - name: minorversion
      apiCall:
        urlPath: /version
        jmesPath: minor
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            apiminorversion: "{{minorversion}}"
```
