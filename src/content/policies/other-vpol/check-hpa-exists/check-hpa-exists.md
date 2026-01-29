---
title: 'Ensure HPA for Deployments'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Deployment
  - ReplicaSet
  - StatefulSet
  - DaemonSet
tags:
  - Other
description: 'This policy ensures that Deployments, ReplicaSets, StatefulSets, and DaemonSets are only allowed if they have a corresponding Horizontal Pod Autoscaler (HPA) configured in the same namespace. The policy checks for the presence of an HPA that targets the resource and denies the creation or update of the resource if no such HPA exists. This policy helps enforce scaling practices and ensures that resources are managed efficiently.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/check-hpa-exists/check-hpa-exists.yaml" target="-blank">/other-vpol/check-hpa-exists/check-hpa-exists.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: check-hpa-exists
  annotations:
    policies.kyverno.io/title: Ensure HPA for Deployments
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/subject: Deployment,ReplicaSet,StatefulSet,DaemonSet
    policies.kyverno.io/description: This policy ensures that Deployments, ReplicaSets, StatefulSets, and DaemonSets are only allowed if they have a corresponding Horizontal Pod Autoscaler (HPA) configured in the same namespace. The policy checks for the presence of an HPA that targets the resource and denies the creation or update of the resource if no such HPA exists. This policy helps enforce scaling practices and ensures that resources are managed efficiently.
spec:
  validationActions:
    - Audit
  variables:
    - name: hpaList
      expression: resource.List('autoscaling/v1', 'horizontalpodautoscalers', object.metadata.namespace).items.orValue([])
  matchConstraints:
    resourceRules:
      - resources:
          - deployments
          - replicasets
          - statefulsets
          - daemonsets
        operations:
          - CREATE
          - UPDATE
        apiGroups:
          - apps
        apiVersions:
          - v1
  validations:
    - message: Resource is not allowed without a corresponding HPA.
      expression: variables.hpaList.exists(hpa, hpa.spec.scaleTargetRef.name == object.metadata.name)

```
