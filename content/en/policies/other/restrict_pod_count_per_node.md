---
type: "docs"
title: Restrict Pod Count
linkTitle: Restrict Pod Count
weight: 26
description: >
    Sample policy to restrict pod count on node 'minikube' to be no more than 10.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict_pod_count_per_node.yaml" target="-blank">/other/restrict_pod_count_per_node.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-pod-count
  annotations:
    policies.kyverno.io/title: Restrict Pod Count per Node
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      Sample policy to restrict pod count on node 'minikube' to be no more than 10.
    pod-policies.kyverno.io/autogen-controllers: None
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: restrict-pod-count
      match:
        resources:
          kinds:
            - Pod
      context:
        - name: podcounts
          apiCall:
            urlPath: "/api/v1/pods"
            jmesPath: "items[?spec.nodeName=='minikube'] | length(@)"
      preconditions:
        - key: "{{ request.operation }}"
          operator: Equals
          value: "CREATE"
      validate:
        message: "restrict pod counts to be no more than 12 on node minikube"
        deny:
          conditions:
            - key: "{{ podcounts }}"
              operator: GreaterThanOrEquals
              value: 10
```
