---
title: 'Ensure HPA for Deployments'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Deployment
  - ReplicaSet
  - StatefulSet
  - DaemonSet
tags: []
version: 1.9.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/check-hpa-exists/check-hpa-exists.yaml" target="-blank">/other/check-hpa-exists/check-hpa-exists.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-hpa-exists
  annotations:
    policies.kyverno.io/title: Ensure HPA for Deployments
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.9.0
    kyverno.io/kubernetes-version: '1.28'
    policies.kyverno.io/subject: Deployment,ReplicaSet,StatefulSet,DaemonSet
    policies.kyverno.io/description: This policy ensures that Deployments, ReplicaSets, StatefulSets, and DaemonSets are only allowed if they have a corresponding Horizontal Pod Autoscaler (HPA) configured in the same namespace. The policy checks for the presence of an HPA that targets the resource and denies the creation or update of the resource if no such HPA exists. This policy helps enforce scaling practices and ensures that resources are managed efficiently.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: validate-hpa
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - ReplicaSet
                - StatefulSet
                - DaemonSet
      context:
        - name: hpas
          apiCall:
            urlPath: /apis/autoscaling/v1/namespaces/{{ request.namespace }}/horizontalpodautoscalers
            jmesPath: items[].spec.scaleTargetRef.name
      validate:
        message: Deployment is not allowed without a corresponding HPA.
        deny:
          conditions:
            all:
              - key: '{{ request.object.metadata.name }}'
                operator: AnyNotIn
                value: '{{ hpas }}'
```
