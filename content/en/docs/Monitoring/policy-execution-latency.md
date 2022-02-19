---
title: Policy Rule Execution Latency
description: This metric can be used to track the latencies associated with the execution/processing of the individual rules whenever they evaluate incoming resource requests or execute background scans. This metric can be further aggregated to present latencies at the policy-level.
weight: 30
---

**Metric Name**

kyverno_policy_execution_duration_seconds

**Metric Value**

Histogram - A float value representing the latency of the rule's execution in seconds.

## Use cases

* The cluster admin wants to know how efficiently the policies are getting executed by tracking the average latencies associated with the Kyverno policies' execution since the last 24 hrs.
* The cluster admin wants to track the rule causing highest latency in a certain cluster policy.

## Filter Labels

| Label                             | Allowed Values                                         | Description                                                                                                                                                                                                                               |
| --------------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| policy\_validation\_mode          | "enforce", "audit"                                     | PolicyValidationFailure action of the rule's parent policy                                                                                                                                                                               |
| policy\_type                      | "cluster", "namespaced"                                | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                                                                                                                                     |
| policy\_background\_mode          | "true", "false"                                        | Policy's set background mode                                                                                                                                                                                                              |
| policy\_name                      |                                                        | Name of the policy to which the rule belongs                                                                                                                                                                                              |
| policy\_namespace                 |                                                        | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-"                                                                                                                 |
| resource\_kind                    | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                                                                                                                                                     |
| resource\_namespace               |                                                        | Namspace in which this resource lies                                                                                                                                                                                                      |
| resource\_request\_operation      | "create", "update", "delete"                           | If the requested resource is being created, updated, or deleted.                                                                                                                                                                           |
| rule\_name                        |                                                        | Name of the rule, in the above policy, which is evaluating in this situation                                                                                                                                                              |
| rule\_result                      | "PASS", "FAIL"                                         | Result of the rule's execution                                                                                                                                                                                                            |
| rule\_type                        | "validate", "mutate", "generate"                       | Rule's behavior type.<br>For rule\_execution\_cause="background\_scan", it will always be "validate" as background scans only run validate rules                                                                                         |
| rule\_execution\_cause            | "admission\_request", "background\_scan"               | Identifies whether the rule is executing in response to an admission request or a periodic background scan.<br>In background scans, only validate rules whereas in the case of admission requests, all validate/mutate/generate rules run |

## Useful Queries

* Tracking the average latency associated with the execution of rules grouped by their rule types (validate, mutate, generate):<br>
`avg(kyverno_policy_execution_duration_seconds{}) by (rule_type)`

* Listing the validate rule with maximum latency in the past 24h:<br>
`max(kyverno_policy_execution_duration_seconds{rule_type="validate"}[24h])`

* Tracking the average policy-level execution latency of the enforce policies in the namespace "default":<br>
`avg(kyverno_policy_execution_duration_seconds{policy_validation_mode="enforce", policy_namespace="default", policy_type="namespaced"}) by (policy_name)`
