---
title: "Restrict Binding to Cluster-Admin in ValidatingPolicy"
category: Security in vpol
version: 1.14.0
subject: RoleBinding, ClusterRoleBinding, RBAC
policyType: "validate"
description: >
    The cluster-admin ClusterRole allows any action to be performed on any resource in the cluster and its granting should be heavily restricted. This policy prevents binding to the cluster-admin ClusterRole in RoleBinding or ClusterRoleBinding resources.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other-vpol/restrict-binding-clusteradmin/restrict-binding-clusteradmin.yaml" target="-blank">/other-vpol/restrict-binding-clusteradmin/restrict-binding-clusteradmin.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: restrict-binding-clusteradmin
  annotations:
    policies.kyverno.io/title: Restrict Binding to Cluster-Admin in ValidatingPolicy
    policies.kyverno.io/category: Security in vpol 
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: RoleBinding, ClusterRoleBinding, RBAC
    kyverno.io/kyverno-version: 1.14.0
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: >-
      The cluster-admin ClusterRole allows any action to be performed on any resource
      in the cluster and its granting should be heavily restricted. This
      policy prevents binding to the cluster-admin ClusterRole in
      RoleBinding or ClusterRoleBinding resources.
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
        resources: ["rolebindings", "clusterrolebindings"]
  validations:
            - expression: "object.roleRef.name != 'cluster-admin'"
              message: "Binding to cluster-admin is not allowed."


```
