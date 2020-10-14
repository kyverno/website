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
- Equal
- Equals
- NotEqual
- NotEquals
- In
- NotIn

## Deny requests without a service account

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

## Allow requests from specific service accounts

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

## Deny delete requests

This example prevents deletion of resources with a specific label:


```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
 name: deny-policy
spec:
 validationFailureAction: enforce
 background: false
 rules:
   - name: block-deletes-for-critical-apps
     match:
       resources:
         kinds:
         - Deployment
         selector:
           matchLabels:
             app: critical
     validate:
       message: |
        Deleting {{request.oldObject.kind}}/{{request.oldObject.metadata.name}} 
        is not allowed
       deny:
         conditions:
           - key: "{{request.operation}}"
             operator: In
             value: 
             - DELETE
```
