---
title: Dynamic Webhook Configurations
description: Manage webhook configurations dynamically.
weight: 2
---

From Kyverno 1.5.0, the `mutatingWebhookConfiguration` and the `validatingWebhookConfiguration` are registered and managed dynamically based on the configured policies. Prior to this version, Kyverno uses a wildcard webhook that allows it to receive all resources and make policy decisions. With the auto-configuration, Kyverno only receives the selected resources to reduce unnecessary admission requests being forwarded to Kyverno. This feature is enabled by default in 1.5.0 and can be turned off by flag `--autoUpdateWebhooks=false`.

## Configurable Fields

`pol.spec.failurePolicy`: FailurePolicy defines how unrecognized errors from the admission endpoint are handled. Rules within the same policy share the same failure behavior. Allowed values are Ignore or Fail. Defaults to Fail.

`pol.spec.webhookTimeoutSeconds`: WebhookTimeoutSeconds specifies the webhook timeout for this policy. After the timeout passes, the admission request will fail based on the failure policy. The default timeout is 10s, the value must be between 1 and 30 seconds.