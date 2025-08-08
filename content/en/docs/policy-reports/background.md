---
title: Background Scans 
description: Periodically reapply policies to existing resources for reporting.
weight: 15
---

Kyverno can validate existing resources in the cluster that may have been created before a policy was created. This can be useful when evaluating the potential effects some new policies will have on a cluster prior to changing them to `Enforce` mode. The application of policies to existing resources is referred to as **background scanning** and is enabled by default unless `spec.background` is set to `false` in a policy like shown below in the snippet.

```yaml
spec:
  background: false
  rules:
  - name: default-deny-ingress
```

{{% alert title="Note" color="info" %}}
Background scans are handled by the **reports controller**, not the background controller. In Kyverno v1.12 and later, the internal reporting mechanism has been simplified. Instead of four separate intermediary resources (`AdmissionReport`, `ClusterAdmissionReport`, `BackgroundScanReport`, and `ClusterBackgroundScanReport`), Kyverno now uses ephemeral reports (`EphemeralReport` and `ClusterEphemeralReport`) which are short-lived and generated on-the-fly for both admission and background scans. These are used internally by Kyverno to construct the final `PolicyReport` and `ClusterPolicyReport` resources for users.
{{% /alert %}}

Background scanning, enabled by default in a `Policy` or `ClusterPolicy` object with the `spec.background` field, allows Kyverno to periodically scan existing resources and find if they match any `validate` or `verifyImages` rules. If existing resources are found which would violate an existing policy, the background scan notes them in a `ClusterPolicyReport` or a `PolicyReport` object, depending on if the resource is namespaced or not. It does not block any existing resources that match a rule, even in `Enforce` mode. It has no effect on either `generate` or `mutate` rules for the purposes of reporting.

Background scanning occurs on a periodic basis (one hour by default) and offers some configuration options via [container flags](/docs/installation/customization.md#container-flags).

When background scanning is enabled, regardless of whether the policy's `failureAction` is set to `Enforce` or `Audit`, the results will be recorded in a report. To see the specifics of how reporting works with background scans, refer to the tables below.

**Reporting behavior when `background: true`**

|                                  | New Resource | Existing Resource |
|----------------------------------|--------------|-------------------|
| `failureAction: Enforce` | Pass only         | Report            |
| `failureAction: Audit`   | Report       | Report            |

**Reporting behavior when `background: false`**

|                                  | New Resource | Existing Resource |
|----------------------------------|--------------|-------------------|
| `failureAction: Enforce` | Pass only         | None              |
| `failureAction: Audit`   | Report       | None              |

Also, policy rules that are written using either certain variables from [AdmissionReview](/docs/policy-types/cluster-policy/variables.md#variables-from-admission-review-requests) request information (e.g. `request.userInfo`), or fields like Roles, ClusterRoles, and Subjects in `match` and `exclude` statements, cannot be applied to existing resources in the background scanning mode since that information must come from an AdmissionReview request and is not available if the resource exists. Hence, these rules must set `background` to `false` to disable background scanning. The exceptions to this are `request.object` and `request.namespace` variables as these will be translated from the current state of the resource.
