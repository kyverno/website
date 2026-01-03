---
title: 'Block Large Images'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Other
version: 1.6.0
description: 'Pods which run containers of very large image size take longer to pull and require more space to store. A user may either inadvertently or purposefully name an image which is unusually large to disrupt operations. This policy checks the size of every container image and blocks if it is over 2 Gibibytes.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/block-large-images/block-large-images.yaml" target="-blank">/other/block-large-images/block-large-images.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-large-images
  annotations:
    policies.kyverno.io/title: Block Large Images
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Pods which run containers of very large image size take longer to pull and require more space to store. A user may either inadvertently or purposefully name an image which is unusually large to disrupt operations. This policy checks the size of every container image and blocks if it is over 2 Gibibytes.
spec:
  validationFailureAction: Audit
  rules:
    - name: block-over-twogi
      match:
        any:
          - resources:
              kinds:
                - Pod
      preconditions:
        all:
          - key: "{{request.operation || 'BACKGROUND'}}"
            operator: NotEquals
            value: DELETE
      validate:
        message: images with size greater than 2Gi not allowed
        foreach:
          - list: request.object.spec.containers
            context:
              - name: imageSize
                imageRegistry:
                  reference: "{{ element.image }}"
                  jmesPath: to_string(sum(manifest.layers[*].size))
            deny:
              conditions:
                all:
                  - key: 2Gi
                    operator: LessThan
                    value: "{{imageSize}}"

```
