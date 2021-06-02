---
title: kyverno_admission_review_latency_milliseconds
description: This metric can be used to track the end-to-end latencies associated with the entire individual admission review, corresponding to the incoming resource request triggering a bunch of policies and rules.
weight: 2
---

**Metric Value**

A float value representing the latency of the admission review in milliseconds.

## Use cases

* The cluster admin wants to know how fast/slow have the admission reviews been for incoming requests around “Deployment” creations in the default namespace.
* The cluster admin wants to be alerted as soon as the p95 latency of admission reviews associated with the incoming “Pod” creation requests breach a certain threshold.

## Filter Labels

| Label                        | Allowed Values                                         | Description                                                                       |
| ---------------------------- | ------------------------------------------------------ | --------------------------------------------------------------------------------- |
| cluster\_policies\_count     |                                                        | Number of cluster policies which got executed under this admission review.        |
| namespaced\_policies\_count  |                                                        | Number of namespaced policies which got executed under this admission review.     |
| validate\_rules\_count       |                                                        | Number of validate rules which got executed under this admission review.          |
| mutate\_rules\_count         |                                                        | Number of mutate rules which got executed under this admission review.            |
| generate\_rules\_count       |                                                        | Number of generate rules which got executed under this admission review.          |
| resource\_name               |                                                        | Name of the resource which is being evaluated as a part of this admission review. |
| resource\_kind               | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                             |
| resource\_namespace          |                                                        | Namspace in which this resource lies                                              |
| resource\_request\_operation | "create", "update", "delete"                           | If the requested resource is being created, updated or deleted.                   |

## Useful Queries

* Average latency associated with the admission reviews triggered by incoming resource requests, grouped by the resource:<br> 
`avg(kyverno_admission_review_latency_milliseconds{}) by (resource_type)`

* Maximum latency associated with the admission reviews triggered by incoming pod requests over last 24 hours:<br>
`max(kyverno_admission_review_latency_milliseconds{resource_type="Pod"}[24h])`

* Listing the admission request which consumed maximum amount of latency in the last 60 minutes:<br> 
`max(kyverno_admission_review_latency_milliseconds{}[60m])`
