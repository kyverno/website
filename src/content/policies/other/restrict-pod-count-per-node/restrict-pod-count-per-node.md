---
title: 'Restrict Pod Count per Node'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/restrict-pod-count-per-node/restrict-pod-count-per-node.yaml" target="-blank">/other/restrict-pod-count-per-node/restrict-pod-count-per-node.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-pod-count
  annotations:
    policies.kyverno.io/title: Restrict Pod Count per Node
    policies.kyverno.io/category: Sample
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/description: Sometimes Kubernetes Nodes may have a maximum number of Pods they can accommodate due to resources outside CPU and memory such as licensing, or in some development cases. This policy restricts Pod count on a Node named `minikube` to be no more than 10.
spec:
  validationFailureAction: Audit
  background: false
  rules:
    - name: restrict-pod-count
      match:
        any:
          - resources:
              kinds:
                - Pod
      context:
        - name: podcounts
          apiCall:
            urlPath: /api/v1/pods
            jmesPath: items[?spec.nodeName=='minikube'] | length(@)
      preconditions:
        any:
          - key: "{{ request.operation || 'BACKGROUND' }}"
            operator: Equals
            value: CREATE
      validate:
        message: A maximum of 10 Pods are allowed on the Node `minikube`
        deny:
          conditions:
            any:
              - key: '{{ podcounts }}'
                operator: GreaterThan
                value: 10
```
