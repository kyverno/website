---
title: "Custom Resource Definitions"
weight: 80
description: >
  Custom Resource Definitions (CRDs) for Kyverno policies and other types.
---

Kyverno uses Kubernetes Custom Resource Definitions (CRDs) for policy definitions, policy reports, and other internal types. When operating in a Kubernetes cluster with Kyverno installed, you can always inspect Kyverno types natively using `kubectl explain`. 

For example, here is the definition of a Kyverno `policy.spec`:

```shell
λ kubectl explain policy.spec
KIND:     Policy
VERSION:  kyverno.io/v1

RESOURCE: spec <Object>

DESCRIPTION:
     Spec defines policy behaviors and contains one or rules.

FIELDS:
   background   <boolean>
     Background controls if rules are applied to existing resources during a
     background scan. Optional. Default value is "true". The value must be set
     to "false" if the policy rule uses variables that are only available in the
     admission review request (e.g. user name).

   rules        <[]Object>
     Rules is a list of Rule instances. A Policy contains multiple rules and
     each rule can validate, mutate, or generate resources.

   validationFailureAction      <string>
     ValidationFailureAction controls if a validation policy rule failure should
     disallow the admission review request (enforce), or allow (audit) the
     admission review request and report an error in a policy report. Optional.
     The default value is "audit".
```

Kyverno's support for structural schema's also enables integrated help in Kubernetes enabled Integrated Development Environments like VS Code with the Kubernetes Extension installed.

The complete Kyverno CRD reference can be viewed using this link:

  **[kyverno.io/v1.ClusterPolicy](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/main/docs/crd/v1/index.html#kyverno.io/v1.ClusterPolicy)**

The HTML source is available in the [Kyverno GitHub repository](https://github.com/kyverno/kyverno/tree/main/docs) and generated from type definitions stored at [kyverno/kyverno/pkg/api](https://github.com/kyverno/kyverno/tree/main/pkg/api).


