---
title: Preconditions
description: Fine-grained control of policy rule execution based on variables and expressions.
sidebar:
  order: 120
---

Preconditions allow for more fine-grained selection of resources than the options allowed by `match` and `exclude` statements. Preconditions consist of one or more expressions which are evaluated after a resource has been successfully matched (and not excluded) by a rule. They are powerful in that they allow you access to variables, JMESPath filters, operators, and other constructs which can be used to precisely select when a rule should be evaluated. When preconditions are evaluated to an overall TRUE result, processing of the rule body begins.

For example, if you wished to apply policy to all Kubernetes Services which were of type `NodePort`, since neither the `match`/`exclude` blocks provide access to fields within a resource's `spec`, a precondition could be used. In the below rule, while all Services are initially selected by Kyverno, only the ones which have the field `spec.type` set to `NodePort` will go on to be processed to ensure the field `spec.externalTrafficPolicy` equals a value of `Local`.

```yaml
rules:
  - name: validate-nodeport-trafficpolicy
    match:
      any:
        - resources:
            kinds:
              - Service
    preconditions:
      all:
        - key: '{{ request.object.spec.type }}'
          operator: Equals
          value: NodePort
    validate:
      message: 'All NodePort Services must use an externalTrafficPolicy of Local.'
      pattern:
        spec:
          externalTrafficPolicy: Local
```

While, in the above snippet, a precondition is used, it would have been possible to also express this desire using multiple types of [anchors](/docs/policy-types/cluster-policy/validate#anchors) instead. It is more common for preconditions to exist when needing to perform more advanced comparisons between [context data](/docs/policy-types/cluster-policy/external-data-sources) (e.g., results from a stored ConfigMap, Kubernetes API call, service call, etc.) and admission data. In the below snippet, a precondition is used to measure the length of an array of volumes coming from a Pod which are of type hostPath. Preconditions can use context variables, the JMESPath system, and perform comparisons between the two and more.

```yaml
rules:
  - name: check-hostpaths
    match:
      any:
        - resources:
            kinds:
              - Pod
    context:
      - name: hostpathvolnames
        variable:
          jmesPath: request.object.spec.volumes[?hostPath].name
          default: []
    preconditions:
      all:
        - key: '{{ length(hostpathvolnames) }}'
          operator: GreaterThan
          value: 0
```

Preconditions are similar in nature to [deny rules](/docs/policy-types/cluster-policy/validate#deny-rules) in that they are built of the same type of expressions and have the same fields. Also like deny rules, preconditions use [short circuiting](https://en.wikipedia.org/wiki/Short-circuit_evaluation) to stop or continue processing depending on whether they occur in an `any` or `all` block.

Because preconditions very commonly use variables in JMESPath format (e.g., `{{ request.object.spec.type }}`), there are some special considerations when it comes to their formatting. See the [JMESPath formatting page](/docs/policy-types/cluster-policy/jmespath#formatting) for further details.

When preconditions are used in the rule types which support reporting, a result will be scored as a `skip` if a resource is matched by a rule but discarded by the combined preconditions. Note that this result differs from if it applies to an `exclude` block where the resource is immediately ignored.

Preconditions are also used in mutate rules inside a `foreach` loop for more granular selection of array entries to be mutated. See the documentation [here](/docs/policy-types/cluster-policy/mutate#foreach) for more details.

## Any and All Statements

Preconditions are evaluated by nesting the expressions under `any` and/or `all` statements. This gives you further power in building more precise logic for how the rule is triggered. Either or both may be used simultaneously in the same rule. For each `any`/`all` statement, each block must overall evaluate to TRUE for the precondition to be processed. If any of the `any` / `all` statement blocks does not evaluate to TRUE, preconditions will not be satisfied and thus the rule will not be applicable.

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
          command: ['sleep', '9999']
```

By using `any` and `all` blocks in the preconditions statement, it is possible to gain more granular control over when rules are evaluated. In the below sample policy, using an `any` block will allow the preconditions to work as a logical OR operation. This policy will only perform the validation if labels `color=blue` OR `app=busybox` are found. Because the Deployment manifest above specified `color=red`, using the `any` statement still allows the validation to occur.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: any-all-preconditions
spec:
  background: false
  rules:
    - name: any-all-rule
      match:
        any:
          - resources:
              kinds:
                - Deployment
      preconditions:
        any:
          - key: "{{ request.object.metadata.labels.color || '' }}"
            operator: Equals
            value: blue
          - key: "{{ request.object.metadata.labels.app || '' }}"
            operator: Equals
            value: busybox
      validate:
        failureAction: Enforce
        message: 'Busybox must be used based on this label combination.'
        pattern:
          spec:
            template:
              spec:
                containers:
                  - name: '*busybox*'
```

:::note[Note]
Since preconditions often consider fields in Kubernetes resources which are optional, it is often necessary to use a JMESPath syntax for non-existence checks (`|| ''`). See the JMESPath page [here](/docs/policy-types/cluster-policy/jmespath#non-existence-checks) for more details on why these are necessary and how to use them.
:::

Adding an `all` block means that all of the statements within that block must evaluate to TRUE for the whole block to be considered TRUE. In this policy, in addition to the previous `any` conditions, it checks that all of `animal=cow` and `env=qa` but changes the validation to look for a container with name having the string `foxes` in it. Because the `any` block and `all` block evaluate to TRUE, the validation is performed, however the Deployment will fail to create because the name is still `busybox`. If one of the statements in the `all` block is changed so the value of the checked label is not among those in the Deployment, the rule will not be processed and the Deployment will be created.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: any-all-preconditions
spec:
  background: false
  rules:
    - name: any-all-rule
      match:
        any:
          - resources:
              kinds:
                - Deployment
      preconditions:
        any:
          - key: "{{ request.object.metadata.labels.color || '' }}"
            operator: Equals
            value: blue
          - key: "{{ request.object.metadata.labels.app || '' }}"
            operator: Equals
            value: busybox
        all:
          - key: "{{ request.object.metadata.labels.animal || '' }}"
            operator: Equals
            value: cow
          - key: "{{ request.object.metadata.labels.env || '' }}"
            operator: Equals
            value: qa
      validate:
        failureAction: Enforce
        message: 'Foxes must be used based on this label combination.'
        pattern:
          spec:
            template:
              spec:
                containers:
                  - name: '*foxes*'
```

## Operators

The following operators are currently supported in conditional expressions wherever expressions are used:

- Equals
- NotEquals
- AnyIn
- AllIn
- AnyNotIn
- AllNotIn
- GreaterThan
- GreaterThanOrEquals
- LessThan
- LessThanOrEquals
- DurationGreaterThan
- DurationGreaterThanOrEquals
- DurationLessThan
- DurationLessThanOrEquals

Operators `Equals` and `NotEquals` are only applicable when comparing a single key to a single value and not an array. Set operators should be used instead in those cases.

The set operators, `AnyIn`, `AllIn`, `AnyNotIn` and `AllNotIn`, are the most commonly-used and most flexible operators which support one-to-one, one-to-many, many-to-one, and many-to-many comparisons. They support string, integer, and boolean types.

- `AnyIn`: checks that ANY of the keys are found in the values.
- `AllIn`: checks that ALL of the keys are found in the values.
- `AnyNotIn`: checks that ANY of the keys are NOT found in the values.
- `AllNotIn`: checks that ALL of the keys are NOT found in the values.

The duration operators can be used for things such as validating an annotation that is a duration unit. Duration operators expect numeric key or value as seconds or as a string that is a valid Go time duration, eg: "1h". The string units supported are `s` (second), `m` (minute) and `h` (hour). Full details on supported duration strings are covered by [time.ParseDuration](https://pkg.go.dev/time#ParseDuration).

The `GreaterThan`, `GreaterThanOrEquals`, `LessThan` and `LessThanOrEquals` operators can also be used with Kubernetes resource quantities. Any value handled by [resource.ParseQuantity](https://pkg.go.dev/k8s.io/apimachinery/pkg/api/resource#ParseQuantity) can be used, this includes comparing values that have different scales. Note that these operators can only operate on a single value currently and not an array of values, even if the array contains a single string.

Example:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: resource-quantities
spec:
  background: false
  rules:
    - name: memory-limit
      match:
        any:
          - resources:
              kinds:
                - Pod
      preconditions:
        any:
          - key: '{{request.object.spec.containers[0].resources.requests.memory}}'
            operator: LessThan
            value: 1Gi
```

## Wildcard Matches

String values support the use of wildcards to allow for partial matches. The following example matches on Ingress resources where the first rule does not have a `host` which ends in `.mycompany.com`.

```yaml
- name: mutate-rules-host
  match:
    resources:
      kinds:
        - Ingress
  preconditions:
    all:
      - key: '{{request.object.spec.rules[0].host}}'
        operator: NotEquals
        value: '*.mycompany.com'
```

## Matching requests without a service account

Preconditions have access to [predefined variables](/docs/policy-types/cluster-policy/variables#pre-defined-variables) from Kyverno further extending their power.

In this example, the rule is only applied to requests from ServiceAccounts (i.e. when the `{{serviceAccountName}}` variable is not empty).

```yaml
- name: generate-owner-role
  match:
    any:
      - resources:
          kinds:
            - Namespace
  preconditions:
    any:
      - key: '{{serviceAccountName}}'
        operator: NotEquals
        value: ''
```

## Matching requests from specific service accounts

Preconditions support providing `key` and `value` fields as lists as well as simple strings.

In this example, the rule is only applied to requests from a ServiceAccount with name `build-default` and `build-base`.

```yaml
- name: generate-default-build-role
  match:
    any:
      - resources:
          kinds:
            - Namespace
  preconditions:
    any:
      - key: '{{serviceAccountName}}'
        operator: AnyIn
        value:
          - build-default
          - build-base
```

## Adding custom messages

Although preconditions do not produce a blocking effect similar to deny rules, they are capable of showing a custom message when an expressions fails. The message will be shown in the Kyverno log. The rule snippet below will print the message specified in the logs for the expression which evaluates to FALSE keeping in mind short circuiting.

```yaml
- name: message-rule
  match:
    any:
      - resources:
          kinds:
            - ConfigMap
  preconditions:
    all:
      - key: '{{ request.object.data.food }}'
        operator: Equals
        value: cheese
        message: My favorite food is cheese.
      - key: '{{ request.object.data.day }}'
        operator: Equals
        value: monday
        message: You have a case of the Mondays.
```
