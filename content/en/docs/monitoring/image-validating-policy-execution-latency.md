---
title: Image Validating Policy Execution Latency
description: This metric can be used to track the latencies associated with the execution/processing of image validating policies whenever they evaluate incoming resource requests or execute background scans.
weight: 50
---

#### Metric Name(s)

* `kyverno_image_validating_policy_execution_duration_seconds_count`
* `kyverno_image_validating_policy_execution_duration_seconds_sum`
* `kyverno_image_validating_policy_execution_duration_seconds_bucket`

#### Metric Value

Histogram - A float value representing the latency of the image validating policy's execution in seconds.

See [Prometheus docs](https://prometheus.io/docs/practices/histograms/) for a detailed explanation of how histograms work.

#### Metric Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| policy\_background\_mode | "true", "false" | Policy's set background mode |
| policy\_name | | Name of the policy |
| policy\_validation\_mode | "enforce", "audit" | PolicyValidationFailure action of the rule's parent policy |
| resource\_kind | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource |
| resource\_namespace | | Namespace in which this resource lives |
| resource\_request\_operation | "create", "update", "delete" | If the requested resource is being created, updated, or deleted. |
| execution\_cause | "admission\_request", "background\_scan" | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result | "PASS", "FAIL" | Result of the policy's execution |

#### Use cases

* The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
* The cluster admin wants to track the policy causing highest latency in a certain cluster policy.

#### Useful Queries

* Tracking the average latency associated with the execution of image validating policies:<br>
`avg(kyverno_image_validating_policy_execution_duration_seconds{})`

* Tracking the average execution latency of the deny policies:<br>
`avg(kyverno_image_validating_policy_execution_duration_seconds{policy_validation_mode="Deny"})`
