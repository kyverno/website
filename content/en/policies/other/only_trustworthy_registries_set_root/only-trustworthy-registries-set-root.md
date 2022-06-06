---
title: "Only Trustworthy Registries Set Root"
category: Other
version: 1.6.0
subject: Pod
policyType: "validate"
description: >
    Some containers must be built to run as root in order to function properly, but use of those images should be carefully restricted to prevent unneeded privileges. This policy blocks any image that runs as root if it does not come from a trustworthy registry, `ghcr.io` in this case.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/only_trustworthy_registries_set_root/only-trustworthy-registries-set-root.yaml" target="-blank">/other/only_trustworthy_registries_set_root/only-trustworthy-registries-set-root.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: only-trustworthy-registries-set-root
  annotations:
    policies.kyverno.io/title: Only Trustworthy Registries Set Root
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Some containers must be built to run as root in order to function properly, but
      use of those images should be carefully restricted to prevent unneeded privileges.
      This policy blocks any image that runs as root if it does not come from a trustworthy
      registry, `ghcr.io` in this case.
spec:
  validationFailureAction: audit
  rules:
  - name: only-allow-trusted-images
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      all:
      - key: "{{request.operation}}"
        operator: NotEquals
        value: DELETE
    validate:
      message: "Images with root user are not allowed to be pulled from any registry other than ghcr.io."  
      foreach:
      - list: "request.object.spec.containers"
        context: 
        - name: imageData
          imageRegistry: 
            reference: "{{ element.image }}"
        deny:
          conditions:
            all:
              - key: "{{ imageData.configData.config.User || ''}}"
                operator: Equals
                value: ""
              - key: "{{ imageData.registry }}"
                operator: NotEquals
                value: "ghcr.io"
```
