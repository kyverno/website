---
title: 'Disallow Service Type LoadBalancer in CEL expressions'
category: Sample in CEL
version: 1.11.0
subject: Service
policyType: 'validate'
description: >
  Especially in cloud provider environments, a Service having type LoadBalancer will cause the provider to respond by creating a load balancer somewhere in the customer account. This adds cost and complexity to a deployment. Without restricting this ability, users may easily overrun established budgets and security practices set by the organization. This policy restricts use of the Service type LoadBalancer.
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main//other-cel/restrict-loadbalancer/restrict-loadbalancer.yaml" target="-blank">/other-cel/restrict-loadbalancer/restrict-loadbalancer.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: no-loadbalancer-service
  annotations:
    policies.kyverno.io/title: Disallow Service Type LoadBalancer in CEL expressions
    policies.kyverno.io/category: Sample in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: '1.26-1.27'
    policies.kyverno.io/description: >-
      Especially in cloud provider environments, a Service having type LoadBalancer will cause the
      provider to respond by creating a load balancer somewhere in the customer account. This adds
      cost and complexity to a deployment. Without restricting this ability, users may easily
      overrun established budgets and security practices set by the organization. This policy restricts
      use of the Service type LoadBalancer.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: no-LoadBalancer
      match:
        any:
          - resources:
              kinds:
                - Service
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: "object.spec.type != 'LoadBalancer'"
              message: 'Service of type LoadBalancer is not allowed.'
```
