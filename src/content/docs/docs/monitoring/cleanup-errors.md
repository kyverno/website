---
title: Cleanup Controller Errors Count
description: This metric can be used to track the number of errors encountered by the cleanup controller while trying to delete objects.
sidebar:
  order: 45
---

#### Metric Name(s)

- `kyverno_cleanup_controller_errors_total`

#### Metric Value

Counter - An only-increasing integer representing the number of errors encountered by the cleanup controller while trying to delete objects.

#### Metric Labels

| Label              | Allowed Values                                         | Description                                                                                                               |
| ------------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| policy_name        |                                                        | Name of the policy to which the rule belongs                                                                              |
| policy_namespace   |                                                        | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-" |
| policy_type        | "cluster", "namespaced"                                | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                     |
| resource_kind      | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                                     |
| resource_namespace |                                                        | Namespace in which this resource lives                                                                                    |

#### Use cases

- Monitor the number of errors per cleanup policy.

#### Useful Queries

- Number of errors per second per cleanup policy:<br>
  `sum by (policy_name, policy_namespace) (rate(kyverno_cleanup_controller_errors_total{}[5m]))`
