---
title: 'Restrict Node Affinity in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Other in Vpol
description: 'Pods may use several mechanisms to prefer scheduling on a set of nodes, and nodeAffinity is one of them. nodeAffinity uses expressions to select eligible nodes for scheduling decisions and may override intended placement options by cluster administrators. This policy ensures that nodeAffinity is not used in a Pod spec.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/restrict-node-affinity/restrict-node-affinity.yaml" target="-blank">/other-vpol/restrict-node-affinity/restrict-node-affinity.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-node-affinity
  annotations:
    policies.kyverno.io/title: Restrict Node Affinity in ValidatingPolicy
    policies.kyverno.io/category: Other in Vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: Pods may use several mechanisms to prefer scheduling on a set of nodes, and nodeAffinity is one of them. nodeAffinity uses expressions to select eligible nodes for scheduling decisions and may override intended placement options by cluster administrators. This policy ensures that nodeAffinity is not used in a Pod spec.
spec:
  evaluation:
    background:
      enabled: true
  validationActions:
    - Audit
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
  validations:
    - expression: "!object.spec.?affinity.?nodeAffinity.hasValue()"
      message: Node affinity cannot be used.

```
