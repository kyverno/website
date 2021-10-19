---
title: Dynamic Webhook Configurations
description: Manage webhook configurations dynamically.
weight: 2
---

Starting with Kyverno 1.5.0, the `mutatingWebhookConfiguration` and the `validatingWebhookConfiguration` resources are registered and managed dynamically based on the configured policies. Prior to this version, Kyverno uses a wildcard webhook that allowed it to receive admission requests for all resources. With the webhook auto-configuration feature, Kyverno now only receives admission requests for select resources hence preventing unnecessary admission requests being forwarded to Kyverno.

This feature is enabled by default in 1.5.0 and can be turned off by flag `--autoUpdateWebhooks=false`. If disabled, Kyverno creates the default webhook configurations that forwards admission requests for all resources and with `FailurePolicy` set to `Ignore`.


## Policy Configurable Fields

`pol.spec.failurePolicy`: FailurePolicy defines how unrecognized errors from the admission endpoint are handled by the Kubernetes API server.

`pol.spec.webhookTimeoutSeconds`: After the configured time has expired, the admission request will be handled based on the failure policy. The default timeout is 10s, the value must be between 1 and 30 seconds.