---
title: Policies and Rules
description: >
    Get an overview of how Kyverno policies and rules work.
weight: 45
---

A Kyverno policy is a collection of rules. Each rule consists of a [`match`](/docs/writing-policies/match-exclude/) declaration, an optional [`exclude`](/docs/writing-policies/match-exclude/) declaration, and one of a [`validate`](/docs/writing-policies/validate/), [`mutate`](/docs/writing-policies/mutate/), [`generate`](/docs/writing-policies/generate), or [`verifyImages`](/docs/writing-policies/verify-images) declaration. Each rule can contain only a single `validate`, `mutate`, `generate`, or `verifyImages` child declaration.

<img src="/images/Kyverno-Policy-Structure.png" alt="Kyverno Policy" width="65%"/>
<br/>
<br/>

Policies can be defined as cluster-wide resources (using the kind `ClusterPolicy`) or namespaced resources (using the kind `Policy`). As expected, namespaced policies will only apply to resources within the namespace in which they are defined while cluster-wide policies are applied to matching resources across all namespaces. Otherwise, there is no difference between the two types.

Additional policy types include [Policy Exceptions](/docs/writing-policies/exceptions/) and [Cleanup Policies](/docs/writing-policies/cleanup/) which are separate resources and described further in the documentation.

Learn more about [Applying Policies](/docs/applying-policies/) and [Writing Policies](/docs/writing-policies/) in the upcoming chapters.
