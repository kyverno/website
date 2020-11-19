---
title: Background Scans 
description: >
  Manage applying policies to existing resources in a cluster.
weight: 9
---

**EXISTING**

Kyverno can validate existing resources in the cluster that may have been created before a policy was created. The application of policies to existing resources is referred to as `background scanning`.

**Note: Kyverno does not mutate existing resources, to prevent inadvertent changes to workloads. Mutate and generate rules are not processed during background scans.**

A policy is always enabled for processing during admission control. However, policy rules that rely on variable ``AdmissionReview`` request information (e.g. `{{request.userInfo}}`) cannot be applied to existing resources in the `background scanning` mode as the user information is not available. Hence, these rules must set the boolean flag `{spec.background}` to `false` to disable `background` scanning.

```yaml
spec:
  background: true
  rules:
  - name: default-deny-ingress
```

The default value of `background` is `true`.

When a policy is created or modified, the policy validation logic will report an error if a rule uses `userInfo` and does not set `background` to `false`.

---

**PROPOSED**

Kyverno can validate existing resources in the cluster that may have been created before a policy was created. This can be useful when evaluating the potential effects new policies will have on a cluster prior to changing them to `enforce` mode. The application of policies to existing resources is referred to as **background scanning** and is enabled by default unless `background` is set to `false` in a policy like shown below in the snippet.

```yaml
spec:
  background: false
  rules:
  - name: default-deny-ingress
```

Background scanning, enabled by default in a `Policy` or `ClusterPolicy` object with the `spec.background` field, allows Kyverno to scan existing resources and see if they match any `validate` rules. If existing resources are found which would violate an existing policy, the background scan notes them in a `ClusterPolicyReport` or a `PolicyReport` object, depending on if the resource is namespaced or not. Background scanning defaults to `true` and only takes effect on `validate` rules. It has no effect on either `generate` or `mutate` rules.

By default, background scanning occurs every 15 minutes and is not currently configurable.

> ⚠️ **Note: Kyverno does not mutate existing resources to prevent inadvertent changes to workloads. Mutate and generate rules are not processed during background scans.**

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

Also, policy rules that are written using variables from Admission Review request information (e.g. `{{request.userInfo}}`) cannot be applied to existing resources in the background scanning mode since that information is not available. Hence, these rules must set `background` to `false` to disable background scanning.
