---
title: 'Restrict Node Affinity in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-cel/restrict-node-affinity/restrict-node-affinity.yaml" target="-blank">/other-cel/restrict-node-affinity/restrict-node-affinity.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-node-affinity
  annotations:
    policies.kyverno.io/title: Restrict Node Affinity in CEL expressions
    policies.kyverno.io/category: Other in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/description: Pods may use several mechanisms to prefer scheduling on a set of nodes, and nodeAffinity is one of them. nodeAffinity uses expressions to select eligible nodes for scheduling decisions and may override intended placement options by cluster administrators. This policy ensures that nodeAffinity is not used in a Pod spec.
spec:
  background: true
  validationFailureAction: Audit
  rules:
    - name: check-nodeaffinity
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
            - expression: '!object.spec.?affinity.?nodeAffinity.hasValue()'
              message: Node affinity cannot be used.
```
