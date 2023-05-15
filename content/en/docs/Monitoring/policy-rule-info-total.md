---
title: Policies and Rule Counts
description: This metric can be used to track the number of policies as well as rules present in the cluster which are currently active and even the ones which are not currently active but were created in the past.
weight: 10
---

**Metric Name**

`kyverno_policy_rule_info_total`

**Metric Value**

* `1` - for rules currently actively present in the cluster.

## Use cases

* The cluster admin wants to know the average number of cluster policies in the cluster since last 1 year.
* The cluster admin wants to track the trend of the count of policies applied in the default namespace.
* The cluster admin wants to track and see the month when the default namespace possessed the highest number of policies.

## Filter Labels

| Label                    | Allowed Values                   | Description                                                                                                                                       |
| ------------------------ | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| policy\_validation\_mode | "enforce", "audit"               | PolicyValidationFailure action of the rule's parent policy                                                                                       |
| policy\_type             | "cluster", "namespaced"          | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                                             |
| policy\_background\_mode | "true", "false"                  | Policy's set background mode                                                                                                                      |
| policy\_name             |                                  | Name of the policy to which the rule belongs                                                                                                      |
| policy\_namespace        |                                  | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-"                         |
| rule\_name               |                                  | Name of the rule, in the above policy, which is evaluating in this situation                                                                      |
| rule\_type               | "validate", "mutate", "generate" | Rule's behavior type.<br>For rule\_execution\_cause="background\_scan", it will always be "validate" as background scans only run validate rules |
| status\_ready            | "true", "false"                  | Readiness of the policy. When ready, the policy is able to serve admission requests

## Useful Queries

* Tracking the count of the cluster policies currently active:<br> 
`count(count(kyverno_policy_rule_info_total{policy_type="cluster"} == 1) by (policy_name))`

* Tracking the per-minute rate (avged over 30s) at which "validate" rules (both of cluster and namespaced policies) are being added to the cluster:<br> 
`rate(kyverno_policy_rule_info_total{rule_type="validate"}[30s] == 1)*60`

* Tracking the total number of mutate rules added in the last 24hrs:<br> 
`count(kyverno_policy_rule_info_total{rule_type="mutate"}[24h]==1)`

* Tracking the total number of active policies with enforce mode and background mode:<br>
`count(count(kyverno_policy_rule_info_total{policy_validation_mode="enforce", policy_background_mode="true"}==1) by (policy_name))`
