---
title: kyverno_policy_changes_info
description: This metric can be used to track the history of all the Kyverno policies-related changes such as policy creations, updations and deletions.
weight: 2
---

**Metric Value**

1 - Constant value serving no purpose

## Use cases

* The cluster admin wants to track how many cluster policies have been created in the last 1 year.
* An end user wants to track how many policies (kind: Policy) have been created in their personal namespace.
* The cluster admin wants to see how many policies with `validationFailureAction: enforce` and background mode enabled were created since last week.

## Filter Labels

| Label                    | Allowed Values               | Description                                                                                                               |
| ------------------------ | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| policy\_validation\_mode | "enforce", "audit"           | PolicyValidationFailure action of the rule's parent policy                                                               |
| policy\_type             | "cluster", "namespaced"      | Kind of the rule's parent policy. Kind: ClusterPolicy or Kind: Policy                                                     |
| policy\_background\_mode | "true", "false"              | Policy's set background mode                                                                                              |
| policy\_name             |                              | Name of the policy to which the rule belongs                                                                              |
| policy\_namespace        |                              | Namespace in which this Policy resides (only for policies with kind: Policy), For ClusterPolicies, this field will be "-" |
| policy\_change\_type     | "create", "update", "delete" | Action which happened with the policy behind this policy change.                                                          |

## Useful Queries

* Tracking the number of cluster policies with audit mode which were created in the last 60 minutes:<br>
`count(kyverno_policy_changes_info{policy_type="cluster", policy_change_type="create", policy_validation_mode="audit"}[60m])`

* Listing down all the namespaced Policies which were deleted in the “default" namespace in the last 5 minutes:<br>
`kyverno_policy_changes_info{policy_type="namespaced", policy_namespace="default", policy_change_type="delete"}[5m]`

* Track the number of changes which happened with a cluster policy named “sample-policy":<br>
`count(kyverno_policy_changes_info{policy_type="cluster", policy_name="sample-policy"})`
