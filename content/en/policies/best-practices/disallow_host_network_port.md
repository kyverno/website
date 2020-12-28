---
type: "docs"
title: Disallow Host Network Port
linkTitle: Disallow Host Network Port
weight: 2
description: >
    Using 'hostPort' and 'hostNetwork' allows pods to share the host network stack, allowing potential snooping of network traffic from an application pod.
---

## Category
Workload Isolation

## Definition
[/best-practices/disallow_host_network_port.yaml](https://github.com/kyverno/policies/raw/main//best-practices/disallow_host_network_port.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-network-port
  annotations:
    policies.kyverno.io/category: Workload Isolation
    policies.kyverno.io/description: Using 'hostPort' and 'hostNetwork' allows pods to share 
      the host network stack, allowing potential snooping of network traffic from an application pod.
spec:
  validationFailureAction: audit
  rules:
  - name: validate-host-network
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Use of hostNetwork is not allowed"
      pattern:
        spec:
          =(hostNetwork): false
  - name: validate-host-port
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Use of hostPort is not allowed"
      pattern:
        spec:
          containers:
          - name: "*"
            =(ports):
              - X(hostPort): null

```
