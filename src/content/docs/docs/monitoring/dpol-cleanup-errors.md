---
title: Deleting Controller Errors Count
description: This metric can be used to track the number of errors encountered by the deleting policies while trying to delete objects.
sidebar:
  order: 46
---

#### Metric Name(s)

- `kyverno_deleting_controller_errors_total`

#### Metric Value

Counter - An only-increasing integer representing the number of errors encountered by the deleting policies while trying to delete objects.

#### Metric Labels

| Label            | Allowed Values                                             | Description                                                         |
| ---------------- | ---------------------------------------------------------- | ------------------------------------------------------------------- |
| policy_type      |                                                            | `DeletingPolicy` or `NamespacedDeletingPolicy`                      |
| policy_namespace |                                                            | Namespace of the policy (empty for cluster-scoped `DeletingPolicy`) |
| policy_name      |                                                            | Name of the policy                                                  |
| resource         | "pods", "deployments", "statefulsets", "replicasets", etc. | resource of the deleted object                                      |

#### Use cases

- Monitor the number of errors per deleting policy.
- Alert when deleting operations start failing for specific resources or namespaces.

#### Useful Queries

- Number of errors per second per deleting policy:<br>
  `sum by (policy_name, policy_namespace) (rate(kyverno_deleting_controller_errors_total{}[5m]))`
