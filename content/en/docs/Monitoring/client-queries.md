---
title: "Client Queries"
description: >
    This metric can be used to track the number of queries per second (QPS) from Kyverno.
weight: 55
---

#### Metric Name(s)

* `kyverno_client_queries_total`

#### Metric Value

Counter - An only-increasing integer representing the total number of policy-level changes associated with a metric sample.

#### Metric Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| client_type | dynamic, kubeclient, kyverno, policyreport | Client type |
| operation | create, get, list, update, update_status, delete, delete_collection, watch, patch | Operation performed |
| resource_kind | | Resource kind |
| resource_namespace | | Resource Namespace |

#### Use cases

* The cluster admin wants to track how many queries per second Kyverno is making to the Kubernetes API server

#### Useful Queries

* `kyverno_client_queries_total`
* `rate(kyverno_client_queries_total{client_type="dynamic"}[5m])`
* `increase(kyverno_client_queries_total{client_type="dynamic"}[5m])`
