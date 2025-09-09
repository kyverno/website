---
title: "Restrict Wildcards in Resources in ValidatingPolicy"
category: Security, EKS Best Practices in vpol
version: 1.14.0
subject: ClusterRole, Role, RBAC
policyType: "validate"
description: >
    Wildcards ('*') in resources grants access to all of the resources referenced by the given API group and does not follow the principal of least privilege. As much as possible, avoid such open resources unless scoped to perhaps a custom API group. This policy blocks any Role or ClusterRole that contains a wildcard entry in the resources list found in any rule.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-vpol/restrict-wildcard-resources/restrict-wildcard-resources.yaml" target="-blank">/other-vpol/restrict-wildcard-resources/restrict-wildcard-resources.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: restrict-wildcard-resources
  annotations:
    policies.kyverno.io/title: Restrict Wildcards in Resources in ValidatingPolicy
    policies.kyverno.io/category: Security, EKS Best Practices in vpol 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: ClusterRole, Role, RBAC
    kyverno.io/kyverno-version: 1.14.0
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: >-
      Wildcards ('*') in resources grants access to all of the resources referenced by
      the given API group and does not follow the principal of least privilege. As much as possible,
      avoid such open resources unless scoped to perhaps a custom API group.
      This policy blocks any Role or ClusterRole that contains a wildcard entry in
      the resources list found in any rule.
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
  validations:
            - expression: "object.rules == null || !object.rules.exists(rule, '*' in rule.resources)"
              message: "Use of a wildcard ('*') in any resources is forbidden."


```
