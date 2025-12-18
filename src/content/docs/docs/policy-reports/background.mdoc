---
title: Background Scans
description: Periodically reapply policies to existing resources for reporting.
sidebar:
  order: 15
---

Kyverno can validate existing resources in the cluster that may have been created before a policy was created. This can be useful when evaluating the potential effects some new policies will have on a cluster prior to changing them to `Enforce` mode. The application of policies to existing resources is referred to as **background scanning** and is enabled by default unless `spec.background` is set to `false` in a policy like shown below in the snippet.

```yaml
spec:
  background: false
  rules:
    - name: default-deny-ingress
```

{% aside title="Note" type="note" %}
Background scans are handled by the reports controller and not the background controller.
{% /aside %}

Background scanning, enabled by default in a `Policy` or `ClusterPolicy` object with the `spec.background` field, allows Kyverno to periodically scan existing resources and find if they match any `validate` or `verifyImages` rules. If existing resources are found which would violate an existing policy, the background scan notes them in a `ClusterPolicyReport` or a `PolicyReport` object, depending on if the resource is namespaced or not. It does not block any existing resources that match a rule, even in `Enforce` mode. It has no effect on either `generate` or `mutate` rules for the purposes of reporting.

Background scanning occurs on a periodic basis (one hour by default) and offers some configuration options via [container flags](/docs/installation/customization.md#container-flags).

When background scanning is enabled, regardless of whether the policy's `failureAction` is set to `Enforce` or `Audit`, the results will be recorded in a report. To see the specifics of how reporting works with background scans, refer to the tables below.

**Reporting behavior when `background: true`**

|                          | New Resource | Existing Resource |
| ------------------------ | ------------ | ----------------- |
| `failureAction: Enforce` | Pass only    | Report            |
| `failureAction: Audit`   | Report       | Report            |

**Reporting behavior when `background: false`**

|                          | New Resource | Existing Resource |
| ------------------------ | ------------ | ----------------- |
| `failureAction: Enforce` | Pass only    | None              |
| `failureAction: Audit`   | Report       | None              |

Also, policy rules that are written using either certain variables from [AdmissionReview](/docs/policy-types/cluster-policy/variables.md#variables-from-admission-review-requests) request information (e.g. `request.userInfo`), or fields like Roles, ClusterRoles, and Subjects in `match` and `exclude` statements, cannot be applied to existing resources in the background scanning mode since that information must come from an AdmissionReview request and is not available if the resource exists. Hence, these rules must set `background` to `false` to disable background scanning. The exceptions to this are `request.object` and `request.namespace` variables as these will be translated from the current state of the resource.
