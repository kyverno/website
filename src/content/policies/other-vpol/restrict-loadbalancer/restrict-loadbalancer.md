---
title: 'Disallow Service Type LoadBalancer in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Service
tags:
  - Sample in Vpol
version: 1.14.0
description: 'Especially in cloud provider environments, a Service having type LoadBalancer will cause the provider to respond by creating a load balancer somewhere in the customer account. This adds cost and complexity to a deployment. Without restricting this ability, users may easily overrun established budgets and security practices set by the organization. This policy restricts use of the Service type LoadBalancer.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/restrict-loadbalancer/restrict-loadbalancer.yaml" target="-blank">/other-vpol/restrict-loadbalancer/restrict-loadbalancer.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: no-loadbalancer-service
  annotations:
    policies.kyverno.io/title: Disallow Service Type LoadBalancer in ValidatingPolicy
    policies.kyverno.io/category: Sample in Vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: Especially in cloud provider environments, a Service having type LoadBalancer will cause the provider to respond by creating a load balancer somewhere in the customer account. This adds cost and complexity to a deployment. Without restricting this ability, users may easily overrun established budgets and security practices set by the organization. This policy restricts use of the Service type LoadBalancer.
spec:
  validationActions:
    - Audit
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
          - services
  validations:
    - expression: object.spec.type != 'LoadBalancer'
      message: Service of type LoadBalancer is not allowed.

```
