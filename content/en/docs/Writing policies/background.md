---
title: Background Scans 
description: >
  Manage applying policies to existing resources in a cluster.
weight: 110
---

Kyverno can validate existing resources in the cluster that may have been created before a policy was created. This can be useful when evaluating the potential effects new `validate` policies will have on a cluster prior to changing them to `enforce` mode. The application of policies to existing resources is referred to as **background scanning** and is enabled by default unless `background` is set to `false` in a policy like shown below in the snippet.

```yaml
spec:
  background: false
  rules:
  - name: default-deny-ingress
```

Background scanning, enabled by default in a `Policy` or `ClusterPolicy` object with the `spec.background` field, allows Kyverno to scan existing resources and find if they match any `validate` rules. If existing resources are found which would violate an existing policy, the background scan notes them in a `ClusterPolicyReport` or a `PolicyReport` object, depending on if the resource is namespaced or not. It does not block any existing resources that match a `validate` rule, even in `enforce` mode. Background scanning is an optional field and defaults to `true`, only taking effect on `validate` rules. It has no effect on either `generate` or `mutate` rules.

Background scanning occurs on a continual basis and offers some configuration options via [container flags](/docs/installation/#container-flags).

{{% alert title="Note" color="info" %}}
Kyverno does not mutate existing resources to prevent inadvertent changes to workloads.
Mutate and generate rules are not processed during background scans.
{{% /alert %}}

When background scanning is enabled, regardless of whether the policy's `validationFailureAction` is set to `enforce` or `audit`, the results will be recorded in a report. To see the specifics of how reporting works with background scans, refer to the tables below.

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

Also, policy rules that are written using either certain variables from [AdmissionReview](/docs/writing-policies/variables/#variables-from-admission-review-request-data) request information (e.g. `request.userInfo`), or fields like Roles, ClusterRoles, and Subjects in `match` and `exclude` statements, cannot be applied to existing resources in the background scanning mode since that information must come from an AdmissionReview request and is not available if the resource exists. Hence, these rules must set `background` to `false` to disable background scanning. The exceptions to this are `request.object` and `request.namespace` variables as these will be translated from the current state of the resource.
