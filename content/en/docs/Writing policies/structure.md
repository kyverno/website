---
title: Policy Structure
description: Learn how Kyverno policies and rules work
weight: 1
---

The following picture shows the structure of a Kyverno Policy:

![KyvernoPolicy](/images/Kyverno-Policy-Structure.png)

Each Kyverno policy contains one or more rules. Each rule has a `match` clause, an optional `exclude` clause, and one of a `mutate`, `validate`, or `generate` clause.

Each rule can validate, mutate, or generate configurations of matching resources. A rule definition can contain only a single **mutate**, **validate**, or **generate** child node. 

Policies can be defined as cluster-wide resources (using the kind `ClusterPolicy`) or namespaced resources (using the kind `Policy`.) As expected, namespaced policies will only apply to resources within the namespace they are defined in and cluster-wide policies are applied to matching resources across all namespaces. Otherwise, there is no difference between the two types.

Rules in a policy are applied in the order of definition. During [admission control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) mutation rules are applied before validation rules. This allows validation of changes made during mutation.

There is no ordering across policies and all matching policy rules will always be applied. Since validation rules are written as `pass` or `fail` conditions, rules cannot override other rules and can only extend the `fail` condition set. Hence, namespaced policies cannot override or modify behaviors described in a cluster-wide policy.