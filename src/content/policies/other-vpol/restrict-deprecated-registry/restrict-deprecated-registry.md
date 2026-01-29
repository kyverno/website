---
title: 'Restrict Deprecated Registry in ValidatingPolicy'
category: validate
severity: high
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Best Practices
  - EKS Best Practices in vpol
version: 1.14.0
description: 'Legacy k8s.gcr.io container image registry will be frozen in early April 2023 k8s.gcr.io image registry will be frozen from the 3rd of April 2023.   Images for Kubernetes 1.27 will not be available in the k8s.gcr.io image registry. Please read our announcement for more details. https://kubernetes.io/blog/2023/02/06/k8s-gcr-io-freeze-announcement/     '
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/restrict-deprecated-registry/restrict-deprecated-registry.yaml" target="-blank">/other-vpol/restrict-deprecated-registry/restrict-deprecated-registry.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-deprecated-registry
  annotations:
    policies.kyverno.io/title: Restrict Deprecated Registry in ValidatingPolicy
    policies.kyverno.io/category: Best Practices, EKS Best Practices in vpol
    policies.kyverno.io/severity: high
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: 1.27-1.28
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: "Legacy k8s.gcr.io container image registry will be frozen in early April 2023 k8s.gcr.io image registry will be frozen from the 3rd of April 2023.   Images for Kubernetes 1.27 will not be available in the k8s.gcr.io image registry. Please read our announcement for more details. https://kubernetes.io/blog/2023/02/06/k8s-gcr-io-freeze-announcement/     "
spec:
  validationActions:
    - Deny
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  variables:
    - name: allContainers
      expression: object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])
  validations:
    - expression: variables.allContainers.all(container, !container.image.startsWith('k8s.gcr.io/'))
      message: The "k8s.gcr.io" image registry is deprecated. "registry.k8s.io" should now be used.

```
