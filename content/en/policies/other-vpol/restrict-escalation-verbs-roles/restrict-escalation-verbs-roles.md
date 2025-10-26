---
title: "Restrict Escalation Verbs in Roles in ValidatingPolicy"
category: Security in vpol
version: 1.14.0
subject: Role, ClusterRole, RBAC
policyType: "validate"
description: >
    The verbs `impersonate`, `bind`, and `escalate` may all potentially lead to privilege escalation and should be tightly controlled. This policy prevents use of these verbs in Role or ClusterRole resources.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-vpol/restrict-escalation-verbs-roles/restrict-escalation-verbs-roles.yaml" target="-blank">/other-vpol/restrict-escalation-verbs-roles/restrict-escalation-verbs-roles.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: restrict-escalation-verbs-roles
  annotations:
    policies.kyverno.io/title: Restrict Escalation Verbs in Roles in ValidatingPolicy
    policies.kyverno.io/category: Security in vpol 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Role, ClusterRole, RBAC
    kyverno.io/kyverno-version: 1.14.0
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: >-
      The verbs `impersonate`, `bind`, and `escalate` may all potentially lead to
      privilege escalation and should be tightly controlled. This policy prevents
      use of these verbs in Role or ClusterRole resources.
spec:
  validationActions: 
    - Audit
  evaluation:
    background:
      enabled: true  
  matchConstraints:
    resourceRules:
      - apiGroups: ["rbac.authorization.k8s.io"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["roles", "clusterroles"]
  variables:
            - name: apiGroups
              expression: "['*', 'rbac.authorization.k8s.io']"
            - name: resources
              expression: "['*', 'clusterroles', 'roles']"
            - name: verbs
              expression: "['*', 'bind', 'escalate', 'impersonate']"
  validations:
            - expression: >-
                object.rules == null || 
                !object.rules.exists(rule,
                rule.apiGroups.exists(apiGroup, apiGroup in variables.apiGroups) &&
                rule.resources.exists(resource, resource in variables.resources) &&
                rule.verbs.exists(verb, verb in variables.verbs))
              message: "Use of verbs `escalate`, `bind`, and `impersonate` are forbidden."


```
