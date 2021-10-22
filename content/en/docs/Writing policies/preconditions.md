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

```sh
{{request.object.spec.template.metadata.annotations.\"foo.k8s.corp.net/bar\"}}
```

You may specify multiple statements in the `preconditions` field. The use of multiple `preconditions` statements function as a logical AND statement.

## Any and All Statements

You may further control how `preconditions` are evaluated by nesting the expressions under `any` and/or `all` statements. This gives you further power in building more precise logic for how the rule is triggered. Either or both may be used simultaneously in the same rule with multiple `any` statements also being possible (multiple `all` statements would be redundant). For each `any`/`all` statement, each block must overall evaluate to TRUE for the precondition to be processed. If any of the `any` / `all` statement blocks does not evaluate to TRUE, `preconditions` will not be satisfied and thus the rule will not be applicable.

{{% alert title="Note" color="info" %}}
`any` and `all` statements are available starting in Kyverno v1.3.4 but are optional. Users can continue to write multiple statements inside the `preconditions` field and have them evaluated as a logical AND statement.
{{% /alert %}}

For example, consider a Deployment manifest which features many different labels as follows.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox
  labels:
    app: busybox
    color: red
    animal: cow
    food: pizza
    car: jeep
    env: qa
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - image: busybox:1.28
        name: busybox
        command: ["sleep", "9999"]
```

By using `any` and `all` blocks in the `preconditions` statement, it is possible to gain more granular control over when rules are evaluated. In the below sample policy, using an `any` block will allow the `preconditions` to work as a logical OR operation. This policy will only perform the validation if labels `color=blue` OR `app=busybox` are found. Because the Deployment manifest above specified `color=red`, using the `any` statement still allows the validation to occur.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: any-all-preconditions
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: any-all-rule
    match:
      resources:
        kinds:
        - Deployment
    preconditions:
      any:
      - key: "{{request.object.metadata.labels.color}}"
        operator: Equals
        value: blue
      - key: "{{request.object.metadata.labels.app}}"
        operator: Equals
        value: busybox
    validate:
      message: "Busybox must be used based on this label combination."
      pattern:
        spec:
          template:
            spec:
              containers:
              - name: "*busybox*"
```

Adding an `all` block means that all of the statements within that block must evaluate to TRUE for the whole block to be considered TRUE. In this policy, in addition to the previous `any` conditions, it checks that all of `animal=cow` and `env=prod` but changes the validation to look for a container with name having the string `foxes` in it. Because the `any` block and `all` block evaluate to TRUE, the validation is performed, however the Deployment will fail to create because the name is still `busybox`. If one of the statements in the `all` block is changed so the value of the checked label is not among those in the Deployment, the rule will not be processed and the Deployment will be created.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: any-all-preconditions
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: any-all-rule
    match:
      resources:
        kinds:
        - Deployment
    preconditions:
      any:
      - key: "{{request.object.metadata.labels.color}}"
        operator: Equals
        value: blue
      - key: "{{request.object.metadata.labels.app}}"
        operator: Equals
        value: busybox
      all:
      - key: "{{request.object.metadata.labels.animal}}"
        operator: Equals
        value: cow
      - key: "{{request.object.metadata.labels.env}}"
        operator: Equals
        value: qa
    validate:
      message: "Foxes must be used based on this label combination."
      pattern:
        spec:
          template:
            spec:
              containers:
              - name: "*foxes*"
```

## Operators

The following operators are currently supported for precondition evaluation:

- Equals
- NotEquals
- In
- NotIn
- GreaterThan
- GreaterThanOrEquals
- LessThan
- LessThanOrEquals
- DurationGreaterThan
- DurationGreaterThanOrEquals
- DurationLessThan
- DurationLessThanOrEquals

The set operators, `In` and `NotIn` support a set of strings as the value (e.g. In ["str1", "str2"]). They also allow you to specify a set of strings as the key (e.g. ["str1", "str2"] In ["str1", "str2", "str3"]). In this case `In` checks if **all** the strings part of the key are in the value set (i.e. key is a subset of value) and `NotIn` checks if **any** of the strings part of the key is **not** in the value set (i.e. key is not a subset of value). Sets of other types are currently not supported.

The duration operators can be used for things such as validating an annotation that is a duration unit. Duration operators expect numeric key or value as seconds or as a string that is a valid Go time duration, eg: "1h". The string units supported are `s` (second), `m` (minute) and `h` (hour).  Full details on supported duration strings are covered by <a href="https://pkg.go.dev/time#ParseDuration" target="-blank">time.ParseDuration</a>.

The `GreaterThan`, `GreaterThanOrEquals`, `LessThan` and `LessThanOrEquals` operators can also be used with Kubernetes resource quantities. Any value handled by <a href="https://pkg.go.dev/k8s.io/apimachinery/pkg/api/resource#ParseQuantity" target="_blank">resource.ParseQuantity</a> can be used, this includes comparing values that have different scales.

Example:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: resource-quantities
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: memory-limit
    match:
      resources:
        kinds:
        - Pod
    preconditions:
      any:
      - key: "{{request.object.spec.containers[*].resources.requests.memory}}"
        operator: LessThan
        value: 1Gi
```

## Wildcard Matches

String values support the use of wildcards to allow for partial matches. The following example matches on pods that have a container using a `bash` image.

```yaml
  - name: match-on-image
    match:
      resources:
        kinds:
        - Pods
    preconditions:
    - key: "{{request.object.spec.template.spec.containers.image}}"
      operator: Equals
      value: "bash:*"
```

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
