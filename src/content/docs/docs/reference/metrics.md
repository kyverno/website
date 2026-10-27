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
| policy_namespace           |                                                        | Namespace in which this policy resides. For cluster-scoped policies, this field will be empty                 |
| policy_validation_mode     | "Audit", "Deny"                                        | The policy's configured `validationActions`                                                                   |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "pass", "fail", "warning", "error", "skip"             | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
- The cluster admin wants to track the policy causing highest latency in a certain cluster policy.

#### Useful Queries

- Tracking the average latency associated with the execution of validating policies:<br>
  `avg(kyverno_validating_policy_execution_duration_seconds{})`

- Tracking the average execution latency of the deny policies:<br>
  `avg(kyverno_validating_policy_execution_duration_seconds{policy_validation_mode="Deny"})`

---

### Validating Policy Results

#### Metric Name(s)

- `kyverno_validating_policy_results_total`

#### Metric Value

Counter - An only-increasing integer representing the number of results associated with the validating policy's execution.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                   |
| -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| policy_validation_mode     | "Audit", "Deny"                                        | The policy's configured `validationActions`                                                                   |
| policy_background_mode     | "true", "false"                                        | Policy's set background mode                                                                                  |
| policy_name                |                                                        | Name of the policy                                                                                            |
| policy_namespace           |                                                        | Namespace in which this policy resides. For cluster-scoped policies, this field will be empty                 |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "pass", "fail", "warning", "error", "skip"             | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to track the count of incoming resource requests which resulted in a pass or fail result for a validating policy.
- The cluster admin wants to compare admission-time enforcement against background-scan findings for the same policy.

#### Useful Queries

- Tracking the total number of validating policy failures in the last 24 hours, grouped by policy:<br>
  `sum(increase(kyverno_validating_policy_results_total{result="fail"}[24h])) by (policy_name)`

- Tracking the per-minute rate of validating policy results triggered by admission requests:<br>
  `rate(kyverno_validating_policy_results_total{execution_cause="admission_request"}[1m])*60`

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
| policy_namespace           |                                                        | Namespace in which this policy resides. For cluster-scoped policies, this field will be empty                 |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "pass", "fail", "warning", "error", "skip"             | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
- The cluster admin wants to track the policy causing highest latency in a certain cluster policy.

#### Useful Queries

- Tracking the average latency associated with the execution of mutating policies:<br>
  `avg(kyverno_mutateting_policy_execution_duration_seconds{})`

---

### Mutating Policy Results

#### Metric Name(s)

- `kyverno_mutating_policy_results_total`

#### Metric Value

Counter - An only-increasing integer representing the number of results associated with the mutating policy's execution.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                   |
| -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| policy_background_mode     | "true", "false"                                        | Policy's set background mode                                                                                  |
| policy_name                |                                                        | Name of the policy                                                                                            |
| policy_namespace           |                                                        | Namespace in which this policy resides. For cluster-scoped policies, this field will be empty                 |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "pass", "fail", "warning", "error", "skip"             | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to track the count of incoming resource requests which resulted in a pass or fail result for a mutating policy.
- The cluster admin wants to know how many resources a specific mutating policy has actually mutated versus skipped.

#### Useful Queries

- Tracking the total number of mutating policy failures in the last 24 hours, grouped by policy:<br>
  `sum(increase(kyverno_mutating_policy_results_total{result="fail"}[24h])) by (policy_name)`

- Tracking the per-minute rate of mutating policy results triggered by admission requests:<br>
  `rate(kyverno_mutating_policy_results_total{execution_cause="admission_request"}[1m])*60`

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

| Label                      | Allowed Values                                         | Description                                                                                                                                                                                          |
| -------------------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| policy_name                |                                                        | Name of the policy                                                                                                                                                                                   |
| policy_namespace           |                                                        | Namespace in which this policy resides. For cluster-scoped policies, this field will be empty                                                                                                        |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                                                                                                                |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                                                                                                               |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                                                                                                                     |
| execution_cause            | "background_scan"                                      | Generating policies are only ever processed asynchronously via UpdateRequest reconciliation, never inside a live admission response, so this label is currently always fixed to `"background_scan"`. |
| result                     | "pass", "fail", "warning", "error", "skip"             | Result of the policy's execution                                                                                                                                                                     |

#### Use cases

- The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
- The cluster admin wants to track the policy causing highest latency in a certain cluster policy.

#### Useful Queries

- Tracking the average latency associated with the execution of generating policies:<br>
  `avg(kyverno_generating_policy_execution_duration_seconds{})`

---

### Generating Policy Results

#### Metric Name(s)

- `kyverno_generating_policy_results_total`

#### Metric Value

Counter - An only-increasing integer representing the number of results associated with the generating policy's execution.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                                                                                                          |
| -------------------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| policy_name                |                                                        | Name of the policy                                                                                                                                                                                   |
| policy_namespace           |                                                        | Namespace in which this policy resides. For cluster-scoped policies, this field will be empty                                                                                                        |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of the trigger resource                                                                                                                                                                         |
| resource_namespace         |                                                        | Namespace in which the trigger resource lives                                                                                                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the triggering resource request was a create, update, or delete.                                                                                                                                  |
| execution_cause            | "background_scan"                                      | Generating policies are only ever processed asynchronously via UpdateRequest reconciliation, never inside a live admission response, so this label is currently always fixed to `"background_scan"`. |
| result                     | "pass", "fail", "warning", "error", "skip"             | Result of the policy's execution                                                                                                                                                                     |

#### Use cases

- The cluster admin wants to track the count of generation results which resulted in a pass or fail result for a generating policy.
- The cluster admin wants to know how many downstream resources a specific generating policy has produced versus failed to produce.

#### Useful Queries

- Tracking the total number of generating policy failures in the last 24 hours, grouped by policy:<br>
  `sum(increase(kyverno_generating_policy_results_total{result="fail"}[24h])) by (policy_name)`

- Tracking the per-minute rate of generating policy results:<br>
  `rate(kyverno_generating_policy_results_total[1m])*60`

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
| policy_namespace           |                                                        | Namespace in which this policy resides. For cluster-scoped policies, this field will be empty                 |
| policy_validation_mode     | "Audit", "Deny"                                        | The policy's configured `validationActions`                                                                   |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "pass", "fail", "warning", "error", "skip"             | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
- The cluster admin wants to track the policy causing highest latency in a certain cluster policy.

#### Useful Queries

- Tracking the average latency associated with the execution of image validating policies:<br>
  `avg(kyverno_image_validating_policy_execution_duration_seconds{})`

- Tracking the average execution latency of the deny policies:<br>
  `avg(kyverno_image_validating_policy_execution_duration_seconds{policy_validation_mode="Deny"})`

---

### Image Validating Policy Results

#### Metric Name(s)

- `kyverno_image_validating_policy_results_total`

#### Metric Value

Counter - An only-increasing integer representing the number of results associated with the image validating policy's execution.

#### Metric Labels

| Label                      | Allowed Values                                         | Description                                                                                                   |
| -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| policy_background_mode     | "true", "false"                                        | Policy's set background mode                                                                                  |
| policy_name                |                                                        | Name of the policy                                                                                            |
| policy_namespace           |                                                        | Namespace in which this policy resides. For cluster-scoped policies, this field will be empty                 |
| policy_validation_mode     | "Audit", "Deny"                                        | The policy's configured `validationActions`                                                                   |
| resource_kind              | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                         |
| resource_namespace         |                                                        | Namespace in which this resource lives                                                                        |
| resource_request_operation | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                              |
| execution_cause            | "admission_request", "background_scan"                 | Identifies whether the policy is executing in response to an admission request or a periodic background scan. |
| result                     | "pass", "fail", "warning", "error", "skip"             | Result of the policy's execution                                                                              |

#### Use cases

- The cluster admin wants to track the count of image verification results which resulted in a pass or fail result for an image validating policy.
- The cluster admin wants to compare admission-time image verification against background-scan findings for the same policy.

#### Useful Queries

- Tracking the total number of image validating policy failures in the last 24 hours, grouped by policy:<br>
  `sum(increase(kyverno_image_validating_policy_results_total{result="fail"}[24h])) by (policy_name)`

- Tracking the per-minute rate of image validating policy results triggered by admission requests:<br>
  `rate(kyverno_image_validating_policy_results_total{execution_cause="admission_request"}[1m])*60`

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
