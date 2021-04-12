---
title: "Disallow Host Ports"
linkTitle: "Disallow Host Ports"
weight: 36
repo: "https://github.com/kyverno/policies/blob/main/pod-security/default/disallow-host-ports/disallow-host-ports.yaml"
description: >
    Access to host ports allows potential snooping of network traffic and should not be allowed, or at minimum restricted to a known list.
category: Pod Security Standards (Default)
policyType: "validate"
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security/default/disallow-host-ports/disallow-host-ports.yaml" target="-blank">/pod-security/default/disallow-host-ports/disallow-host-ports.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-ports
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Default)
    policies.kyverno.io/description: >-
      Access to host ports allows potential snooping of network traffic and should not be
      allowed, or at minimum restricted to a known list.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: host-ports
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Use of host ports is disallowed. The fields spec.containers[*].ports[*].hostPort
        and spec.initContainers[*].ports[*].hostPort must be empty.
      pattern:
        spec:
          =(initContainers):
          - =(ports):
              - X(hostPort): 0
          containers:
          - =(ports):
              - X(hostPort): 0

```
