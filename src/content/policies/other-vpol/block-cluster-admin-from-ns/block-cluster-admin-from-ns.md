---
title: 'Block cluster-admin from modifying any object in a Namespace'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Namespace
  - ClusterRole
  - User
tags:
  - Other
version: 1.15.0
description: 'In some cases, it may be desirable to block operations of certain privileged users (i.e. cluster-admins) in a specific namespace. In this policy, Kyverno will look for all user operations (CREATE, UPDATE, DELETE), on every object kind, in the testnamespace namespace, and for the ClusterRole cluster-admin. The user testuser is also mentioned so it won''t include all the cluster-admins in the cluster, but will be flexible enough to apply only for a sub-group of the cluster-admins in the cluster.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/block-cluster-admin-from-ns/block-cluster-admin-from-ns.yaml" target="-blank">/other-vpol/block-cluster-admin-from-ns/block-cluster-admin-from-ns.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: block-cluster-admin-from-ns
  annotations:
    policies.kyverno.io/title: Block cluster-admin from modifying any object in a Namespace
    policies.kyverno.io/category: Other
    policies.kyverno.io/subject: Namespace, ClusterRole, User
    policies.kyverno.io/minversion: 1.15.0
    policies.kyverno.io/description: In some cases, it may be desirable to block operations of certain privileged users (i.e. cluster-admins) in a specific namespace. In this policy, Kyverno will look for all user operations (CREATE, UPDATE, DELETE), on every object kind, in the testnamespace namespace, and for the ClusterRole cluster-admin. The user testuser is also mentioned so it won't include all the cluster-admins in the cluster, but will be flexible enough to apply only for a sub-group of the cluster-admins in the cluster.
spec:
  validationActions:
    - Deny
  variables:
    - name: isTestUser
      expression: request.userInfo.username == "testuser"
    - name: isTestNamespace
      expression: request.namespace == "testnamespace"
    - name: hasClusterAdminRole
      expression: request.userInfo.groups.exists(group, group == "system:masters") || request.userInfo.groups.exists(group, group.contains("cluster-admin"))
    - name: isBlockedOperation
      expression: request.operation in ["CREATE", "UPDATE", "DELETE"]
  matchConstraints:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: testnamespace
    resourceRules:
      - resources:
          - "*"
        operations:
          - CREATE
          - UPDATE
          - DELETE
        apiGroups:
          - "*"
        apiVersions:
          - "*"
  validations:
    - messageExpression: "\"The cluster-admin 'testuser' user cannot touch testnamespace Namespace.\""
      expression: "!(variables.isTestUser && variables.isTestNamespace && variables.isBlockedOperation)"

```
