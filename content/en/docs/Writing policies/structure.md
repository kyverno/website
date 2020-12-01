---
title: Policy Structure
description: Learn how Kyverno policies and rules work.
weight: 1
---

The following picture shows the structure of a Kyverno Policy:

![KyvernoPolicy](/images/Kyverno-Policy-Structure.png)

A Kyverno policy is a logical collection of one or more rules. Each rule has a `match` clause, an optional `exclude` clause, and one of a `mutate`, `validate`, or `generate` clause.

Each rule can validate, mutate, or generate configurations of matching resources. A rule definition can contain only a single **mutate**, **validate**, or **generate** child node.

Policies can be defined as cluster-wide resources (using the kind `ClusterPolicy`) or namespaced resources (using the kind `Policy`.) As expected, namespaced policies will only apply to resources within the namespace in which they are defined while cluster-wide policies are applied to matching resources across all namespaces. Otherwise, there is no difference between the two types.

Rules in a policy are applied in the order of definition. During [admission control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/), mutation rules are applied before validation rules. This allows validation of changes made during mutation. Note that **all** mutation rules are applied first across all policies before any validation rules are applied.

There is no ordering within or across policies and all matching policy rules will always be applied. Since validation rules are written as `pass` or `fail` conditions, rules cannot override other rules and can only extend the `fail` condition set. Hence, namespaced policies cannot override or modify behaviors described in a cluster-wide policy. Because policies are logical collections of related rules and do not imply functionality relative to other policies, a single policy having two validation rules, for example, produces the same ultimate effect as two policies each having one rule. Designing policies is therefore more of an organizational concern and not a functional one.
