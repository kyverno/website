---
title: 'Restrict NetworkPolicy with Empty podSelector in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - NetworkPolicy
tags: []
version: 1.11.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-cel/restrict-networkpolicy-empty-podselector/restrict-networkpolicy-empty-podselector.yaml" target="-blank">/other-cel/restrict-networkpolicy-empty-podselector/restrict-networkpolicy-empty-podselector.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-networkpolicy-empty-podselector
  annotations:
    policies.kyverno.io/title: Restrict NetworkPolicy with Empty podSelector in CEL expressions
    policies.kyverno.io/category: Other, Multi-Tenancy in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: NetworkPolicy
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/description: By default, all pods in a Kubernetes cluster are allowed to communicate with each other, and all network traffic is unencrypted. It is recommended to not use an empty podSelector in order to more closely control the necessary traffic flows. This policy requires that all NetworkPolicies other than that of `default-deny` not use an empty podSelector.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: empty-podselector
      match:
        any:
          - resources:
              kinds:
                - NetworkPolicy
              operations:
                - CREATE
                - UPDATE
      exclude:
        any:
          - resources:
              kinds:
                - NetworkPolicy
              names:
                - default-deny
      validate:
        cel:
          expressions:
            - expression: size(object.spec.podSelector) != 0
              message: NetworkPolicies must not use an empty podSelector.

```
