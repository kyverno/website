---
title: 'Check Kasten Policy RPO based on Namespace Label'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Policy
tags:
  - Veeam Kasten
version: 1.12.0
description: 'Kasten Policy resources can be required to adhere to common Recovery Point Objective (RPO) best practices.  This example policy validates that the Policy is set to run hourly if it explicitly protects any namespaces containing the `appPriority=critical` label. This policy can be adapted to enforce any Kasten Policy requirements based on a namespace label.'
createdAt: "2024-05-08T20:30:41.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/kasten/kasten-hourly-rpo/kasten-hourly-rpo.yaml" target="-blank">/kasten/kasten-hourly-rpo/kasten-hourly-rpo.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: kasten-hourly-rpo
  annotations:
    policies.kyverno.io/title: Check Kasten Policy RPO based on Namespace Label
    policies.kyverno.io/category: Veeam Kasten
    kyverno.io/kyverno-version: 1.12.1
    policies.kyverno.io/minversion: 1.12.0
    kyverno.io/kubernetes-version: 1.24-1.30
    policies.kyverno.io/subject: Policy
    policies.kyverno.io/description: Kasten Policy resources can be required to adhere to common Recovery Point Objective (RPO) best practices.  This example policy validates that the Policy is set to run hourly if it explicitly protects any namespaces containing the `appPriority=critical` label. This policy can be adapted to enforce any Kasten Policy requirements based on a namespace label.
spec:
  validationFailureAction: Enforce
  rules:
    - name: kasten-hourly-rpo
      match:
        any:
          - resources:
              kinds:
                - config.kio.kasten.io/v1alpha1/Policy
      context:
        - name: namespacesWithPriorityLabel
          apiCall:
            urlPath: /api/v1/namespaces?labelSelector=appPriority%3Dcritical
            jmesPath: items[].metadata.name
      preconditions:
        any:
          - key: "{{ length(namespacesWithPriorityLabel) }}"
            operator: GreaterThan
            value: 0
      validate:
        message: Mission Critical RPO frequency should use no shorter than @hourly frequency
        foreach:
          - list: request.object.spec.selector.matchExpressions[0].values
            deny:
              conditions:
                all:
                  - key: "{{ element }}"
                    operator: AnyIn
                    value: "{{ namespacesWithPriorityLabel }}"
                  - key: "{{ request.object.spec.frequency }}"
                    operator: NotEquals
                    value: "@hourly"

```
