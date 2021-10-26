---
title: Policy Settings
description: Common configuration for all rules in a policy.
weight: 1
---

A [policy](/docs/kyverno-policies/) contains one or more rules, and the following common settings which apply to all rules in the policy:

* **validationFailureAction**: controls if a validation policy rule failure should block the admission review request ("enforce") or allow ("audit") the admission review request and report the policy failure in a policy report. Defaults to "audit".

* **background**: controls if rules are applied to existing resources during a background scan. Defaults to "true".

* **schemaValidation**: controls whether policy validation checks are applied. Defaults to "true". Kyverno will attempt to validate the schema of a policy and fail because it cannot determine if it satisfies the OpenAPI schema definition for that resource. Can occur on either validate or mutate policies. Set to "false" to skip.

* **failurePolicy**: defines the API server behavior if the webhook fails to respond, Allowed values are "Ignore" or "Fail". Defaults to "Fail".

* **webhookTimeoutSeconds**: specifies the maximum time in seconds allowed to apply this policy. The default timeout is 10s. The value must be between 1 and 30 seconds.

{{% alert title="Tip" color="info" %}}
Use `kubectl explain policy.spec` for command-line help on the policy schema.
{{% /alert %}}
