---
title: Preconditions
description: >
  Control policy rule execution based on variables.
weight: 8
---

Preconditions allow controlling policy rule execution based on variable values.

While `match` and `exclude` allow filtering requests based on resource and user information, `preconditions` can be used to define custom filters for more granular control of when a rule should be applied.

The primary use case for `preconditions` is in `mutate` or `generate` rules when needing to check and ensure a variable, typically from AdmissionReview data, is not empty. In addition to AdmissionReview variables, written as JMESPath expressions, `preconditions` can also be used to check against variables from ConfigMap resources. `mutate` rules which use `patchJson6902` should use `preconditions` as a way to filter out results.

For `validate` rules, the use of `patterns` is often preferable since conditionals can be used.

When specifying a JMESPath expression in a `preconditions` statement which contains a special character (ex. `/` in the case of Kubernetes annotations), double quote the annotation as a literal string. Escape the double quotes with a backslash character (`\`).

```yaml
{{request.object.spec.template.metadata.annotations.\"foo.k8s.corp.net/bar\"}}
```

You may specify multiple statements in the `preconditions` field. The use of multiple `preconditions` statements function as a logical AND statement.


## Operators

The following operators are currently supported for precondition evaluation:

- Equals
- NotEquals
- In
- NotIn

The set operators, `In` and `NotIn` support a set of strings as the value (e.g. In ["str1", "str2"]). Sets of other types are currently not supported.

## Matching requests without a service account

In this example, the rule is only applied to requests from service accounts (i.e. when the `{{serviceAccountName}}` is not empty).

```yaml
  - name: generate-owner-role
    match:
      resources:
        kinds:
        - Namespace
    preconditions:
    - key: "{{serviceAccountName}}"
      operator: NotEquals
      value: ""
```

## Matching requests from specific service accounts

In this example, the rule is only applied to requests from a service account with name `build-default` and `build-base`.

```yaml
  - name: generate-default-build-role
    match:
      resources:
        kinds:
        - Namespace
    preconditions:
    - key: "{{serviceAccountName}}"
      operator: In
      value: ["build-default", "build-base"]
```
