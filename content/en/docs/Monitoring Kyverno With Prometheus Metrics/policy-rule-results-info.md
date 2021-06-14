---
title: Information around results of Rule/Policy executions
description: This metric can be used to track the results associated with the rule executing as a part of incoming resource requests and even background scans.
weight: 20
---

**Metric Name**

kyverno_policy_rule_results_info

**Metric Value**

1 - Constant value serving no purpose

## Use cases

* The admin wants to track the count of the incoming resource requests which resulted in PASS status of any cluster policy since the last 24 hrs.
* The cluster admin wants to track the count of all the Deployment objects, which when created, violated a specific cluster policy named “sample-cluster-policy” 
* The cluster admin wants to track the count of all the resources belonging to the default namespace in the last 1 hr which were blocked from being created because those resource requests violated some Kyverno Policy.
* An end user has a dedicated namespace and in it, he/she is creating a big number of k8s resources in one go and wants to track how many of them are violating the existing cluster policies.


## Filter Labels

| Label                             | Allowed Values                                         | Description                                                                                                                                                                                                                               |
| --------------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| policy\_validation\_mode          | "enforce", "audit"                                     | PolicyValidationFailure action of the rule's parent policy                                                                                                                                                                               |
| policy\_type                      | "cluster", "namespaced"                                | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                                                                                                                                     |
| policy\_background\_mode          | "true", "false"                                        | Policy's set background mode                                                                                                                                                                                                              |
| policy\_name                      |                                                        | Name of the policy to which the rule belongs                                                                                                                                                                                              |
| policy\_namespace                 |                                                        | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-"                                                                                                                 |
| resource\_name                    |                                                        | Name of the resource whose incoming request is being evaluated by the above policy                                                                                                                                                        |
| resource\_kind                    | "Pod", "Deployment", "StatefulSet", "ReplicaSet", etc. | Kind of this resource                                                                                                                                                                                                                     |
| resource\_namespace               |                                                        | Namspace in which this resource lies                                                                                                                                                                                                      |
| resource\_request\_operation      | "create", "update", "delete"                           | If the requested resource is being created, updated or deleted.                                                                                                                                                                           |
| rule\_name                        |                                                        | Name of the rule, in the above policy, which is evaluating in this situation                                                                                                                                                              |
| rule\_result                      | "PASS", "FAIL"                                         | Result of the rule's execution                                                                                                                                                                                                            |
| rule\_type                        | "validate", "mutate", "generate"                       | Rule's behaviour type.<br>For rule\_execution\_cause="background\_scan", it will always be "validate" as background scans only run validate rules                                                                                         |
| rule\_execution\_cause            | "admission\_request", "background\_scan"               | Identifies whether the rule is executing in response to an admission request or a periodic background scan.<br>In background scans, only validate rules whereas in the case of admission requests, all validate/mutate/generate rules run |
| rule\_response                    |                                                        | Response message associated with the rule's result                                                                                                                                                                                        |
| main\_request\_trigger\_timestamp |                                                        | Timestamp of the main admission request or background scan in the first place which resulted in the execution of this rule                                                                                                                |
| rule\_execution\_timestamp        |                                                        | Timestamp at which this rule got executed                                                                                                                                                                                                 |
| policy\_execution\_timestamp      |                                                        | Timestamp at which the policy corresponding to this rule got triggered.                                                                                                                                                                   |

## Useful Queries

* Tracking the total number of rules which failed in the 24 hours in "default" namespace grouped by their rule types (validate, mutate, generate):<br>
`count(kyverno_policy_rule_results_info{policy_namespace="default"}[24h]) by (rule_type)`

* Tracking the per-minute rate of the number of rule executions triggered by incoming Pod requests over the cluster:<br>
`rate(kyverno_policy_rule_results_info{resource_kind="Pod", rule_execution_cause="admission_request"}[1m])*60`

* Tracking the total number of policies over the cluster running as a part of background scans over the last 2 hours:<br>
`count(count(kyverno_policy_rule_results_info{rule_execution_cause="background_scan"}[2h]) by (policy_name,policy_execution_timestamp))`