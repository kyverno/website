---
title: Policy and Rule Execution
description: This metric can be used to track the results associated with the rules executing as a part of incoming resource requests and even background scans. This metric can be further aggregated to track policy-level results as well.
weight: 20
---

**Metric Name**

`kyverno_policy_results_total`

**Metric Value**

Counter - An only-increasing integer representing the number of results/executions associated with the rule corresponding to a metric sample.

## Use cases

* The admin wants to track the count of the incoming resource requests which resulted in PASS status of any cluster policy since the last 24 hrs.
* The cluster admin wants to track the count of all the Deployment objects, which when created, violated a specific cluster policy named `sample-cluster-policy`
* The cluster admin wants to track the count of all the resources belonging to the default namespace in the last 1 hr which were blocked from being created because those resource requests violated some Kyverno Policy.
* An end user has a dedicated namespace and in it, he/she is creating a big number of Kubernetes resources in one go and wants to track how many of them are violating the existing cluster policies.

## Filter Labels

| Label | Allowed Values | Description |
| --- | --- | --- |
| policy\_validation\_mode | "enforce", "audit" | PolicyValidationFailure action of the rule's parent policy |
| policy\_type | "cluster", "namespaced" | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy |
| policy\_background\_mode | "true", "false" | Policy's set background mode |
| policy\_name | | Name of the policy to which the rule belongs |
| policy\_namespace | | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-" |
| resource\_kind | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource |
| resource\_namespace | | Namespace in which this resource lies |
| resource\_request\_operation | "create", "update", "delete" | If the requested resource is being created, updated, or deleted. |
| rule\_name | | Name of the rule, in the above policy, which is evaluating in this situation |
| rule\_result | "PASS", "FAIL" | Result of the rule's execution |
| rule\_type | "validate", "mutate", "generate" | Rule's behavior type.<br>For rule\_execution\_cause="background\_scan", it will always be "validate" as background scans only run validate rules |
| rule\_execution\_cause | "admission\_request", "background\_scan" | Identifies whether the rule is executing in response to an admission request or a periodic background scan.<br>In background scans, only validate rules whereas in the case of admission requests, all validate/mutate/generate rules run |

## Useful Queries

* Tracking the total number of rules which failed in the 24 hours in "default" namespace grouped by their rule types (validate, mutate, generate):<br>
`sum(increase(kyverno_policy_results_total{policy_namespace="default", rule_result="fail"}[24h])) by (rule_type)`

* Tracking the per-minute rate of the number of rule executions triggered by incoming Pod requests over the cluster:<br>
`rate(kyverno_policy_results_total{resource_kind="Pod", rule_execution_cause="admission_request"}[1m])*60`

* Tracking the total number of policies over the cluster running as a part of background scans over the last 2 hours:<br>
`count(increase(kyverno_policy_results_total{rule_execution_cause="background_scan"}[2h]) by (policy_name))`
