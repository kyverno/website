---
title: Deleting Controller Deleted Objects
description: This metric can be used to track the number of objects deleted for configured deleting policies.
sidebar:
  order: 45
---

#### Metric Name(s)

- `kyverno_deleting_controller_deletedobjects_total`

#### Metric Value

Counter - An only-increasing integer representing the number of objects deleted by deleting policies.

#### Metric Labels

#### Metric Labels

| Label            | Allowed Values                                             | Description                                                         |
| ---------------- | ---------------------------------------------------------- | ------------------------------------------------------------------- |
| policy_type      |                                                            | `DeletingPolicy` or `NamespacedDeletingPolicy`                      |
| policy_namespace |                                                            | Namespace of the policy (empty for cluster-scoped `DeletingPolicy`) |
| policy_name      |                                                            | Name of the policy                                                  |
| resource         | "pods", "deployments", "statefulsets", "replicasets", etc. | resource of the deleted object                                      |

#### Use cases

- Monitor the number of resources deleted over time.

#### Useful Queries

- Deleted objects by resource in the last 1h:<br>
  `sum by (resource) (increase(kyverno_deleting_controller_deletedobjects_total[1h]))
`

- Deleted objects by policy in the last 24h:<br>
  `sum by (policy_namespace, policy_name) (increase(kyverno_deleting_controller_deletedobjects_total[24h]))`

- Deleted objects by namespace and resource (namespaced objects) in the last 15m:<br>
  `sum by (resource_namespace, resource) (increase(kyverno_deleting_controller_deletedobjects_total[15m]))`
