---
title: "Disallow hostPorts in CEL expressions"
category: Pod Security Standards (Baseline) in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    Access to host ports allows potential snooping of network traffic and should not be allowed, or at minimum restricted to a known list. This policy ensures the `hostPort` field is unset or set to `0`. 
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security-cel/baseline/disallow-host-ports/disallow-host-ports.yaml" target="-blank">/pod-security-cel/baseline/disallow-host-ports/disallow-host-ports.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-ports
  annotations:
    policies.kyverno.io/title: Disallow hostPorts in CEL expressions
    policies.kyverno.io/category: Pod Security Standards (Baseline) in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      Access to host ports allows potential snooping of network traffic and should not be
      allowed, or at minimum restricted to a known list. This policy ensures the `hostPort`
      field is unset or set to `0`. 
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: host-ports-none
      match:
        any:
        - resources:
            kinds:
              - Pod
            operations:
            - CREATE
            - UPDATE
      validate:
        cel:
          expressions:
            - expression: >- 
                object.spec.containers.all(container, !has(container.ports) || 
                container.ports.all(port, !has(port.hostPort) || port.hostPort == 0))
              message: >-
                Use of host ports is disallowed. The field spec.containers[*].ports[*].hostPort
                must either be unset or set to `0`.

            - expression: >- 
                !has(object.spec.initContainers) || 
                object.spec.initContainers.all(container, !has(container.ports) || 
                container.ports.all(port, !has(port.hostPort) || port.hostPort == 0))
              message: >-
                Use of host ports is disallowed. The field spec.initContainers[*].ports[*].hostPort
                must either be unset or set to `0`.

            - expression: >- 
                !has(object.spec.ephemeralContainers) ||
                object.spec.ephemeralContainers.all(container, !has(container.ports) ||
                container.ports.all(port, !has(port.hostPort) || port.hostPort == 0))
              message: >-
                Use of host ports is disallowed. The field spec.ephemeralContainers[*].ports[*].hostPort
                must either be unset or set to `0`.

```
