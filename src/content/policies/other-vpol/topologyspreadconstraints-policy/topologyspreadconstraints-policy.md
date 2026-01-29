---
title: 'Spread Pods Across Nodes & Zones in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Deployment
  - StatefulSet
tags:
  - Sample in Vpol
version: 1.14.0
description: 'Deployments to a Kubernetes cluster with multiple availability zones often need to distribute those replicas to align with those zones to ensure site-level failures do not impact availability. This policy ensures topologySpreadConstraints are defined,  to spread pods over nodes and zones. Deployments or Statefulsets with less than 3  replicas are skipped.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/topologyspreadconstraints-policy/topologyspreadconstraints-policy.yaml" target="-blank">/other-vpol/topologyspreadconstraints-policy/topologyspreadconstraints-policy.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: topologyspreadconstraints-policy
  annotations:
    policies.kyverno.io/title: Spread Pods Across Nodes & Zones in ValidatingPolicy
    kyverno.io/kubernetes-version: "1.30"
    kyverno.io/kyverno-version: 1.14.0
    policies.kyverno.io/category: Sample in Vpol
    policies.kyverno.io/description: Deployments to a Kubernetes cluster with multiple availability zones often need to distribute those replicas to align with those zones to ensure site-level failures do not impact availability. This policy ensures topologySpreadConstraints are defined,  to spread pods over nodes and zones. Deployments or Statefulsets with less than 3  replicas are skipped.
    policies.kyverno.io/minversion: 1.14.0
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Deployment, StatefulSet
spec:
  evaluation:
    background:
      enabled: true
  validationActions:
    - Audit
  matchConstraints:
    resourceRules:
      - apiGroups:
          - apps
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - deployments
          - statefulsets
  matchConditions:
    - name: replicas-must-be-3-or-more
      expression: object.spec.replicas >= 3
  validations:
    - expression: size(object.spec.template.spec.?topologySpreadConstraints.orValue([]).filter(t, t.topologyKey == 'kubernetes.io/hostname' || t.topologyKey == 'topology.kubernetes.io/zone')) == 2
      message: topologySpreadConstraint for kubernetes.io/hostname & topology.kubernetes.io/zone are required

```
