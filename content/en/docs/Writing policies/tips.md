---
title: Tips & Tricks 
description: Tips and tricks for writing more effective policy.
weight: 11
---

These are some tips and tricks you can use when putting together your Kyverno policies.

## General

* Need more examples or struggling to see a practical use case? Remember to check out the extensive community samples library for ideas on how to author certain types, as well as to kickstart your own needs. Very often, you may not need to start from scratch but can instead use one of the samples as a starting point to further customize.

* Use `kubectl explain` to explain and explore the various parts and fields of a Kyverno policy. It works just like on native Kubernetes resources!

  ```sh
  kubectl explain policy.spec.rules.validate
  KIND:     Policy
  VERSION:  kyverno.io/v1

  RESOURCE: validate <Object>

  DESCRIPTION:
      Validation is used to validate matching resources.

  FIELDS:
    anyPattern   <>
      AnyPattern specifies list of validation patterns. At least one of the
      patterns must be satisfied for the validation rule to succeed.

    deny <Object>
      Deny defines conditions to fail the validation rule.

    message      <string>
      Message specifies a custom message to be displayed on failure.

    pattern      <>
      Pattern specifies an overlay-style pattern used to check resources.
  ```

* Organize your policies in a way which is meaningful to you, your organization, and your Kubernetes cluster design. In most cases, rules can be grouped into a single policy definition. Here are some tips when it comes to organizing rules:
  * Create a single `ClusterPolicy` for all `validate` rules and a `Policy` for all namespaced `validate` rules.
  * `mutate` and `generate` rules should go into their own policy definition.
  * Policies that cannot be written as a single rule but have highly related processing can go into their own policy definition.
  * Name your rules effectively as this is a component that will be displayed to users upon enforcement for `validate` rules.

* Ensure the resource you're matching and the spec definition align. For example, if writing a `mutate` rule which matches on a Deployment, the spec of what is being mutated needs to also align to a Deployment which may be different from, for example, a Pod. When copying-and-pasting from other rules, remember to check the spec.

* Check Kyverno logs when designing rules if the desired result is not achieved:
  ```
  kubectl -n <kyverno_namespace> logs -l app=kyverno
  ```

## Validate

* When developing your `validate` policies, it's easiest to set `validationFailureAction: enforce` so when testing you can see the results immediately without having to look at report.

* Before deploying into production, ensure you have `validationFailureAction: audit` so the policy doesn't have unintended consequences.

* `validate` rules have no precedence/overriding behavior, so even though a rule may be written to either allow or deny a resource/action, one cannot counteract the other. For example, a rule written to ensure all images come from registry `reg.corp.com` and another rule written to ensure they do **not** come from `reg.corp.com` will effectively render all image pulls impossible and nothing will run. Where the rule is defined is irrelevant.

* The choice between using a `pattern` statement or a `deny` statement depends largely on the data you need to consider; `pattern` works on incoming (new) objects while `deny` can additionally work on variable data such as the API operation (CREATE, UPDATE, etc.), old object data, and ConfigMap data.

## Mutate

* When writing policies which perform [cascading mutations](/docs/writing-policies/mutate/#mutate-rule-ordering-cascading), rule ordering matters. All rules which perform cascading mutations should be in the same policy definition and ordered top to bottom to ensure consistent results.

* Need to mutate an object at a specific ordered position within an array? Use the [`patchesJson6902`](/docs/writing-policies/mutate/#rfc-6902-jsonpatch) method.

## Generate

* `generate` rules which trigger off the same source object should be organized in the same policy definition.

* Be careful with the `synchronize=true` behavior as other users who may have privileges to change an object may do so to a Kyverno-protected object and see their changes wiped away during the next sync cycle.
