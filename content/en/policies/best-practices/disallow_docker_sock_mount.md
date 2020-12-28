---
type: "docs"
title: Disallow Docker Sock Mount
linkTitle: Disallow Docker Sock Mount
weight: 1
description: >
    The Docker socket bind mount allows access to the Docker daemon on the node. This access can be used for privilege escalation and to manage containers outside of Kubernetes, and hence should not be allowed.
---

## Category
Security

## Definition
[/best-practices/disallow_docker_sock_mount.yaml](https://github.com/kyverno/policies/raw/main//best-practices/disallow_docker_sock_mount.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-docker-sock-mount
  annotations:
    policies.kyverno.io/category: Security
    policies.kyverno.io/description: The Docker socket bind mount allows access to the 
      Docker daemon on the node. This access can be used for privilege escalation and 
      to manage containers outside of Kubernetes, and hence should not be allowed.  
spec:
  validationFailureAction: audit
  rules:
  - name: validate-docker-sock-mount
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Use of the Docker Unix socket is not allowed"
      pattern:
        spec:
          =(volumes):
            - =(hostPath):
                path: "!/var/run/docker.sock"
```
