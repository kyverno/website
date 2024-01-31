---
title: Policy Settings
description: >
    Common configuration for all rules in a policy.
weight: 10
---

A [policy](/docs/kyverno-policies/) contains one or more rules, and the following common settings which apply to all rules in the policy:

* **admission**: determines whether rules in this policy should be applied during admission control. This is an optional field with a default of `true`. If set to `false` then policies should be applied in background mode only (see further below).

* **applyRules**: states how many of the rules in the parent policy should be applied to a matching resource. Values are `One` and `All` (default). If set to `One`, the first matching rule to be applied will stop further rules from being evaluated.

* **background**: controls scanning of existing resources to find potential violations and generating Policy Reports. See the documentation [here](/docs/policy-reports/background/). Defaults to "true".

* **failurePolicy**: defines the API server behavior if the webhook fails to respond. Allowed values are "Ignore" or "Fail". Defaults to "Fail". Additionally, if set to "Ignore" will allow failing calls to image registries to be ignored. This allows for rule types like verifyImages or others which use image data to not block if the registry is temporarily down, useful in situations where images already exist on the nodes.

* **generateExisting**: applicable to generate rules only. Controls whether Kyverno should evaluate the policy the moment it is created.

* **mutateExistingOnPolicyUpdate**: applicable to mutate rules which define targets. Controls whether Kyverno should evaluate the policy when it is updated.

* **schemaValidation**: controls whether policy validation checks are applied. Defaults to "true". Kyverno will attempt to validate the schema of a policy and fail if it cannot determine it satisfies the OpenAPI schema definition for that resource. Can occur on either validate or mutate policies. Set to "false" to skip schema validation. This field is deprecated as of 1.11 and currently has no effect. Scheduled to be removed in a future version.

* **skipBackgroundRequests**: bypasses admission requests that are sent by the background controller. The default value is set to "true", it must be set to "false" to apply generate and mutateExisting rules to those requests.

* **useServerSideApply**: controls whether to use server-side apply for generate rules. Defaults to `false`. If set to `true`, Kyverno will use server-side apply when generating resources allowing other controllers to know which fields Kyverno owns.

* **validationFailureAction**: controls if a validation policy rule failure should block the admission review request (`Enforce`) or allow (`Audit`) the admission review request and report the policy failure in a policy report. Defaults to `Audit`.

* **validationFailureActionOverrides**: a ClusterPolicy attribute that specifies `validationFailureAction` Namespace-wise. It overrides `validationFailureAction` for the specified Namespaces.

* **webhookTimeoutSeconds**: specifies the maximum time in seconds allowed to apply this policy. The default timeout is 10s. The value must be between 1 and 30 seconds.

{{% alert title="Tip" color="info" %}}
Use `kubectl explain policy.spec` for command-line help on the policy schema.
{{% /alert %}}
