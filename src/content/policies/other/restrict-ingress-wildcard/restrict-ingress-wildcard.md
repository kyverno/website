---
title: 'Restrict Ingress Host with Wildcards'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Ingress
tags:
  - Other
version: 1.6.0
description: 'Ingress hosts optionally accept a wildcard as an alternative to precise matching. In some cases, this may be too permissive as it would direct unintended traffic to the given Ingress resource. This policy enforces that any Ingress host does not contain a wildcard character.'
createdAt: "2022-05-01T20:08:48.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/restrict-ingress-wildcard/restrict-ingress-wildcard.yaml" target="-blank">/other/restrict-ingress-wildcard/restrict-ingress-wildcard.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-ingress-wildcard
  annotations:
    policies.kyverno.io/title: Restrict Ingress Host with Wildcards
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.2
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Ingress
    policies.kyverno.io/description: Ingress hosts optionally accept a wildcard as an alternative to precise matching. In some cases, this may be too permissive as it would direct unintended traffic to the given Ingress resource. This policy enforces that any Ingress host does not contain a wildcard character.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: block-ingress-wildcard
      match:
        any:
          - resources:
              kinds:
                - Ingress
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
          - list: request.object.spec.rules
            deny:
              conditions:
                any:
                  - key: "{{ contains(element.host, '*') }}"
                    operator: Equals
                    value: true

```
