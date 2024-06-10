---
title: "Restrict Binding System Groups in CEL expressions"
category: Security, EKS Best Practices in CEL
version: 1.11.0
subject: RoleBinding, ClusterRoleBinding, RBAC
policyType: "validate"
description: >
    Certain system groups exist in Kubernetes which grant permissions that are used for certain system-level functions yet typically never appropriate for other users. This policy prevents creating bindings to some of these groups including system:anonymous, system:unauthenticated, and system:masters.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/restrict-binding-system-groups/restrict-binding-system-groups.yaml" target="-blank">/other-cel/restrict-binding-system-groups/restrict-binding-system-groups.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-binding-system-groups
  annotations:
    policies.kyverno.io/title: Restrict Binding System Groups in CEL expressions
    policies.kyverno.io/category: Security, EKS Best Practices in CEL 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: RoleBinding, ClusterRoleBinding, RBAC
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      Certain system groups exist in Kubernetes which grant permissions that
      are used for certain system-level functions yet typically never appropriate
      for other users. This policy prevents creating bindings to some of these
      groups including system:anonymous, system:unauthenticated, and system:masters.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: restrict-subject-groups
      match:
        any:
        - resources:
            kinds:
              - RoleBinding
              - ClusterRoleBinding
      validate:
        cel:
          expressions:
            - expression: "object.subjects.all(subject, subject.name != 'system:anonymous')"
              message: "Binding to system:anonymous is not allowed."
            - expression: "object.subjects.all(subject, subject.name != 'system:unauthenticated')"
              message: "Binding to system:unauthenticated is not allowed."
            - expression: "object.subjects.all(subject, subject.name != 'system:masters')"
              message: "Binding to system:masters is not allowed."
            

```
