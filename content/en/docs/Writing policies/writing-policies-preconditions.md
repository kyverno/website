---
title: Preconditions
description: >
  Control policy rule execution based on variables.
weight: 6
---

Preconditions allow controlling policy rule execution based on variable values.

While `match` & `exclude` allow filtering requests based on resource and user information, `preconditions` can be used to define custom filters for more granular control of when a rule should be applied.

## Operators

The following operators are currently supported for preconditon evaluation:
- Equals
- NotEquals
- In
- NotIn

## Matching requests without a service account

In this example, the rule is only applied to requests from service accounts i.e. when the `{{serviceAccountName}}` is not empty.


```yaml
  - name: generate-owner-role
    match:
      resources:
        kinds:
        - Namespace
    preconditions:
    - key: "{{serviceAccountName}}"
      operator: NotEqual
      value: ""
```

## Matching requests from specific service accounts

In this example, the rule is only applied to requests from service account with name `build-default` and `build-base`.


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


