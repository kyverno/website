---
title: "Restrict Binding to Cluster-Admin"
category: Security
version: 1.6.0
subject: RoleBinding, ClusterRoleBinding, RBAC
policyType: "validate"
description: >
    The cluster-admin ClusterRole allows any action to be performed on any resource in the cluster and its granting should be heavily restricted. This policy prevents binding to the cluster-admin ClusterRole in RoleBinding or ClusterRoleBinding resources.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict-binding-clusteradmin/restrict-binding-clusteradmin.yaml" target="-blank">/other/restrict-binding-clusteradmin/restrict-binding-clusteradmin.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-binding-clusteradmin
  annotations:
    policies.kyverno.io/title: Restrict Binding to Cluster-Admin
    policies.kyverno.io/category: Security
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: RoleBinding, ClusterRoleBinding, RBAC
    kyverno.io/kyverno-version: 1.6.2
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/description: >-
      The cluster-admin ClusterRole allows any action to be performed on any resource
      in the cluster and its granting should be heavily restricted. This
      policy prevents binding to the cluster-admin ClusterRole in
      RoleBinding or ClusterRoleBinding resources.
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: clusteradmin-bindings
      match:
        any:
        - resources:
            kinds:
              - RoleBinding
              - ClusterRoleBinding
      validate:
        message: "Binding to cluster-admin is not allowed."
        pattern:
          roleRef: 
            name: "!cluster-admin"
```
