---
title: Policies and Rules
description: >
    Get an overview of how Kyverno policies and rules work.
weight: 45
---

A Kyverno policy is a collection of rules. Each rule consists of a [`match`](../writing-policies/match-exclude.md) declaration, an optional [`exclude`](../writing-policies/match-exclude.md) declaration, and one of a [`validate`](../writing-policies/validate.md), [`mutate`](../writing-policies/mutate.md), [`generate`](../writing-policies/generate.md), or [`verifyImages`](../writing-policies/verify-images/index.md) declaration. Each rule can contain only a single `validate`, `mutate`, `generate`, or `verifyImages` child declaration.

<img src="/images/Kyverno-Policy-Structure.png" alt="Kyverno Policy" width="65%"/>
<br/>
<br/>

Policies can be defined as cluster-wide resources (using the kind `ClusterPolicy`) or namespaced resources (using the kind `Policy`). As expected, namespaced policies will only apply to resources within the namespace in which they are defined while cluster-wide policies are applied to matching resources across all namespaces. Otherwise, there is no difference between the two types.

Additional policy types include [Policy Exceptions](../writing-policies/exceptions.md) and [Cleanup Policies](../writing-policies/cleanup.md) which are separate resources and described further in the documentation.

Learn more about [Applying Policies](../applying-policies/_index.md) and [Writing Policies](../writing-policies/_index.md) in the upcoming chapters.
