---
title: "Restrict Binding to Cluster-Admin in CEL expressions"
category: Security in CEL
version: 1.11.0
subject: RoleBinding, ClusterRoleBinding, RBAC
policyType: "validate"
description: >
    The cluster-admin ClusterRole allows any action to be performed on any resource in the cluster and its granting should be heavily restricted. This policy prevents binding to the cluster-admin ClusterRole in RoleBinding or ClusterRoleBinding resources.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-cel/restrict-binding-clusteradmin/restrict-binding-clusteradmin.yaml" target="-blank">/other-cel/restrict-binding-clusteradmin/restrict-binding-clusteradmin.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-binding-clusteradmin
  annotations:
    policies.kyverno.io/title: Restrict Binding to Cluster-Admin in CEL expressions
    policies.kyverno.io/category: Security in CEL 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: RoleBinding, ClusterRoleBinding, RBAC
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/description: >-
      The cluster-admin ClusterRole allows any action to be performed on any resource
      in the cluster and its granting should be heavily restricted. This
      policy prevents binding to the cluster-admin ClusterRole in
      RoleBinding or ClusterRoleBinding resources.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: clusteradmin-bindings
      match:
        any:
        - resources:
            kinds:
              - RoleBinding
              - ClusterRoleBinding
            operations:
            - CREATE
            - UPDATE
      validate:
        cel:
          expressions:
            - expression: "object.roleRef.name != 'cluster-admin'"
              message: "Binding to cluster-admin is not allowed."


```
