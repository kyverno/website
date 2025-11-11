---
title: Mutating Policy Execution Latency
description: This metric can be used to track the latencies associated with the execution/processing of mutating policies whenever they evaluate incoming resource requests or execute background scans.
sidebar:
  order: 50
---

#### Metric Name(s)

- `kyverno_mutating_policy_execution_duration_seconds_count`
- `kyverno_mutating_policy_execution_duration_seconds_sum`
- `kyverno_mutating_policy_execution_duration_seconds_bucket`

#### Metric Value

Histogram - A float value representing the latency of the mutating policy's execution in seconds.

See [Prometheus docs](https://prometheus.io/docs/practices/histograms/) for a detailed explanation of how histograms work.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                   |
| -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| policy_background_mode     | "true", "false"                                        | Policy's set background mode                                                                                  |
| policy_name                |                                                        | Name of the policy                                                                                            |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "PASS", "FAIL"                                         | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
- The cluster admin wants to track the policy causing highest latency in a certain cluster policy.

#### Useful Queries

- Tracking the average latency associated with the execution of mutating policies:<br>
  `avg(kyverno_mutateting_policy_execution_duration_seconds{})`
