---
title: Tips & Tricks 
description: >
  Tips and tricks for writing more effective policy.
weight: 140
---

These are some tips and tricks you can use when putting together your Kyverno policies.

## General

* Need more examples or struggling to see a practical use case? Remember to check out the extensive [community samples library](/docs/policies/) for ideas on how to author certain types, as well as to kickstart your own needs. Very often, you may not need to start from scratch but can instead use one of the samples as a starting point to further customize.

* Use `kubectl explain` to explain and explore the various parts and fields of a Kyverno policy. It works just like on native Kubernetes resources!

  ```sh
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
      Deny defines conditions used to pass or fail a validation rule.

    foreach      <Object>
      ForEach applies policy rule checks to nested elements.

    message      <string>
      Message specifies a custom message to be displayed on failure.

    pattern      <>
      Pattern specifies an overlay-style pattern used to check resources.
  ```

* Use `kubectl get kyverno -A` or `kubectl get crd | grep kyverno` to show all the Kyverno Custom Resources present in your cluster. This will return resources such as policies of various types, policy reports, and intermediary resources used internally by Kyverno.
* When using VS Code, because of the OpenAPIV3 schema Kyverno supports, you can make use of this integration to assist in writing policy by getting field hints and describing elements.
* Make use of the [Kyverno CLI](/docs/kyverno-cli/) to test policies out in advance.
* Organize your policies in a way which is meaningful to you, your organization, and your Kubernetes cluster design keeping in mind how they are processed. Each policy is processed in an idempotent manner while rules within policies are executed serially. When needing to control processing order, put highly-related rules in the same policy and use the `applyRules` field.

* Ensure the resource you're matching and the spec definition align. For example, if writing a `mutate` rule which matches on a Deployment, the spec of what is being mutated needs to also align to a Deployment which may be different from, for example, a Pod. When copying-and-pasting from other rules, remember to check the spec.

* Check Kyverno logs when designing rules if the desired result is not achieved:

```sh
kubectl -n <kyverno_namespace> logs <pod_name>
```

Depending on the level of detail needed, you may need to increase the log level. To see variable substitution messages, use log level 4. To see the full AdmissionReview payload sent by the Kubernetes API server to Kyverno, use the `--dumpPayload=true` [flag](/docs/installation/customization.md#container-flags) and inspect the logs. Remember to remove this flag at the conclusion of your troubleshooting process.

* Use the [Kyverno Playground](https://playground.kyverno.io/) to test out new or modified policies with your resources.

## Validate

* When developing your `validate` policies, it's easiest to set `failureAction: Enforce` so when testing you can see the results immediately without having to look at a report.

* Before deploying into production, ensure you have `failureAction: Audit` so the policy doesn't have unintended consequences.

* `validate` rules cannot counteract the other. For example, a rule written to ensure all images come from registry `reg.corp.com` and another rule written to ensure they do **not** come from `reg.corp.com` will effectively render all image pulls impossible and nothing will run. Where the rule is defined is irrelevant.

* The choice between using a `pattern` statement or a `deny` statement depends largely on the data you need to consider; `pattern` works on incoming (new) objects while `deny` can additionally work on variable data such as the API operation (CREATE, UPDATE, etc.), old object data, and ConfigMap data.

## Mutate

* When writing policies which perform [cascading mutations](/docs/policy_types/cluster_policy/mutate.md#mutate-rule-ordering-cascading), rule ordering matters. All rules which perform cascading mutations should be in the same policy definition and ordered top to bottom to ensure consistent results.

* Need to mutate an object at a specific ordered position within an array? Use the [`patchesJson6902`](/docs/policy_types/cluster_policy/mutate.md#rfc-6902-jsonpatch) method.

## Generate

* `generate` rules which trigger off the same source object should be organized in the same policy definition.

* Be careful with the `synchronize=true` behavior as other users who may have privileges to change an object may do so to a Kyverno-protected object and see their changes wiped away during the next sync cycle.
