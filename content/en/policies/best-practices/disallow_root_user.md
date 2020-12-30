---
type: "docs"
title: Disallow Root User
linkTitle: Disallow Root User
weight: 6
description: >
    By default, processes in a container run as a root user (uid 0). To prevent potential compromise of container hosts, specify a least privileged user ID when building the container image and require that application containers run as non root users.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/disallow_root_user.yaml" target="-blank">/best-practices/disallow_root_user.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-root-user
  annotations:
    policies.kyverno.io/category: Security
    policies.kyverno.io/description: By default, processes in a container run as a 
      root user (uid 0). To prevent potential compromise of container hosts, specify a 
      least privileged user ID when building the container image and require that 
      application containers run as non root users.
spec:
  validationFailureAction: audit
  rules:
  - name: validate-runAsNonRoot
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Running as root is not allowed. Set runAsNonRoot to true, or use runAsUser"
      anyPattern:
      - spec:
          securityContext:
            runAsNonRoot: true
      - spec:
          securityContext:
            runAsUser: ">0"
      - spec:
          containers:
          - securityContext:
              runAsNonRoot: true
      - spec:
          containers:
          - securityContext:
              runAsUser: ">0"
```
