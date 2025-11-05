---
title: Working with Assertion Trees
description: Advanced testing with the Kyverno CLI
sidebar:
  order: 20
---

Kyverno 1.12 introduced assertion trees support in the `test` command.

The purpose of assertion trees is to offer more flexibility than the traditional syntax in `results`.

Assertion trees reside under the `checks` stanza as shown in the example below:

```yaml
checks:
  - match:
      resource:
        kind: Namespace
        metadata:
          name: hello-world-namespace
      policy:
        kind: ClusterPolicy
        metadata:
          name: sync-secret
      rule:
        name: sync-my-secret
    assert:
      status: pass
    error:
      (status != 'pass'): true
```

## Composition of a check item

A check is made of the following parts:

- A `match` statement to select the elements considered by a check. This match can act on the resource, the policy and/or the rule. It is not limited to matching by kind or name but can match on anything in the payload (labels, annotations, etc...).
- An `assert` statement defining the conditions to verify on the matched elements.
- An `error` statement (the opposite of an `assert`) defining the conditions that must NOT evaluate to `true` on the matched elements.

In the example above the `check` is matching Namespace elements named `hello-world-namespace` for the cluster policy named `sync-secret` and rule named `sync-my-secret`. For those elements the status is expected to be equal to `pass` and the expression `(status != 'pass')` is NOT expected to be true.

## Examples

Implementation is based on [Kyverno JSON - assertion trees](https://kyverno.github.io/kyverno-json/latest/policies/asserts/). Please refer to the documentation for more details on the syntax.

### Select all results

To select all results, all you need to do is to provide an empty match statement:

```yaml
- match: {} # this will match everything
  assert:
    # ...
  error:
    # ...
```

### Select based on labels

To select results based on labels, specify those labels in the stanza where they apply:

```yaml
- match:
    resource:
      metadata:
        labels:
          foo: bar
    policy:
      metadata:
        labels:
          bar: baz
  assert:
    # ...
  error:
    # ...
```
