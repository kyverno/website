---
title: Metrics
excerpt: Complete reference for all Kyverno metrics
sidebar:
  order: 1
---

This document provides a comprehensive reference for all metrics exposed by Kyverno. Metrics are organized by category to help you find the information you need quickly.

For information on how to set up and configure monitoring with these metrics, see the [Monitoring Guide](/docs/guides/monitoring).

---

## Policy and Rule Metrics

### Policies and Rules Count

#### Metric Name(s)

- `kyverno_policy_rule_info_total`

#### Metric Value

Gauge - `1` for rules currently actively present in the cluster.

#### Metric Labels

| Label                  | Allowed Values                   | Description                                                                                                                                   |
| ---------------------- | -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| policy_background_mode | "true", "false"                  | Policy's set background mode                                                                                                                  |
| policy_name            |                                  | Name of the policy to which the rule belongs                                                                                                  |
| policy_namespace       |                                  | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-"                     |
| policy_type            | "cluster", "namespaced"          | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                                         |
| policy_validation_mode | "enforce", "audit"               | PolicyValidationFailure action of the rule's parent policy                                                                                    |
| rule_name              |                                  | Name of the rule, in the above policy, which is evaluating in this situation                                                                  |
| rule_type              | "validate", "mutate", "generate" | Rule's behavior type.<br>For rule_execution_cause="background_scan", it will always be "validate" as background scans only run validate rules |
| status_ready           | "true", "false"                  | Readiness of the policy. When ready, the policy is able to serve admission requests                                                           |

#### Use cases

- The cluster admin wants to know the average number of cluster policies in the cluster since last 1 year.
- The cluster admin wants to track the trend of the count of policies applied in the default namespace.
- The cluster admin wants to track and see the month when the default namespace possessed the highest number of policies.

#### Useful Queries

- Tracking the count of the cluster policies currently active:<br>
  `count(count(kyverno_policy_rule_info_total{policy_type="cluster"} == 1) by (policy_name))`

- Tracking the per-minute rate (avged over 30s) at which "validate" rules (both of cluster and namespaced policies) are being added to the cluster:<br>
  `rate(kyverno_policy_rule_info_total{rule_type="validate"}[30s] == 1)*60`

- Tracking the total number of mutate rules added in the last 24hrs:<br>
  `count(kyverno_policy_rule_info_total{rule_type="mutate"}[24h]==1)`

- Tracking the total number of active policies with enforce mode and background mode:<br>
  `count(count(kyverno_policy_rule_info_total{policy_validation_mode="enforce", policy_background_mode="true"}==1) by (policy_name))`

---

### Policy and Rule Execution

#### Metric Name(s)

- `kyverno_policy_results`

#### Metric Value

Counter - An only-increasing integer representing the number of results/executions associated with the rule corresponding to a metric sample.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                                                                                                                                               |
| -------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| policy_validation_mode     | "enforce", "audit"                                     | PolicyValidationFailure action of the rule's parent policy                                                                                                                                                                                |
| policy_type                | "cluster", "namespaced"                                | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                                                                                                                                     |
| policy_background_mode     | "true", "false"                                        | Policy's set background mode                                                                                                                                                                                                              |
| policy_name                |                                                        | Name of the policy to which the rule belongs                                                                                                                                                                                              |
| policy_namespace           |                                                        | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-"                                                                                                                 |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                                                                                                                                                     |
| resource_namespace         |                                                        | Namespace in which this resource lies                                                                                                                                                                                                     |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                                                                                                                                                          |
| rule_name                  |                                                        | Name of the rule, in the above policy, which is evaluating in this situation                                                                                                                                                              |
| rule_result                | "PASS", "FAIL"                                         | Result of the rule's execution                                                                                                                                                                                                            |
| rule_type                  | "validate", "mutate", "generate"                       | Rule's behavior type.<br>For rule_execution_cause="background_scan", it will always be "validate" as background scans only run validate rules                                                                                             |
| rule_execution_cause       | "admission_request", "background_scan"                 | Identifies whether the rule is executing in response to an admission request or a periodic background scan.<br>In background scans, only validate rules whereas in the case of admission requests, all validate/mutate/generate rules run |

#### Use cases

- The admin wants to track the count of the incoming resource requests which resulted in PASS status of any cluster policy since the last 24 hrs.
- The cluster admin wants to track the count of all the Deployment objects, which when created, violated a specific cluster policy named `sample-cluster-policy`
- The cluster admin wants to track the count of all the resources belonging to the default namespace in the last 1 hr which were blocked from being created because those resource requests violated some Kyverno Policy.
- An end user has a dedicated namespace and in it, he/she is creating a big number of Kubernetes resources in one go and wants to track how many of them are violating the existing cluster policies.

#### Useful Queries

- Tracking the total number of rules which failed in the 24 hours in "default" namespace grouped by their rule types (validate, mutate, generate):<br>
  `sum(increase(kyverno_policy_results{policy_namespace="default", rule_result="fail"}[24h])) by (rule_type)`

- Tracking the per-minute rate of the number of rule executions triggered by incoming Pod requests over the cluster:<br>
  `rate(kyverno_policy_results{resource_kind="Pod", rule_execution_cause="admission_request"}[1m])*60`

- Tracking the total number of policies over the cluster running as a part of background scans over the last 2 hours:<br>
  `count(increase(kyverno_policy_results{rule_execution_cause="background_scan"}[2h]) by (policy_name))`

---

### Policy Rule Execution Latency

#### Metric Name(s)

- `kyverno_policy_execution_duration_seconds_count`
- `kyverno_policy_execution_duration_seconds_sum`
- `kyverno_policy_execution_duration_seconds_bucket`

#### Metric Value

Histogram - A float value representing the latency of the rule's execution in seconds.

See [Prometheus docs](https://prometheus.io/docs/practices/histograms/) for a detailed explanation of how histograms work.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                                                                                                                                               |
| -------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| policy_background_mode     | "true", "false"                                        | Policy's set background mode                                                                                                                                                                                                              |
| policy_name                |                                                        | Name of the policy to which the rule belongs                                                                                                                                                                                              |
| policy_namespace           |                                                        | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-"                                                                                                                 |
| policy_type                | "cluster", "namespaced"                                | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                                                                                                                                     |
| policy_validation_mode     | "enforce", "audit"                                     | PolicyValidationFailure action of the rule's parent policy                                                                                                                                                                                |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                                                                                                                                                     |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                                                                                                                                                    |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                                                                                                                                                          |
| rule_execution_cause       | "admission_request", "background_scan"                 | Identifies whether the rule is executing in response to an admission request or a periodic background scan.<br>In background scans, only validate rules whereas in the case of admission requests, all validate/mutate/generate rules run |
| rule_name                  |                                                        | Name of the rule, in the above policy, which is evaluating in this situation                                                                                                                                                              |
| rule_result                | "PASS", "FAIL"                                         | Result of the rule's execution                                                                                                                                                                                                            |
| rule_type                  | "validate", "mutate", "generate"                       | Rule's behavior type.<br>For rule_execution_cause="background_scan", it will always be "validate" as background scans only run validate rules                                                                                             |

#### Use cases

- The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
- The cluster admin wants to track the rule causing highest latency in a certain cluster policy.

#### Useful Queries

- Tracking the average latency associated with the execution of rules grouped by their rule types (validate, mutate, generate):<br>
  `avg(kyverno_policy_execution_duration_seconds{}) by (rule_type)`

- Listing the validate rule with maximum latency in the past 24h:<br>
  `max(kyverno_policy_execution_duration_seconds{rule_type="validate"}[24h])`

- Tracking the average policy-level execution latency of the enforce policies in the namespace "default":<br>
  `avg(kyverno_policy_execution_duration_seconds{policy_validation_mode="enforce", policy_namespace="default", policy_type="namespaced"}) by (policy_name)`

---

### Validating Policy Execution Latency

#### Metric Name(s)

- `kyverno_validating_policy_execution_duration_seconds_count`
- `kyverno_validating_policy_execution_duration_seconds_sum`
- `kyverno_validating_policy_execution_duration_seconds_bucket`

#### Metric Value

Histogram - A float value representing the latency of the validating policy's execution in seconds.

See [Prometheus docs](https://prometheus.io/docs/practices/histograms/) for a detailed explanation of how histograms work.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                   |
| -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| policy_background_mode     | "true", "false"                                        | Policy's set background mode                                                                                  |
| policy_name                |                                                        | Name of the policy                                                                                            |
| policy_validation_mode     | "enforce", "audit"                                     | PolicyValidationFailure action of the rule's parent policy                                                    |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "PASS", "FAIL"                                         | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
- The cluster admin wants to track the policy causing highest latency in a certain cluster policy.

#### Useful Queries

- Tracking the average latency associated with the execution of validating policies:<br>
  `avg(kyverno_validating_policy_execution_duration_seconds{})`

- Tracking the average execution latency of the deny policies:<br>
  `avg(kyverno_validating_policy_execution_duration_seconds{policy_validation_mode="Deny"})`

---

### Mutating Policy Execution Latency

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

---

### Generating Policy Execution Latency

#### Metric Name(s)

- `kyverno_generating_policy_execution_duration_seconds_count`
- `kyverno_generating_policy_execution_duration_seconds_sum`
- `kyverno_generating_policy_execution_duration_seconds_bucket`

#### Metric Value

Histogram - A float value representing the latency of the generating policy's execution in seconds.

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

- Tracking the average latency associated with the execution of generating policies:<br>
  `avg(kyverno_generating_policy_execution_duration_seconds{})`

---

### Image Validating Policy Execution Latency

#### Metric Name(s)

- `kyverno_image_validating_policy_execution_duration_seconds_count`
- `kyverno_image_validating_policy_execution_duration_seconds_sum`
- `kyverno_image_validating_policy_execution_duration_seconds_bucket`

#### Metric Value

Histogram - A float value representing the latency of the image validating policy's execution in seconds.

See [Prometheus docs](https://prometheus.io/docs/practices/histograms/) for a detailed explanation of how histograms work.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                   |
| -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| policy_background_mode     | "true", "false"                                        | Policy's set background mode                                                                                  |
| policy_name                |                                                        | Name of the policy                                                                                            |
| policy_validation_mode     | "enforce", "audit"                                     | PolicyValidationFailure action of the rule's parent policy                                                    |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "PASS", "FAIL"                                         | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
- The cluster admin wants to track the policy causing highest latency in a certain cluster policy.

#### Useful Queries

- Tracking the average latency associated with the execution of image validating policies:<br>
  `avg(kyverno_image_validating_policy_execution_duration_seconds{})`

- Tracking the average execution latency of the deny policies:<br>
  `avg(kyverno_image_validating_policy_execution_duration_seconds{policy_validation_mode="Deny"})`

---

### Policy Changes Count

#### Metric Name(s)

- `kyverno_policy_changes_total`

#### Metric Value

Counter - An only-increasing integer representing the total number of policy-level changes associated with a metric sample.

#### Metric Labels

| Label                  | Allowed Values               | Description                                                                                                               |
| ---------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| policy_background_mode | "true", "false"              | Policy's set background mode                                                                                              |
| policy_change_type     | "create", "update", "delete" | Action which happened with the policy behind this policy change.                                                          |
| policy_name            |                              | Name of the policy to which the rule belongs                                                                              |
| policy_namespace       |                              | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-" |
| policy_type            | "cluster", "namespaced"      | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                     |
| policy_validation_mode | "enforce", "audit"           | PolicyValidationFailure action of the rule's parent policy                                                                |

#### Use cases

- The cluster admin wants to track how many cluster policies have been created in the last 1 year.
- An end user wants to track how many policies (kind: Policy) have been created in their personal namespace.
- The cluster admin wants to see how many policies with `validationFailureAction: Enforce` and background mode enabled were created since last week.

#### Useful Queries

- Tracking the number of cluster policies with audit mode which were created in the last 60 minutes:<br>
  `sum(increase(kyverno_policy_changes_total{policy_type="cluster", policy_change_type="create", policy_validation_mode="audit"}[60m]))`

- Listing down all the namespaced Policies which were deleted in the "default" namespace in the last 5 minutes:<br>
  `kyverno_policy_changes_total{policy_type="namespaced", policy_namespace="default", policy_change_type="delete"}[5m]`

- Track the number of changes which happened with a cluster policy named "sample-policy":<br>
  `sum(kyverno_policy_changes_total{policy_type="cluster", policy_name="sample-policy"})`

---

## Admission Metrics

### Admission Requests Count

#### Metric Name(s)

- `kyverno_admission_requests_total`

#### Metric Value

Counter - An only-increasing integer representing the count of admission requests associated with a sample.

#### Metric Labels

| Label                      | Allowed Values                                                   | Description                                                      |
| -------------------------- | ---------------------------------------------------------------- | ---------------------------------------------------------------- |
| request_allowed            | "true", "false"                                                  | If the admission review was accepeted or rejected.               |
| request_webhook            | "ValidatingWebhookConfiguration", "MutatingWebhookConfiguration" | Type of webhook processing the admission review.                 |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc.           | Kind of this resource                                            |
| resource_namespace         |                                                                  | Namespace in which this resource lives                           |
| resource_request_operation | "create", "update", "delete"                                     | If the requested resource is being created, updated, or deleted. |

#### Use cases

- The cluster admin wants to know how many admission requests were triggered in the last 24h hence, know how active Kyverno has been.
- The cluster admin wants to know what percentage of total incoming admission requests to Kyverno correspond to the incoming resource creations.

#### Useful Queries

- Total admission requests triggered in the last 24h:<br>
  `sum(increase(kyverno_admission_requests_total{}[24h]))`

- Percentage of total incoming admission requests corresponding to resource creations:<br>
  `sum(kyverno_admission_requests_total{resource_request_operation="create"})/sum(kyverno_admission_requests_total{})`

---

### Admission Review Latency

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

- The cluster admin wants to know how fast/slow have the admission reviews been for incoming requests around "Deployment" creations in the default namespace.
- The cluster admin wants to be alerted as soon as the p95 latency of admission reviews associated with the incoming "Pod" creation requests breach a certain threshold.

#### Useful Queries

- Average latency associated with the admission reviews triggered by incoming resource requests, grouped by the resource:<br>
  `avg(kyverno_admission_review_duration_seconds{}) by (resource_type)`

- Maximum latency associated with the admission reviews triggered by incoming pod requests over last 24 hours:<br>
  `max(kyverno_admission_review_duration_seconds{resource_type="Pod"}[24h])`

- Listing the admission request which consumed maximum amount of latency in the last 60 minutes:<br>
  `max(kyverno_admission_review_duration_seconds{}[60m])`

---

## HTTP Metrics

### HTTP Requests Count

#### Metric Name(s)

- `kyverno_http_requests_total`

#### Metric Value

Counter - An only-increasing integer representing the count of http requests associated with a sample.

#### Metric Labels

| Label       | Allowed Values      | Description        |
| ----------- | ------------------- | ------------------ |
| http_method | `GET`, `POST`, etc. | HTTP method        |
| http_url    |                     | URL of the request |

#### Use cases

- The cluster admin wants to know how many http requests were triggered in the last 24h hence, know how active Kyverno has been.
- The cluster admin wants to know what percentage of total incoming http requests to Kyverno correspond to a specific HTTP method or URL.

#### Useful Queries

- Total admission requests triggered in the last 24h:<br>
  `sum(increase(kyverno_http_requests_total{}[24h]))`

- Percentage of total incoming admission requests corresponding to resource creations:<br>
  `sum(kyverno_http_requests_total{http_method="POST"})/sum(kyverno_http_requests_total{})`

---

### HTTP Requests Latency

#### Metric Name(s)

- `kyverno_http_requests_duration_seconds_count`
- `kyverno_http_requests_duration_seconds_sum`
- `kyverno_http_requests_duration_seconds_bucket`

#### Metric Value

Histogram - A float value representing the latency of the HTTP request processing in seconds.

See [Prometheus docs](https://prometheus.io/docs/practices/histograms/) for a detailed explanation of how histograms work.

#### Metric Labels

| Label       | Allowed Values      | Description        |
| ----------- | ------------------- | ------------------ |
| http_method | `GET`, `POST`, etc. | HTTP method        |
| http_url    |                     | URL of the request |

#### Use cases

- The cluster admin wants to know how fast/slow http requests are processed for a given http method.

#### Useful Queries

- Average http requests latency per http url and method:<br>
  `avg by (http_url, http_method) (kyverno_http_requests_duration_seconds_sum / kyverno_http_requests_duration_seconds_count)`

---

## Controller Metrics

### Controller Reconciliations Count

#### Metric Name(s)

- `kyverno_controller_reconcile_total`

#### Metric Value

Counter - An only-increasing integer representing the count of reconciliations performed.

#### Metric Labels

| Label           | Allowed Values | Description      |
| --------------- | -------------- | ---------------- |
| controller_name |                | Controller name. |

#### Use cases

- Troubleshoot abnormal activity.

#### Useful Queries

- Number of reconciliations per controller in the last hour:<br>
  `changes (kyverno_controller_reconcile_total[1h])`

---

### Controller Requeues Count

#### Metric Name(s)

- `kyverno_controller_requeue_total`

#### Metric Value

Counter - An only-increasing integer representing the number of items requeued.

#### Metric Labels

| Label           | Allowed Values | Description                                       |
| --------------- | -------------- | ------------------------------------------------- |
| controller_name |                | Controller name.                                  |
| num_requeues    |                | Number of consecutive requeues for the same item. |

#### Use cases

- Troubleshoot abnormal conflicts in reconciliation.

#### Useful Queries

- Number of requeues per controller in the last hour:<br>
  `changes (kyverno_controller_requeue_total[1h])`

---

### Controller Drops Count

#### Metric Name(s)

- `kyverno_controller_drop_total`

#### Metric Value

Counter - An only-increasing integer representing the number of items dropped.

#### Metric Labels

| Label           | Allowed Values | Description      |
| --------------- | -------------- | ---------------- |
| controller_name |                | Controller name. |

#### Use cases

- Check if an item was dropped in the last 1 hour.

#### Useful Queries

- Number of drops per second per controller:<br>
  `sum by (controller_name) (rate(kyverno_controller_drop_total{}[1h]))`

---

## Cleanup Metrics

### Cleanup Controller Deleted Objects

#### Metric Name(s)

- `kyverno_cleanup_controller_deletedobjects_total`

#### Metric Value

Counter - An only-increasing integer representing the number of objects deleted by the cleanup controller.

#### Metric Labels

| Label              | Allowed Values                                         | Description                                                                                                               |
| ------------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| policy_name        |                                                        | Name of the policy to which the rule belongs                                                                              |
| policy_namespace   |                                                        | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-" |
| policy_type        | "cluster", "namespaced"                                | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                     |
| resource_kind      | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                                     |
| resource_namespace |                                                        | Namespace in which this resource lives                                                                                    |

#### Use cases

- Monitor the number of resources deleted over time.

#### Useful Queries

- Number of resource cleaned up per second per cleanup policy:<br>
  `sum by (policy_name, policy_namespace, resource_kind) (rate(kyverno_cleanup_controller_deletedobjects_total{}[5m]))`

---

### Cleanup Controller Errors Count

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

---

### Cleanup TTL Controller Deleted Objects

#### Metric Name(s)

- `kyverno_ttl_controller_deletedobjects`

#### Metric Value

Counter - An only-increasing integer representing the number of objects deleted by the cleanup TTL controller.

#### Metric Labels

| Label              | Allowed Values                                                 | Description                            |
| ------------------ | -------------------------------------------------------------- | -------------------------------------- |
| resource_group     | "apps", "rbac.authorization.k8s.io", "networking.k8s.io", etc. | Group of this resource                 |
| resource_version   | "v1", "v1beta1", "v1alpha1", etc.                              | Version of this resource               |
| resource_resource  | "pods", "deployments", "statefulSets", "replicaSets", etc.     | Resource of this resource              |
| resource_namespace |                                                                | Namespace in which this resource lives |

#### Use cases

- Monitor the number of resources deleted over time by the cleanup TTL controller.

---

### Cleanup TTL Controller Errors Count

#### Metric Name(s)

- `kyverno_ttl_controller_errors`

#### Metric Value

Counter - An only-increasing integer representing the number of errors encountered by the cleanup TTL controller while trying to delete objects.

#### Metric Labels

| Label              | Allowed Values                                                 | Description                            |
| ------------------ | -------------------------------------------------------------- | -------------------------------------- |
| resource_group     | "apps", "rbac.authorization.k8s.io", "networking.k8s.io", etc. | Group of this resource                 |
| resource_version   | "v1", "v1beta1", "v1alpha1", etc.                              | Version of this resource               |
| resource_resource  | "pods", "deployments", "statefulSets", "replicaSets", etc.     | Resource of this resource              |
| resource_namespace |                                                                | Namespace in which this resource lives |

#### Use cases

- Monitor the number of failures while performing deletions by the cleanup TTL controller.

---

### Deleting Controller Deleted Objects

#### Metric Name(s)

- `kyverno_deleting_controller_deletedobjects_total`

#### Metric Value

Counter - An only-increasing integer representing the number of objects deleted by deleting policies.

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

---

### Deleting Controller Errors Count

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

---

## Other Metrics

### Client Queries

#### Metric Name(s)

- `kyverno_client_queries_total`

#### Metric Value

Counter - An only-increasing integer representing the total number of policy-level changes associated with a metric sample.

#### Metric Labels

| Label              | Allowed Values                                                                    | Description         |
| ------------------ | --------------------------------------------------------------------------------- | ------------------- |
| client_type        | dynamic, kubeclient, kyverno, policyreport                                        | Client type         |
| operation          | create, get, list, update, update_status, delete, delete_collection, watch, patch | Operation performed |
| resource_kind      |                                                                                   | Resource kind       |
| resource_namespace |                                                                                   | Resource Namespace  |

#### Use cases

- The cluster admin wants to track how many queries per second Kyverno is making to the Kubernetes API server

#### Useful Queries

- `kyverno_client_queries_total`
- `rate(kyverno_client_queries_total{client_type="dynamic"}[5m])`
- `increase(kyverno_client_queries_total{client_type="dynamic"}[5m])`

---

### Kyverno Info

#### Metric Name(s)

- `kyverno_info`

#### Metric Value

Gauge - A constant value of 1 with labels to include relevant information

#### Metric Labels

| Label   | Allowed Values | Description                           |
| ------- | -------------- | ------------------------------------- |
| version |                | Current version of Kyverno being used |

#### Use cases

- The cluster admin wants to see information related to Kyverno such as its version

#### Useful Queries

- `kyverno_info`
