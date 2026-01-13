---
title: Overview
description: Get an overview of how Kyverno policies and rules work.
sidebar:
  order: 1
---

A Kyverno ClusterPolicy contains a list of rules.

Policies with validation rules can be used to block insecure or non-compliant configurations by setting the [`failureAction`](/docs/policy-types/cluster-policy/validate#failure-action) to `Enforce`. Or, validation rules can be applied using periodic scans with results available as [policy reports](/docs/guides/reports).

Rules in a policy are applied in the order of definition. During [admission control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/), mutation rules are applied before validation rules. This allows validation of changes made during mutation. Note that **all** mutation rules are applied first across all policies before any validation rules are applied.

There is no ordering within or across policies and all matching policy rules will always be applied. For `validate` rules, this ordering is irrelevant, however for `mutate` and `generate` rules, if there is a cascading dependency, rules should be ordered according to those dependencies. Since validation rules are written as `pass` or `fail` conditions, rules cannot override other rules and can only extend the `fail` condition set. Hence, namespaced policies cannot override or modify behaviors described in a cluster-wide policy. Because policies are logical collections of related rules and do not imply functionality relative to other policies, a single policy having two validation rules, for example, produces the same ultimate effect as two policies each having one rule. Designing policies is therefore primarily an organizational concern and not a functional one.

Each rule consists of a [`match`](/docs/policy-types/cluster-policy/match-exclude) declaration, an optional [`exclude`](/docs/policy-types/cluster-policy/match-exclude) declaration, and one of a [`validate`](/docs/policy-types/cluster-policy/validate), [`mutate`](/docs/policy-types/cluster-policy/mutate), [`generate`](/docs/policy-types/cluster-policy/generate), or [`verifyImages`](/docs/policy-types/cluster-policy/verify-images/overview) declaration. Each rule can contain only a single `validate`, `mutate`, `generate`, or `verifyImages` child declaration.

<img src="/images/Kyverno-Policy-Structure.png" alt="Kyverno Policy" width="65%"/>
<br/>
<br/>

Policies can be defined as cluster-wide resources (using the kind `ClusterPolicy`) or namespaced resources (using the kind `Policy`). As expected, namespaced policies will only apply to resources within the namespace in which they are defined while cluster-wide policies are applied to matching resources across all namespaces. Otherwise, there is no difference between the two types.

Additional policy types include [Policy Exceptions](/docs/guides/exceptions) and [Cleanup Policies](/docs/policy-types/cleanup-policy) which are separate resources and described further in the documentation.

Learn more about [Applying Policies](/docs/guides/applying-policies) and [Writing Policies](/docs/policy-types/cluster-policy/overview) in the upcoming chapters.
