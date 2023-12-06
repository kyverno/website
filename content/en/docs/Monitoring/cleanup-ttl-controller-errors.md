---
title: Cleanup Controller Errors Count
description: This metric can be used to track the number of errors encountered by the cleanup TTL controller while trying to delete objects.
weight: 45
---

#### Metric Name(s)

* `kyverno_ttl_controller_errors`

#### Metric Value

Counter - An only-increasing integer representing the number of errors encountered by the cleanup TTL controller while trying to delete objects.

#### Metric Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| resource\_group | "apps", "rbac.authorization.k8s.io", "networking.k8s.io", etc. | Group of this resource |
| resource\_version | "v1", "v1beta1", "v1alpha1", etc. | Version of this resource |
| resource\_resource | "pods", "deployments", "statefulSets", "replicaSets", etc. | Resource of this resource |
| resource\_namespace | | Namespace in which this resource lives |

#### Use cases

* Monitor the number of failures while performing deletions by the cleanup TTL controller.

