---
title: 'Limit Containers per Pod in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
version: 1.11.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-cel/limit-containers-per-pod/limit-containers-per-pod.yaml" target="-blank">/other-cel/limit-containers-per-pod/limit-containers-per-pod.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: limit-containers-per-pod
  annotations:
    policies.kyverno.io/title: Limit Containers per Pod in CEL expressions
    policies.kyverno.io/category: Sample in CEL
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: Pods can have many different containers which are tightly coupled. It may be desirable to limit the amount of containers that can be in a single Pod to control best practice application or so policy can be applied consistently. This policy checks all Pods to ensure they have no more than four containers.
spec:
  validationFailureAction: Audit
  background: false
  rules:
    - name: limit-containers-per-pod
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
            - expression: size(object.spec.containers) <= 4
              message: Pods can only have a maximum of 4 containers.
```
