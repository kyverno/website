---
title: 'Restrict Escalation Verbs in Roles in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Role
  - ClusterRole
  - RBAC
tags:
  - Security in CEL
version: 1.11.0
description: 'The verbs `impersonate`, `bind`, and `escalate` may all potentially lead to privilege escalation and should be tightly controlled. This policy prevents use of these verbs in Role or ClusterRole resources.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-cel/restrict-escalation-verbs-roles/restrict-escalation-verbs-roles.yaml" target="-blank">/other-cel/restrict-escalation-verbs-roles/restrict-escalation-verbs-roles.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-escalation-verbs-roles
  annotations:
    policies.kyverno.io/title: Restrict Escalation Verbs in Roles in CEL expressions
    policies.kyverno.io/category: Security in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Role, ClusterRole, RBAC
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/description: The verbs `impersonate`, `bind`, and `escalate` may all potentially lead to privilege escalation and should be tightly controlled. This policy prevents use of these verbs in Role or ClusterRole resources.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: escalate
      match:
        any:
          - resources:
              kinds:
                - Role
                - ClusterRole
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          variables:
            - name: apiGroups
              expression: "['*', 'rbac.authorization.k8s.io']"
            - name: resources
              expression: "['*', 'clusterroles', 'roles']"
            - name: verbs
              expression: "['*', 'bind', 'escalate', 'impersonate']"
          expressions:
            - expression: object.rules == null ||  !object.rules.exists(rule, rule.apiGroups.exists(apiGroup, apiGroup in variables.apiGroups) && rule.resources.exists(resource, resource in variables.resources) && rule.verbs.exists(verb, verb in variables.verbs))
              message: Use of verbs `escalate`, `bind`, and `impersonate` are forbidden.
```
