---
title: Cleanup Controller Deleted Objects
description: This metric can be used to track the number of objects deleted by the cleanup controller.
weight: 45
---

#### Metric Name(s)

* `kyverno_cleanup_controller_deletedobjects_total`

#### Metric Value

Counter - An only-increasing integer representing the number of objects deleted by the cleanup controller.

#### Metric Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| policy\_name | | Name of the policy to which the rule belongs |
| policy\_namespace | | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-" |
| policy\_type | "cluster", "namespaced" | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy |
| resource\_kind | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource |
| resource\_namespace | | Namespace in which this resource lives |

#### Use cases

* Monitor the number of resources deleted over time.

#### Useful Queries

* Number of resource cleaned up per second per cleanup policy:<br> 
`sum by (policy_name, policy_namespace, resource_kind) (rate(kyverno_cleanup_controller_errors_total{}[5m]))`
