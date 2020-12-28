---
type: "docs"
title: Disallow Host Pid Ipc
linkTitle: Disallow Host Pid Ipc
weight: 18
description: >
    Sharing the host's PID namespace allows visibility of process on the host, potentially exposing process information. Sharing the host's IPC namespace allows the container process to communicate with processes on the host. To avoid pod container from having visibility to host process space, validate that 'hostPID' and 'hostIPC' are set to 'false'.
---

## Category
Workload Isolation

## Definition
[/best-practices/disallow_host_pid_ipc.yaml](https://github.com/kyverno/policies/raw/main//best-practices/disallow_host_pid_ipc.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-pid-ipc
  annotations:
    policies.kyverno.io/category: Workload Isolation
    policies.kyverno.io/description: Sharing the host's PID namespace allows visibility of process 
      on the host, potentially exposing process information. Sharing the host's IPC namespace allows 
      the container process to communicate with processes on the host. To avoid pod container from 
      having visibility to host process space, validate that 'hostPID' and 'hostIPC' are set to 'false'.
spec:
  validationFailureAction: audit
  rules:
  - name: validate-hostPID-hostIPC
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Use of host PID and IPC namespaces is not allowed"
      pattern:
        spec:
          =(hostPID): "false"
          =(hostIPC): "false"

```
