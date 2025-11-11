---
title: Admission Review Latency
description: This metric can be used to track the end-to-end latencies associated with the entire individual admission review, corresponding to the incoming resource request triggering a bunch of policies and rules.
sidebar:
  order: 40
---

#### Metric Name(s)

- `kyverno_admission_review_duration_seconds_count`
- `kyverno_admission_review_duration_seconds_sum`
- `kyverno_admission_review_duration_seconds_bucket`

#### Metric Value

Histogram - A float value representing the latency of the admission review in seconds.

See [Prometheus docs](https://prometheus.io/docs/practices/histograms/) for a detailed explanation of how histograms work.

#### Metric Labels

| Label                      | Allowed Values                                                   | Description                                                      |
| -------------------------- | ---------------------------------------------------------------- | ---------------------------------------------------------------- |
| request_allowed            | "true", "false"                                                  | If the admission review was accepeted or rejected.               |
| request_webhook            | "ValidatingWebhookConfiguration", "MutatingWebhookConfiguration" | Type of webhook processing the admission review.                 |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc.           | Kind of this resource                                            |
| resource_namespace         |                                                                  | Namespace in which this resource lives                           |
| resource_request_operation | "create", "update", "delete"                                     | If the requested resource is being created, updated, or deleted. |

#### Use cases

- The cluster admin wants to know how fast/slow have the admission reviews been for incoming requests around “Deployment” creations in the default namespace.
- The cluster admin wants to be alerted as soon as the p95 latency of admission reviews associated with the incoming “Pod” creation requests breach a certain threshold.

#### Useful Queries

- Average latency associated with the admission reviews triggered by incoming resource requests, grouped by the resource:<br>
  `avg(kyverno_admission_review_duration_seconds{}) by (resource_type)`

- Maximum latency associated with the admission reviews triggered by incoming pod requests over last 24 hours:<br>
  `max(kyverno_admission_review_duration_seconds{resource_type="Pod"}[24h])`

- Listing the admission request which consumed maximum amount of latency in the last 60 minutes:<br>
  `max(kyverno_admission_review_duration_seconds{}[60m])`
