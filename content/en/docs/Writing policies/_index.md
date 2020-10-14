---
title: "Writing Policies"
linkTitle: "Writing Policies"
weight: 50
description: >
    Create custom policy rules to validate, mutate, and generate configurations.
---

The following picture shows the structure of a Kyverno Policy:

![KyvernoPolicy](/images/Kyverno-Policy-Structure.png)

Each Kyverno policy contains one or more rules. Each rule has a `match` clause, an optional `exclude` clause, and one of a `mutate`, `validate`, or `generate` clause.

Each rule can validate, mutate, or generate configurations of matching resources. A rule definition can contain only a single **mutate**, **validate**, or **generate** child node. 

During admission control mutation rules are applied before validation.