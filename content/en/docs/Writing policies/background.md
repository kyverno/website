---
title: Background Scans 
description: >
  Apply policies to existing resources in a cluster.
weight: 9
---

{{% alert title="Note" color="info" %}}
⚠️  Kyverno is designed to prevent inadvertent changes to running applications. Hence, mutate and generate rules are not processed during background scans. To generate new resources for existing workloads (e.g. namespaces) use labels or metadata to manage a controlled rollout as detailed [here](/docs/writing-policies/generate/#generating-resources-into-existing-namespaces).
{{% /alert %}}

Background scanning applies validation rules to workloads that are already running in a cluster.

Kyverno can validate existing resources in a cluster that may have been created before a policy was created. This can also be useful when evaluating the potential effects new policies will have on a cluster prior to applying them with `enforce` mode. The application of policies to existing resources is referred to as **background scanning** and is enabled by default unless `background` is set to `false` in a policy like shown below in the snippet.

```yaml
spec:
  background: false
  rules:
  - name: default-deny-ingress
```


When background scans are enabled for a policy, if existing resources are found which would violate the policy, the background scan reports them using a `ClusterPolicyReport` or a `PolicyReport` object, depending on if the resource is namespaced or not. 

The bachround scan does not block, or otherwise impact, any existing resources that match a `validate` rule, even in `enforce` mode. Background scanning is an optional field and defaults to `true`, only taking effect on `validate` rules. It has no effect on either `generate` or `mutate` rules.

By default, background scanning occurs at start and then every 15 minutes. Currently the scan interval is not configurable.

When background scanning is enabled, regardless of whether the policy's `validationFailureAction` is set to `enforce` or `audit`, the violation will be recorded in a report. To see the specifics of how reporting works with background scans, refer to the tables below.

**Reporting behavior when `background: true`**

|                                  | New Resource | Existing Resource |
|----------------------------------|--------------|-------------------|
| `validationFailureAction: enforce` | None         | Report            |
| `validationFailureAction: audit`   | Report       | Report            |

**Reporting behavior when `background: false`**

|                                  | New Resource | Existing Resource |
|----------------------------------|--------------|-------------------|
| `validationFailureAction: enforce` | None         | None              |
| `validationFailureAction: audit`   | Report       | None              |


Policy rules that are written using variables from [Admission Review](/docs/writing-policies/variables/#variables-from-admission-review-request-data) request information (e.g. `{{request.userInfo}}`) cannot be applied to existing resources in the background scanning mode since that information is not available. Hence, these rules must set `background` to `false` to disable background scanning.
