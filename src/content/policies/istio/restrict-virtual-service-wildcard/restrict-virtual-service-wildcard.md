---
title: 'Restrict Virtual Service Host with Wildcards'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - VirtualService
tags:
  - Istio
version: 1.6.0
description: 'Virtual Services optionally accept a wildcard as an alternative to precise matching. In some cases, this may be too permissive as it would direct unintended traffic to the given resource. This policy enforces that any Virtual Service host does not contain a wildcard character and allows for more governance when a single mesh deployment  model is used.'
createdAt: "2022-12-16T00:02:26.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/istio/restrict-virtual-service-wildcard/restrict-virtual-service-wildcard.yaml" target="-blank">/istio/restrict-virtual-service-wildcard/restrict-virtual-service-wildcard.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-virtual-service-wildcard
  annotations:
    policies.kyverno.io/title: Restrict Virtual Service Host with Wildcards
    policies.kyverno.io/category: Istio
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.8.4
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: VirtualService
    policies.kyverno.io/description: Virtual Services optionally accept a wildcard as an alternative to precise matching. In some cases, this may be too permissive as it would direct unintended traffic to the given resource. This policy enforces that any Virtual Service host does not contain a wildcard character and allows for more governance when a single mesh deployment  model is used.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: block-virtual-service-wildcard
      match:
        any:
          - resources:
              kinds:
                - VirtualService
      preconditions:
        all:
          - key: "{{ request.operation || 'BACKGROUND' }}"
            operator: AnyIn
            value:
              - CREATE
              - UPDATE
      validate:
        message: Wildcards are not permitted as hosts.
        foreach:
          - list: request.object.spec.hosts
            deny:
              conditions:
                any:
                  - key: "{{ contains(element, '*') }}"
                    operator: Equals
                    value: true

```
