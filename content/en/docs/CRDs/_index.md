---
title: "Resource Definitions"
weight: 80
description: >-
  Custom Resource Definitions (CRDs) for Kyverno policies and other types.
---

Kyverno uses Kubernetes Custom Resource Definitions (CRDs) for policy definitions, policy reports, and other internal types.

The complete Kyverno CRD reference can be viewed [here](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/main/docs/user/crd/index.html).

The HTML source is available in the [Kyverno GitHub repository](https://github.com/kyverno/kyverno/tree/main/docs) and generated from type definitions stored [here](https://github.com/kyverno/kyverno/tree/main/api).

## kubectl explain

When operating in a Kubernetes cluster with Kyverno installed, you can always inspect Kyverno types natively using `kubectl explain`.

For example, this is the definition of a Kyverno Policy resource at `policy.spec`:

```shell
KIND:     Policy
VERSION:  kyverno.io/v1

RESOURCE: spec <Object>

DESCRIPTION:
     Spec defines policy behaviors and contains one or more rules.

FIELDS:
   background   <boolean>
     Background controls if rules are applied to existing resources during a
     background scan. Optional. Default value is "true". The value must be set
     to "false" if the policy rule uses variables that are only available in the
     admission review request (e.g. user name).

   failurePolicy        <string>
     FailurePolicy defines how unrecognized errors from the admission endpoint
     are handled. Rules within the same policy share the same failure behavior.
     Allowed values are Ignore or Fail. Defaults to Fail.

   rules        <[]Object>
     Rules is a list of Rule instances. A Policy contains multiple rules and
     each rule can validate, mutate, or generate resources.

   schemaValidation     <boolean>
     SchemaValidation skips policy validation checks. Optional. The default
     value is set to "true", it must be set to "false" to disable the validation
     checks.

   validationFailureAction      <string>
     ValidationFailureAction controls if a validation policy rule failure should
     disallow the admission review request (enforce), or allow (audit) the
     admission review request and report an error in a policy report. Optional.
     Allowed values are `Audit` or `Enforce`. The default value is `Audit`.

   validationFailureActionOverrides     <[]Object>
     ValidationFailureActionOverrides is a Cluter Policy attribute that
     specifies ValidationFailureAction namespace-wise. It overrides
     ValidationFailureAction for the specified namespaces.

   webhookTimeoutSeconds        <integer>
     WebhookTimeoutSeconds specifies the maximum time in seconds allowed to
     apply this policy. After the configured time expires, the admission request
     may fail, or may simply ignore the policy results, based on the failure
     policy. The default timeout is 10s, the value must be between 1 and 30
     seconds.
```

Kyverno's support for structural schemas also enables integrated help in Kubernetes enabled Integrated Development Environments (IDEs) like [VS Code](https://code.visualstudio.com/) with the [Kubernetes Extension](https://code.visualstudio.com/docs/azure/kubernetes) installed.
