---
title: Applying Policies
description: >-
    Apply policies across clusters and delivery pipelines
weight: 48
---

{{% alert title="Tip" color="info" %}}
The [Kyverno Policies](/policies/) repository contains several policies you can immediately apply to your clusters.
{{% /alert %}}

## In Clusters

On installation, Kyverno runs as a [dynamic admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) in a Kubernetes cluster. Kyverno receives validating and mutating admission webhook HTTP callbacks from the Kubernetes API server and applies matching policies to return results that enforce admission policies or reject requests.

Policies with validation rules can be used to block insecure or non-compliant configurations by setting the [`validationFailureAction`](../writing-policies/validate.md#failure-action) to `Enforce`. Or, validation rules can be applied using periodic scans with results available as [policy reports](../policy-reports/).

Rules in a policy are applied in the order of definition. During [admission control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/), mutation rules are applied before validation rules. This allows validation of changes made during mutation. Note that **all** mutation rules are applied first across all policies before any validation rules are applied.

There is no ordering within or across policies and all matching policy rules will always be applied. For `validate` rules, this ordering is irrelevant, however for `mutate` and `generate` rules, if there is a cascading dependency, rules should be ordered according to those dependencies. Since validation rules are written as `pass` or `fail` conditions, rules cannot override other rules and can only extend the `fail` condition set. Hence, namespaced policies cannot override or modify behaviors described in a cluster-wide policy. Because policies are logical collections of related rules and do not imply functionality relative to other policies, a single policy having two validation rules, for example, produces the same ultimate effect as two policies each having one rule. Designing policies is therefore primarily an organizational concern and not a functional one.

Exceptions to policies may be defined in the rules themselves or with a separate [PolicyException resource](../writing-policies/exceptions.md).

[Cleanup policies](../writing-policies/cleanup.md), another separate resource type, can be used to remove existing resources based upon a definition and schedule.

## In Pipelines

You can use the [Kyverno CLI](../kyverno-cli/) to apply policies to YAML resource manifest files as part of a software delivery pipeline. This command line tool allows integrating Kyverno into GitOps style workflows and checks for policy compliance of resource manifests before they are committed to version control and applied to clusters.

Refer to the [Kyverno apply command section](../kyverno-cli/usage/apply.md) for details on the CLI. And refer to the [Continuous Integration section](../testing-policies/index.md#continuous-integration) for an example of how to incorporate the CLI to apply and test policies in your pipeline.
