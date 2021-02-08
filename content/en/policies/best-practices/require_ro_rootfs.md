---
type: "docs"
title: Require Read-Only Root FS
linkTitle: Require Read-Only Root FS
weight: 12
description: >
    A read-only root file system helps to enforce an immutable infrastructure strategy;  the container only needs to write on the mounted volume that persists the state.  An immutable root filesystem can also prevent malicious binaries from writing to the  host system.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/require_ro_rootfs.yaml" target="-blank">/best-practices/require_ro_rootfs.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-ro-rootfs
  annotations:
    policies.kyverno.io/title: Require Read-Only Root FS
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/description: >-
      A read-only root file system helps to enforce an immutable infrastructure strategy; 
      the container only needs to write on the mounted volume that persists the state. 
      An immutable root filesystem can also prevent malicious binaries from writing to the 
      host system.
spec:
  validationFailureAction: audit
  rules:
  - name: validate-readOnlyRootFilesystem
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Root filesystem must be read-only."
      pattern:
        spec:
          containers:
          - securityContext:
              readOnlyRootFilesystem: true
```
