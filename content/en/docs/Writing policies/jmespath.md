---
title: JMESPath 
description: The JSON query language behind Kyverno.
weight: 12
---

[JMESPath](https://jmespath.org/) (pronounced "James path") is a JSON query language created by James Saryerwinnie and is the language that Kyverno supports to perform more complex selections of fields and values and also manipulation thereof by using one or more [filters](https://jmespath.org/specification.html#filter-expressions). If you're familiar with `kubectl` and Kubernetes already, this might ring a bell in that it's similar to [JSONPath](https://github.com/json-path/JsonPath). JMESPath can be used almost anywhere in Kyverno although is an optional component depending on the type and complexity of a Kyverno policy or rule that is being written. While many policies can be written with simple overlay patterns, others require more detailed selection and transformation. The latter is where JMESPath is useful.

While the complete specifications of JMESPath can be read on the official site's [specifications page](https://jmespath.org/specification.html), much of the specifics may not apply to Kubernetes use cases and further can be rather thick reading. This page serves as an easier guide and tutorial on how to learn and harness JMESPath for Kubernetes resources for use in crafting Kyverno policies. It should not be a replacement for the official JMESPath documentation but simply a use case specific guide to augment the already comprehensive literature.

## Getting Set Up

In order to position yourself for success with JMESPath expressions inside Kyverno policies, a few tools are recommended.

1. `kubectl`, the Kubernetes CLI [here](https://kubernetes.io/docs/tasks/tools/). While having `kubectl` is a given, it comes in handy especially when building a JMESPath expression around performing API lookups.

2. `kyverno`, the Kyverno CLI [here](https://github.com/kyverno/kyverno/releases) or via [krew](https://krew.sigs.k8s.io/). Kyverno acts as a webhook (when run in-cluster) but also as a standalone CLI when run outside giving you the ability to test policies and, more recently, to test custom JMESPath filters which are endemic to only Kyverno. With the `jp` subcommand, it contains the functionality present in the upstream `jp` [CLI tool](https://github.com/jmespath/jp) and also newer capabilities. It effectively allows you to test out JMESPath expressions live in a command line interface by passing in a JSON document and seeing the results without having to repeatedly test Kyverno policies.

3. `yq`, the YAML processor [here](https://github.com/mikefarah/yq). `yq` allows reading from a Kubernetes manifest and converting to JSON, which is helpful in order to be piped to `jp` in order to test expressions. As of Kyverno 1.7.0, the Kyverno CLI `jp` subcommand's `-f` flag also accepts YAML files in addition to JSON.

4. `jq`, the JSON processor [here](https://stedolan.github.io/jq/download/). `jq` is an extremely popular tool for working with JSON documents and has its own filter ability, but it's also useful in order to format JSON on the terminal for better visuals.

## Basics

JMESPath is used when you need fine-grained selection of a document and need to perform some type of query logic against the result. For example, if in a given field you need to refer to the value of another field either in the same resource or in a different one, you'll need to use JMESPath. This sample policy performs a simple mutation on a Pod to add a new label named `appns` and set the value of it based on the value of the Namespace in which that Pod is created.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-labels
spec:
  rules:
  - name: add-labels
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            appns: "{{request.namespace}}"
```

JMESPath expressions in most places in Kyverno must be enclosed in double curly braces like `{{request.namespace}}`. If an expression is used as the value of a field and contains nothing else, the expression needs to be wrapped in quotes: `appns: "{{request.namespace}}"`. If the value field contains other text outside of the expression, then it can be unquoted and treated as a string but this isn't strictly required: `message: The namespace name is {{request.namespace}}`.

When building a JMESPath expression, a dot (`.`) character is called a "sub-expression" and used to descend into nested structures. In the `{{request.namespace}}` example, this expression is looking for the top-most object the key of which is called `request` and then looking for a child object the key of which is called `namespace`. Whatever the value of the `namespace` key is will be inserted where the expression is written. Given the below AdmissionReview snippet, which will be explained in a moment, the value that would result from the `{{request.namespace}}` expression is `foo`.

```json
{
    "apiVersion": "admission.k8s.io/v1",
    "kind": "AdmissionReview",
    "request": {
        "namespace": "foo"
    }
}
```

When submitting a Pod, which matches the policy above, the result which gets created after Kyverno has mutated it would then look something like this.

**Incoming Pod**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: busybox
    image: busybox
```

**Outgoing Pod**

```yaml {hl_lines=[5,6]}
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  labels:
    appns: foo
spec:
  containers:
  - name: busybox
    image: busybox
```

Notice in the highlighted lines that the new label `appns` has been added to the Pod and the value set equal to the expression `{{request.namespace}}` which, in this instance, happened to be `foo` because it was created in the `foo` Namespace. Should this Pod be created in another Namespace called `bar`, as you might guess, the label would be `appns: bar`. And this is a nice segue into AdmissionReview resources.

{{% alert title="Remember" color="primary" %}}
JMESPath, like JSONPath, is a query language _for JSON_ and, as such, it only works when fed with a JSON-encoded document. Although most work with Kubernetes resources using YAML, the API server will convert this to JSON internally and use that format when storing and sending objects to webhooks like Kyverno. This is why the program `yq` will be invaluable when building the correct expression based upon Kubernetes manifests written in YAML.
{{% /alert %}}

### AdmissionReview

Kyverno is an example, although there are many others, of an [admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#what-are-they). As the name implies, these are pieces of software which have some stake in whether a given resource is _admitted_ into the cluster or not. They may be either validating, mutating, or both. The latter applies to Kyverno as it has both capabilities. For a graphical representation of the order in which these requests make their way into Kyverno, see the [introduction page](/docs/introduction/#how-kyverno-works).

{{% alert title="Note" color="info" %}}
As the name "admission" implies, this process only takes place when an object _does not_ already exist. Pre-existing objects have already been admitted successfully in the past and therefore do not apply here. Certain other _operations_ on pre-existing objects, however, are subject to the admissions process including examples like executing (`exec`) commands inside Pods and deleting objects but, importantly, not when reading back objects.
{{% /alert %}}

When a resource that matches the criteria of a selection statement gets sent to the Kubernetes API server, after the API server performs some basic modifications to it, it then gets sent to webhooks which have told the API server via a MutatingWebhookConfiguration or ValidatingWebhookConfiguration resource--which Kyverno creates for you based upon the policies you write--that it wishes to be informed. The API server will "wrap" the matching resource in another resource called an [AdmissionReview](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#request) which contains a bunch of other descriptive data about that request, for example what _type_ or request this is (like a creation or deletion), the user who submitted the request, and, most importantly, the contents of the resource itself. Given the simple Pod example above that a user wishes to be created in the `foo` Namespace, the AdmissionReview request that hits Kyverno might look like following.

```json
{
    "kind": "AdmissionReview",
    "apiVersion": "admission.k8s.io/v1",
    "request": {
        "uid": "3d4fc6c1-7906-47d9-b7da-fc2b22353643",
        "kind": {
            "group": "",
            "version": "v1",
            "kind": "Pod"
        },
        "resource": {
            "group": "",
            "version": "v1",
            "resource": "pods"
        },
        "requestKind": {
            "group": "",
            "version": "v1",
            "kind": "Pod"
        },
        "requestResource": {
            "group": "",
            "version": "v1",
            "resource": "pods"
        },
        "name": "mypod",
        "namespace": "foo",
        "operation": "CREATE",
        "userInfo": {
            "username": "thomas",
            "uid": "404d34c4-47ff-4d40-b25b-4ec4197cdf63"
        },
        "object": {
            "kind": "Pod",
            "apiVersion": "v1",
            "metadata": {
                "name": "mypod",
                "creationTimestamp": null
            },
            "spec": {
                "containers": [
                    {
                        "name": "busybox",
                        "image": "busybox",
                        "resources": {}
                    }
                ]
            },
            "status": {}
        },
        "oldObject": null,
        "dryRun": false,
        "options": {
            "kind": "CreateOptions",
            "apiVersion": "meta.k8s.io/v1"
        }
    }
}
```

As can be seen, the full Pod is represented along with other metadata surrounding its creation.

These AdmissionReview resources serve as the most common source of data when building JMESPath expressions, specifically `request.object`. For the other data properties which can be consumed via an AdmissionReview resource, refer back to the [variables page](/docs/writing-policies/variables/#variables-from-admission-review-requests).

## Formatting

Because there are various types of values in differing fields, there are differing ways values must be supplied to JMESPath expressions as inputs in order to generate not only a valid expression but produce the output desired. Specifying values in the correct format is key to this success. Values which are supported but need to be differentiated in formatting are numbers (i.e., an integer like `6` or a floating point like `6.7`), a quantity (i.e., a number with a unit of measure like `6Mi`), a duration (i.e., a number with a unit of time like `6h`), a [semver](https://semver.org/) (i.e., a version number like `1.2.3`), and others. Because Kyverno (and therefore most custom JMESPath filters built for Kyverno) is designed for Kubernetes, it is Kubernetes aware. Therefore, specifying \`6\` as an input to a filter is not the same as specifying \'6\' where the former is interpreted as "the number six" and latter as "six bytes". The _types_ which map to the possible values are either JSON or string. In JMESPath, these are [literal expression](https://jmespath.org/specification.html#literal-expressions) and [raw string literals](https://jmespath.org/specification.html#raw-string-literals). Use the table below to find how to format the type of value which should be supplied.

| Value Type   | Input Type | JMESPath Type | Formatting |
|--------------|------------|---------------|------------|
| Number       | Integer    | Literal       | backticks  |
| Quantity     | String     | Raw           | quotes     |
| Duration     | String     | Raw           | quotes     |
| Labels (map) | Object     | Literal       | backticks  |

Paths in a JMESPath expression may also need escaping or literal quoting depending on the contents. For example, in a ResourceQuota the following schema elements may be present:

```yaml
spec:
  hard:
    limits.memory: 3750Mi
    requests.cpu: "5"
```

To represent the `limits.memory` field in a JMESPath expression requires literal quoting of the key in order to avoid being interpreted as child nodes `limits` and `memory`. The expression would then be `{{ spec.hard.\"limits.memory\" }}`. A similar approach is needed when individual keys contain special characters, for example a dash (`-`). Quoting and then escaping is similarly needed there, ex., `{{ images.containers.\"my-container\".tag }}`.

Quoting of an overall JMESPath expression can also impact how it is evaluated. For fields which only contain a JMESPath expression (ex., `key: "{{ request.object.spec.template.spec.containers[].image | contains(@, 'nginx') }}"`) it is important to use double quotes on the outer expression (as shown) and single quotes for input fields of type string. Even if no JMESPath filters are used, any expression should be wrapped in double quotes to avoid unintended evaluation.

## Useful Patterns

When developing policies for Kubernetes resources, there are several patterns which are common where JMESPath can be useful. This section attempts to capture example patterns that have been observed through real world use cases and how to write JMESPath for them.

### Flattening Arrays

In many Kubernetes resources, arrays of both objects and strings are very common. For example, in Pod resources, `spec.containers[]` is an array of objects where each object in the array may optionally specify `args[]` which is an array of strings. Policy very often must be able to peer into these arrays and match a given pattern with enough flexibility to implement a sufficiently advanced level of control. The JMESPath [flatten operator](https://jmespath.org/specification.html#flatten-operator) can help to simplify these checks so writing Kyverno policy becomes less verbose and require fewer rules.

Pods may contain multiple containers and in different locations in the Pod spec tree, for example `ephemeralContainers[]`, `initContainers[]`, and `containers[]`. Regardless of where the container occurs, a container is still a container. And although it's possible to name each location in the spec individually, this produces rule or expression sprawl. It is often more efficient to collect all the containers together in a single query for processing. Consider the example Pod below.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  initContainers:
  - name: redis
    image: redis
  containers:
  - name: busybox
    image: busybox
  - name: nginx
    image: nginx
```

Assume this Pod is saved as `pod.yaml` locally, its `containers[]` may be queried using a simple JMESPath expression after using `yq` to output it as a JSON document then piped into the [Kyverno CLI](/docs/kyverno-cli/#jp).

```sh
$ yq e pod.yaml -o json | kyverno jp "spec.containers[]"
[
  {
    "image": "busybox",
    "name": "busybox"
  },
  {
    "image": "nginx",
    "name": "nginx"
  }
]
```

The above output shows the return of an array of objects as expected where each object is the container. But by using a [multi-select list](https://jmespath.org/specification.html#multiselect-list), the `initContainer[]` array may also be parsed.

```sh
$ yq e pod.yaml -o json | kyverno jp "spec.[initContainers, containers]"
[
  [
    {
      "image": "redis",
      "name": "redis"
    }
  ],
  [
    {
      "image": "busybox",
      "name": "busybox"
    },
    {
      "image": "nginx",
      "name": "nginx"
    }
  ]
]
```

In the above, a multi-select list `spec.[initContainers, containers]` "wraps" the results of both `initContainers[]` and `containers[]` in parent array thereby producing an array consisting of multiple arrays. By using the [flatten operator](https://jmespath.org/specification.html#flatten-operator), these results can be collapsed into just a single array.

```sh
$ yq e pod.yaml -o json | kyverno jp "spec.[initContainers, containers][]"
[
  {
    "image": "redis",
    "name": "redis"
  },
  {
    "image": "busybox",
    "name": "busybox"
  },
  {
    "image": "nginx",
    "name": "nginx"
  }
]
```

With just a single array in which all containers, regardless of where they are, occur in a single hierarchy, it becomes easier to process the data for relevant fields and take action. For example, if you wished to write a policy which forbid using the image named `busybox` in a Pod, by flattening all containers it becomes easier to isolate just the `image` field. Because it does not matter where `busybox` may be found, if found the entire Pod must be rejected. Therefore, while loops or other methods may work, a more efficient method is to simply gather all containers across the Pod and flatten them.

```sh
$ yq e pod.yaml -o json | kyverno jp "spec.[initContainers, containers][].image"
[
  "redis",
  "busybox",
  "nginx"
]
```

With all of the images stored in a simple array, the values can be parsed much easier and just one expression written to contain the necessary logic.

```yaml
deny:
  conditions:
    any:
    - key: busybox
      operator: AnyIn
      value: "{{request.object.spec.[initContainers, containers][].image}}"
```

### Non-Existence Checks

It is common for a JMESPath expression to name a specific field so that its value may be acted upon. For example, in the [basics section](#basics) above, the label `appns` is written to a Pod via a mutate rule which does not contain it or is set to a different value. A Kyverno validate rule which exists to check the value of that label or any other field is commonplace. Because the schema for many Kubernetes resources is flexible in that many fields are optional, policy rules must contend with the scenario in which a matching resource does not contain the field being checked. When using JMESPath to check the value of such a field, a simple expression might be written `{{request.object.metadata.labels.appns}}`. If a resource is submitted which either does not contain any labels at all or does not contain a label with the specified key then the expression cannot be evaluated. An error is likely to result similar to `JMESPath query failed: Unknown key "labels" in path`. In these types of cases, the JMESPath expression should use a non-existence check in the form of the [OR expression](https://jmespath.org/specification.html#or-expressions) followed by a "default" value if the field does not exist. The resulting full expression which will correctly evaluate is `{{request.object.metadata.labels.appns || ''}}`. This expression reads, "take the value of the key request.object.metadata.labels.appns or, if it does not exist, set it to an empty string". Note that the value on the right side may need to be customized given the ultimate use of the value expected to be produced. This non-existence pattern can be used in almost any JMESPath expression to mitigate scenarios in which the initial query may be invalid.

### Matching Special Characters

Kyverno reserves [special behavior for wildcard characters](/docs/writing-policies/validate/#wildcards) such as `*` and `?`. However, certain Kubernetes resources permit wildcards as values in various fields which are treated literally. It may be necessary to construct a policy which validates literal usage of such wildcards. Using the JMESPath [`contains()`](https://jmespath.org/specification.html#contains) filter it is possible to do so. The below policy shows how to use `contains()` to match on wildcards as literal characters.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-ingress-wildcard
spec:
  validationFailureAction: enforce
  rules:
    - name: block-ingress-wildcard
      match:
        any:
        - resources:
            kinds:
              - Ingress
      validate:
        message: "Wildcards are not permitted as hosts."
        foreach:
        - list: "request.object.spec.rules"
          deny:
            conditions:
              any:
              - key: "{{ contains(element.host, '*') }}"
                operator: Equals
                value: true
```

## Custom Filters

In addition to the filters available in the upstream JMESPath library which Kyverno uses, there are also many new and custom filters developed for Kyverno's use found nowhere else. These filters augment the already robust capabilities of JMESPath to bring new functionality and capabilities which help solve common use cases in running Kubernetes. The filters endemic to Kyverno can be used in addition to any of those found in the upstream JMESPath library used by Kyverno and do not represent replaced or removed functionality.

For instructions on how to test these filters in a standalone method (i.e., outside of Kyverno policy), see the [documentation](/docs/kyverno-cli/#jp) on the `kyverno jp` subcommand.

Information on each subcommand, its inputs and output, and specific usage instructions can be found below along with helpful and common use cases that have been identified.

### Add

<details><summary>Expand</summary>
<p>

The `add()` filter very simply adds two values and produces a sum. The official JMESPath library does not include most basic arithmetic operators such as add, subtract, multiply, and divide, the exception being `sum()` as documented [here](https://jmespath.org/specification.html#sum). While `sum()` is useful in that it accepts an array of integers as an input, `add()` is useful as a simplified filter when only two individual values need to be summed. Note that `add()` here is different from the `length()` [filter](https://jmespath.org/specification.html#length) which is used to obtain a _count_ of a certain number of items. Use `add()` instead when you have values of two fields you wish to add together.

`add()` is also value-aware (based on the formatting used for the inputs) and is capable of adding numbers, quantities, and durations without any form of unit conversion.

Arithmetic filters like `add()` currently accept inputs in the following formats.

* Number (ex., \`10\`)
* Quantity (ex., '10Mi')
* Duration (ex., '10h')

Note that how the inputs are enclosed determines how Kyverno interprets their type. Numbers enclosed in back ticks are scalar values while quantities and durations are enclosed in single quotes thus treating them as strings. Using the correct enclosing character is important because, in Kubernetes "regular" numbers are treated implicitly as units of measure. The number written \`10\` is interpreted as an integer or "the number ten" whereas '10' is interpreted as a string or "ten bytes". See the [Formatting](#formatting) section above for more details.

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| Number             | Number             | Number   |
| Quantity or Number | Quantity or Number | Quantity |
| Duration or Number | Duration or Number | Duration |
<br>
Some specific behaviors to note:

* If a duration ('1h') and a number (\`5\`) are the inputs, the number will be interpreted as seconds resulting in a sum of `1h0m5s`.
* Because of durations being a string just like [resource quantities](https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/), and the minutes unit of "m" also present in quantities interpreted as the "milli" prefix, there is no support for minutes.

**Example:** This policy denies a Pod if any of its containers specify memory requests and limits in excess of 200Mi.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-demo
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: add-demo
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      any:
      - key: "{{ request.operation }}"
        operator: In
        value: ["CREATE","UPDATE"]
    validate:
      message: "The total memory defined in requests and limits must not exceed 200Mi."
      foreach:
      - list: "request.object.spec.containers"
        deny:
          conditions:
            any:
            - key: "{{ add('{{ element.resources.requests.memory || `0` }}', '{{ element.resources.limits.memory || `0` }}') }}"
              operator: GreaterThan
              value: 200Mi
```

</p>
</details>

### Base64_decode

<details><summary>Expand</summary>
<p>

The `base64_decode()` filter takes in a base64-encoded string and produces the decoded output similar to the tool and command `base64 --decode`. This can be useful when working with Kubernetes Secrets and deciphering their values in order to take action on them in a policy.

| Input 1 | Output   |
|---------|----------|
| String  | String   |
<br>
Some specific behaviors to note:

* Base64-encoded strings with newline characters will be printed back with them inline.

**Example:** This policy checks every container, initContainer, and ephemeralContainer in a Pod and decodes a Secret having the path `data.license` to ensure it does not refer to a prohibited license key.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: base64-decode-demo
spec:
  background: false
  validationFailureAction: enforce
  rules:
  - name: base64-decode-demo
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      all:
      - key: "{{ request.object.spec.[containers, initContainers, ephemeralContainers][].env[].valueFrom.secretKeyRef || '' | length(@) }}"
        operator: GreaterThanOrEquals
        value: 1
      - key: "{{request.operation}}"
        operator: NotEquals
        value: DELETE
    validate:
      message: This license key may not be consumed by a Secret.
      foreach:
      - list: "request.object.spec.[containers, initContainers, ephemeralContainers][].env[].valueFrom.secretKeyRef"
        context:
        - name: status
          apiCall:
            jmesPath: "data.license"
            urlPath: "/api/v1/namespaces/{{request.namespace}}/secrets/{{element.name}}"
        deny:
          conditions:
            any:
            - key: "{{ status | base64_decode(@) }}"
              operator: Equals
              value: W0247-4RXD3-6TW0F-0FD63-64EFD-38180
```

</p>
</details>

### Base64_encode

<details><summary>Expand</summary>
<p>

The `base64_encode()` filter is the inverse of the `base64_decode()` filter and takes in a regular, plaintext and unencoded string and produces a base64-encoded output similar to the tool and command `base64`. This can be useful when working with Kubernetes Secrets by encoding data into the base64 format which is the only acceptable format for Kubernetes Secrets.

| Input 1 | Output   |
|---------|----------|
| String  | String   |
<br>

**Example:** This policy generates a Secret when a new Namespace is created the contents of which is the value of an annotation named `corpkey`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: base64-encode-demo
spec:
  rules:
  - name: gen-supkey
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      apiVersion: v1
      kind: Secret
      name: sup-key
      namespace: "{{request.object.metadata.name}}"
      synchronize: false
      data:
        data:
          token: "{{ base64_encode('{{ request.object.metadata.annotations.corpkey }}') }}"
```

</p>
</details>

### Compare

<details><summary>Expand</summary>
<p>

The `compare()` filter is provided as an analog to the [inbuilt function to Golang](https://pkg.go.dev/strings#Compare) of the same name. It compares two strings [lexicographically](https://en.wikipedia.org/wiki/Lexicographic_order) where the first string is compared against the second. If both strings are equal, the result is `0` (ex., "a" compared to "a"). If the first is in lower lexical order than the second, the result is `-1` (ex., "a" compared to "b"). And if the first is in higher order than the second, the result is `1` (ex., "b" compared to "a"). Kyverno also has built-in [operators](/docs/writing-policies/preconditions/#operators) for string comparison where `Equals` is usually the most common, and in most use cases it is more practical to use the `Equals` operator in expressions such as preconditions and `deny.conditions` blocks.

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| String             | String             | Number   |

<br>

**Example:** This policy will write a new label called `dictionary` into a Service putting into order the values of two annotations if the order of the first comes before the second.

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: compare-demo
spec:
  background: false
  rules:
  - name: write-dictionary
    match:
      any:
      - resources:
          kinds:
          - Service
    preconditions:
      any:
      - key: "{{ compare('{{request.object.metadata.annotations.foo}}', '{{request.object.metadata.annotations.bar}}') }}"
        operator: LessThan
        value: 0
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            dictionary: "{{request.object.metadata.annotations.foo}}-{{request.object.metadata.annotations.bar}}"
```

</p>
</details>

### Divide

<details><summary>Expand</summary>
<p>

The `divide()` filter performs arithmetic divide capabilities between two input fields and produces an output quotient. Like other arithmetic custom filters, it is input aware based on the type passed and, for quantities, allows auto conversion between units of measure. For example, dividing 10Mi (ten mebibytes) by 5Ki (five kibibytes) results in the value 5120 as units are first normalized and then [canceled](https://www.thoughtco.com/cancel-units-in-chemistry-metric-conversions-604149) through division. The `divide()` filter is currently under development to better account for all permutations of input types, however the below table captures the most common and practical use cases.

Arithmetic filters like `divide()` currently accept inputs in the following formats.

* Number (ex., \`10\`)
* Quantity (ex., '10Mi')
* Duration (ex., '10h')

Note that how the inputs are enclosed determines how Kyverno interprets their type. Numbers enclosed in back ticks are scalar values while quantities and durations are enclosed in single quotes thus treating them as strings. Using the correct enclosing character is important because, in Kubernetes "regular" numbers are treated implicitly as units of measure. The number written \`10\` is interpreted as an integer or "the number ten" whereas '10' is interpreted as a string or "ten bytes". See the [Formatting](#formatting) section above for more details.

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| Number             | Number             | Number   |
| Quantity           | Number             | Quantity |
| Quantity           | Quantity           | Number   |
| Duration           | Number             | Duration |
| Duration           | Duration           | Number   |

<br>

**Example:** This policy will check every container in a Pod and ensure that memory limits are no more than 2.5x its requests.

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-resources-as-ratio
spec:
  validationFailureAction: audit
  rules:
  - name: check-memory-requests-limits
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      any:
      - key: "{{ request.operation }}"
        operator: In
        value:
        - CREATE
        - UPDATE
    validate:
      message: Limits may not exceed 2.5x the requests.
      foreach:
      - list: "request.object.spec.containers"
        deny:
          conditions:
            any:
              # Set resources.limits.memory equal to zero if not present and resources.requests.memory equal to 1m rather than zero
              # to avoid undefined division error. No memory request in this case is basically the same as 1m. Kubernetes API server
              # will automatically set requests=limits if only limits is defined.
            - key: "{{ divide('{{ element.resources.limits.memory || '0' }}', '{{ element.resources.requests.memory || '1m' }}') }}"
              operator: GreaterThan
              value: 2.5
```

</p>
</details>

### Equal_fold

<details><summary>Expand</summary>
<p>

The `equal_fold()` filter is designed to provide text [case folding](https://www.w3.org/TR/charmod-norm/#dfn-case-folding) for two sets of strings as inputs. Case folding allows comparing two strings for equivalency where the only differences are letter cases. The return is a boolean (either `true` or `false`). For example, comparing "pizza" to "Pizza" results in `true` because other than title case on "Pizza" the strings are equivalent. Likewise with "pizza" and "pIzZa". Comparing "pizza" to "APPLE" results in `false` because even once normalized to the same case, the strings are different.

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| String             | String             | Boolean  |

Related filters to `equal_fold()` are [`to_upper()`](#to_upper) and [`to_lower()`](#to_lower) which can also be used to normalize text for comparison.

<br>

**Example:** This policy will validate that a ConfigMap with a label named `dept` and the value of a key under `data` by the same name have the same case-insensitive value.

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: equal-fold-demo
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: validate-dept-label-data
    match:
      any:
      - resources:
          kinds:
          - ConfigMap
    validate:
      message: The dept label must equal the data.dept value aside from case.
      deny:
        conditions:
          any:
          - key: "{{ equal_fold('{{request.object.metadata.labels.dept}}', '{{request.object.data.dept}}') }}"
            operator: NotEquals
            value: true
```

</p>
</details>

### Items

<details><summary>Expand</summary>
<p>

The `items()` filter iterates on map keys (ex., annotations or labels) and converts them to an array of objects with key/value attributes with custom names.

For example, given the following map below

```json
{
  "team": "apple",
  "organization": "banana"
}
```

the `items()` filter can transform this into an array of objects which assigns a key and value of arbitrary name to each of the entries in the map.

```sh
$ echo '{"team" : "apple" , "organization" : "banana" }' | k kyverno jp "items(@, 'key', 'value')"
[
  {
    "key": "organization",
    "value": "banana"
  },
  {
    "key": "team",
    "value": "apple"
  }
]
```

| Input 1                  | Input 2            | Input 3    | Output        |
|--------------------------|--------------------|------------|---------------|
| Map (Object)             | String             | String     | Array/Object  |

<br>

Related filter to `items()` is its inverse, [`object_from_list()`](#object_from_list).

<br>

**Example:** This policy will take the labels on a Namespace `foobar` where a Bucket is deployed and add them as key/value elements to the `spec.forProvider.tagging.tagSet[]` array.

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: test-policy
spec:
  background: false
  rules:
  - name: test-rule
    match:
      any:
      - resources:
          kinds:
          - Bucket
    context:
    - name: nslabels
      apiCall:
        urlPath: /api/v1/namespaces/foobar
        jmesPath: items(metadata.labels,'key','value')
    mutate:
      foreach:
      - list: "nslabels"
        patchesJson6902: |-
          - path: "/spec/forProvider/tagging/tagSet/-1"
            op: add
            value: {"key": "{{element.key}}", "value": "{{element.value}}"}
```

Given a Namespace which looks like the following

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: foobar
  labels:
    team: apple
    organization: banana
```

and a Bucket which looks like the below

```yaml
apiVersion: s3.aws.crossplane.io/v1beta1
kind: Bucket
metadata:
  name: lambda-bucket
spec:
  forProvider:
    acl: private
    locationConstraint: eu-central-1
    accelerateConfiguration:
      status: Enabled
    versioningConfiguration:
      status: Enabled
    notificationConfiguration:
      lambdaFunctionConfigurations:
        - events: ["s3:ObjectCreated:*"]
          lambdaFunctionArn: arn:aws:lambda:eu-central-1:255932642927:function:lambda
    paymentConfiguration:
      payer: BucketOwner
    tagging:
      tagSet:
        - key: s3-bucket
          value: lambda-bucket
    objectLockEnabledForBucket: false
  providerConfigRef:
    name: default
```

the final `spec.forProvider.tagging.tagSet[]` will appear as below. Note that as of Kubernetes 1.21, the [immutable label](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#automatic-labelling) with key `kubernetes.io/metadata.name` and value equal to that of the Namespace name is automatically added to all Namespaces, hence the discrepancy when comparing Namespace with Bucket resource manifests above.

```sh
$ k get bucket lambda-bucket -o json | k kyverno jp "spec.forProvider.tagging.tagSet[]"
[
  {
    "key": "s3-bucket",
    "value": "lambda-bucket"
  },
  {
    "key": "kubernetes.io/metadata.name",
    "value": "foobar"
  },
  {
    "key": "organization",
    "value": "banana"
  },
  {
    "key": "team",
    "value": "apple"
  }
]
```

</p>
</details>

### Label_match

<details><summary>Expand</summary>
<p>

The `label_match()` filter compares two sets of Kubernetes labels (both key and value) and outputs a boolean response if they are equivalent. This custom filter is useful in that it functions similarly to how the Kubernetes API server associates one resource with another through label selectors. There may be one or multiple labels in each set. Labels may occur in any order. A response of `true` indicates all the labels (key and value) in the first input are accounted for in the second input. The second input, to which the first is compared, may have additional labels but it must have at minimum all those listed in the first input.

For example, the first collection compared to the second below results in `true` despite the ordering.

```json
{
  "dog": "lab",
  "color": "tan"
}
```

```json
{
  "color": "tan",
  "dog": "lab"  
}
```

Likewise, these two below collections also result in `true` when compared because the entirety of the first is found within the second.

```json
{
  "dog": "lab",
  "color": "tan"
}
```

```json
{
  "color": "tan",
  "weight":"chonky",
  "dog": "lab"  
}
```

These last two collections when compared are `false` because one of the values of one of the labels does not match what is in the first input.

```json
{
  "dog": "lab",
  "color": "tan"
}
```

```json
{
  "color": "black",
  "dog": "lab"  
}
```

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| Map (Object)       | Map (Object)       | Boolean  |

<br>

**Example:** This policy checks all incoming Deployments to ensure they have a matching, preexisting PodDisruptionBudget in the same Namespace. The `label_match()` filter is used in a query to count how many PDBs have a label set matching that of the incoming Deployment.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-pdb
spec:
  validationFailureAction: audit
  background: false
  rules:
  - name: require-pdb
    match:
      any:
      - resources:
          kinds:
          - Deployment
    preconditions:
      any:
      - key: "{{request.operation}}"
        operator: Equals
        value: CREATE
    context:
    - name: pdb_count
      apiCall:
        urlPath: "/apis/policy/v1beta1/namespaces/{{request.namespace}}/poddisruptionbudgets"
        jmesPath: "items[?label_match(spec.selector.matchLabels, `{{request.object.spec.template.metadata.labels}}`)] | length(@)"
    validate:
      message: "There is no corresponding PodDisruptionBudget found for this Deployment."
      deny:
        conditions:
          any:
          - key: "{{pdb_count}}"
            operator: LessThan
            value: 1
```

</p>
</details>

### Modulo

<details><summary>Expand</summary>
<p>

The `modulo()` filter returns the [modulo](https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/what-is-modular-arithmetic) or remainder between a division of two numbers. For example, the modulo of a division between `10` and `3` would be `1` since `3` can be divided into `10` only `3` times (equaling `9`) while producing `1` as a remainder.

Arithmetic filters like `modulo()` currently accept inputs in the following formats.

* Number (ex., \`10\`)
* Quantity (ex., '10Mi')
* Duration (ex., '10h')

Note that how the inputs are enclosed determines how Kyverno interprets their type. Numbers enclosed in back ticks are scalar values while quantities and durations are enclosed in single quotes thus treating them as strings. Using the correct enclosing character is important because, in Kubernetes "regular" numbers are treated implicitly as units of measure. The number written \`10\` is interpreted as an integer or "the number ten" whereas '10' is interpreted as a string or "ten bytes". See the [Formatting](#formatting) section above for more details.

| Input 1            | Input 2            | Output             |
|--------------------|--------------------|--------------------|
| Number             | Number             | Number             |

{{% pageinfo color="warning" %}}
The inputs list is currently under construction.
{{% /pageinfo %}}

<br>

**Example:** This policy checks every container and ensures that memory limits are evenly divisible by its requests.

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: modulo-demo
spec:
  validationFailureAction: audit
  rules:
  - name: check-memory-requests-limits
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      any:
      - key: "{{ request.operation }}"
        operator: In
        value:
        - CREATE
        - UPDATE
    validate:
      message: Limits must be evenly divisible by the requests.
      foreach:
      - list: "request.object.spec.containers"
        deny:
          conditions:
            any:
              # Set resources.limits.memory equal to zero if not present and resources.requests.memory equal to 1m rather than zero
              # to avoid undefined division error. No memory request in this case is basically the same as 1m. Kubernetes API server
              # will automatically set requests=limits if only limits is defined.
            - key: "{{ modulo('{{ element.resources.limits.memory || '0' }}', '{{ element.resources.requests.memory || '1m' }}') }}"
              operator: GreaterThan
              value: 0
```

</p>
</details>

### Multiply

<details><summary>Expand</summary>
<p>

The `multiply()` filter performs standard multiplication on two inputs producing an output product. Like other arithmetic filters, it is input aware and will produce output with appropriate units attached.

Arithmetic filters like `multiply()` currently accept inputs in the following formats.

* Number (ex., \`10\`)
* Quantity (ex., '10Mi')
* Duration (ex., '10h')

Note that how the inputs are enclosed determines how Kyverno interprets their type. Numbers enclosed in back ticks are scalar values while quantities and durations are enclosed in single quotes thus treating them as strings. Using the correct enclosing character is important because, in Kubernetes "regular" numbers are treated implicitly as units of measure. The number written \`10\` is interpreted as an integer or "the number ten" whereas '10' is interpreted as a string or "ten bytes". See the [Formatting](#formatting) section above for more details.

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| Number             | Number             | Number   |
| Quantity           | Number             | Quantity |
| Duration           | Number             | Duration |
<br>
Due to the [commutative property](https://www.khanacademy.org/math/arithmetic-home/multiply-divide/properties-of-multiplication/a/commutative-property-review) of multiplication, the ordering of inputs (unlike with `divide()`) is irrelevant.

{{% pageinfo color="warning" %}}
The inputs list is currently under construction.
{{% /pageinfo %}}

<br>

**Example:** This policy sets the replica count for a Deployment to a value of two times the current number of Nodes in a cluster.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: multiply-demo
spec:
  background: false
  rules:
    - name: multiply-replicas
      match:
        any:
        - resources:
            kinds:
            - Deployment
      context:
        - name: nodecount
          apiCall:
            urlPath: "/api/v1/nodes"
            jmesPath: "items[] | length(@)"
      mutate:
        patchStrategicMerge:
          spec:
            replicas: "{{ multiply( `{{nodecount}}`,`2`) }}"
```

</p>
</details>

### Object_from_list

<details><summary>Expand</summary>
<p>

The `object_from_list()` filter takes an array of objects and, based on the selected keys, produces a map. This is essentially the inverse of the [`items()`](#items) filter.

For example, given a Pod definition that looks like the following

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: object-from-list-demo
  labels:
    foo: bar
spec:
  containers:
  - name: containername01
    image: containerimage:01
    env:
    - name: KEY
      value: "123-456-789"
    - name: endpoint
      value: "licensing.corp.org"
```

you may want to convert the `spec.containers[].env[]` array of objects into a map where each entry in the map sets the key to the `name` and the value to the `value` fields. Running this through the `object_from_list()` filter will produce a map containing those entries.

```sh
$ k kyverno jp -f pod.yaml "object_from_lists(spec.containers[].env[].name,spec.containers[].env[].value)"
{
  "KEY": "123-456-789",
  "endpoint": "licensing.corp.org"
}
```

| Input 1            | Input 2            | Output        |
|--------------------|--------------------|---------------|
| Array/string       | Array/string       | Map (Object)  |

<br>

Related filter to `object_from_list()` is its inverse, [`items()`](#items).

<br>

**Example:** This policy converts all the environment variables across all containers in a Pod to labels and adds them to that same Pod. Any existing labels will not be replaced but rather augmented with the converted list.

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: object-from-list-demo
  annotations:
    pod-policies.kyverno.io/autogen-controllers: none
spec:
  background: false
  rules:
  - name: object-from-list-rule
    match:
      any:
      - resources:
          kinds:
          - Pod
    context:
    - name: envs
      variable: 
        jmesPath: request.object.spec.containers[].env[]
    - name: envs_to_labels
      variable: 
        jmesPath: object_from_lists(envs[].name, envs[].value)
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            "{{envs_to_labels}}"        
```

Given an incoming Pod that looks like the following

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: object-from-list-demo
  labels:
    foo: bar
spec:
  containers:
  - name: containername01
    image: containerimage:01
    env:
    - name: KEY
      value: "123-456-789"
    - name: ENDPOINT
      value: "licensing.corp.org"
  - name: containername02
    image: containerimage:02
    env:
    - name: ZONE
      value: "fl-west-03"
```

after applying the policy the resulting label set on the Pod appears as shown below.

```sh
$ k get pod/object-from-list-demo -o json | k kyverno jp "metadata.labels"
{
  "ENDPOINT": "licensing.corp.org",
  "KEY": "123-456-789",
  "ZONE": "fl-west-03",
  "foo": "bar"
}
```

</p>
</details>

### Parse_json

<details><summary>Expand</summary>
<p>

The `parse_json()` filter takes in a string of any valid encoded JSON and parses it into a fully-formed JSON object. This is useful because it allows Kyverno to access and work with string data that is stored anywhere which accepts strings as if it were "native" JSON data. Primary use cases for this filter include adding anything from snippets to whole documents as the values of labels, annotations, or ConfigMaps which should then be consumed by policy.

| Input 1            | Output   |
|--------------------|----------|
| String             | Any      |

<br>

**Example:** This policy uses the `parse_json()` filter to read a ConfigMap where a specified key contains JSON-encoded data (an array of strings in this case) and sets the supplementalGroups field of a Pod, if not already supplied, to that list.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: parse-json-demo
spec:
  rules:
  - name: parse-supplementalgroups-from-json
    match:
      any:
      - resources:
          kinds:
          - Pod
    context:
    - name: gidsMap
      configMap:
        name: user-gids-map
        namespace: default
    mutate:
      patchStrategicMerge:
        spec:
          securityContext:
            +(supplementalGroups): "{{ gidsMap.data.\"{{ request.object.metadata.labels.\"corp.com/service-account\" }}\" | parse_json(@)[*].to_number(@) }}"
```

The referenced ConfigMap may look similar to the below.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-gids-map
  namespace: default
data:
  finance: '["1001","1002"]'
```

</p>
</details>

### Parse_yaml

<details><summary>Expand</summary>
<p>

The `parse_yaml()` filter is the YAML equivalent of the [`parse_json()`](#parse_json) filter and takes in a string of any valid YAML document, serializes it into JSON, and parses it so it may be processed by JMESPath. Like `parse_json()`, this is useful because it allows Kyverno to access and work with string data that is stored anywhere which accepts strings as if it were "native" YAML data. Primary use cases for this filter include adding anything from snippets to whole documents as the values of labels, annotations, or ConfigMaps which should then be consumed by policy.

| Input 1            | Output   |
|--------------------|----------|
| String             | Any      |

<br>

**Example:** This policy parses a YAML document as the value of an annotation and uses the filtered value from a JMESPath expression in a variable substitution.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: parse-yaml-demo
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: check-goodbois
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "Only good bois allowed."
      deny:
        conditions:
        - key: "{{request.object.metadata.annotations.pets | parse_yaml(@).species.isGoodBoi }}"
          operator: NotEquals
          value: true
```

The referenced Pod may look similar to the below.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  labels:
    app: busybox
  annotations:
    pets: |-
      species:
        dog: lab
        name: dory
        color: black
        height: 15
        isGoodBoi: false
        snacks:
        - chimken
        - fries
        - pizza
spec:
  containers:
  - name: busybox
    image: busybox:1.28
```

</p>
</details>

### Path_canonicalize

<details><summary>Expand</summary>
<p>

The `path_canonicalize()` filter is used to normalize or canonicalize a given path by removing excess slashes. For example, a path supplied to the filter may be `/var//lib///kubelet` which will be canonicalized into `/var/lib/kubelet` which is how an operating system would interpret the former. This filter is primarily used as a circumvention protection for what would otherwise be strict string matches for paths.

| Input 1            | Output      |
|--------------------|-------------|
| String             | String      |

<br>

**Example:** This policy uses the `path_canonicalize()` filter to check the value of each `hostPath.path` field in a volume block in a Pod to ensure it does not attempt to mount the Containerd host socket.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: path-canonicalize-demo
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: disallow-mount-containerd-sock
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      foreach:
      - list: "request.object.spec.volumes[]"
        deny:
          conditions:
            any:
            - key: "{{ path_canonicalize(element.hostPath.path) }}"
              operator: Equals
              value: "/var/run/containerd/containerd.sock"
```

</p>
</details>

### Pattern_match

<details><summary>Expand</summary>
<p>

The `pattern_match()` filter is used to perform a simple, non-regex match by specifying an input pattern and the string or number to which it should be compared. The output is always a boolean response. This filter can be useful when wishing to make simpler comparisons, typically with strings or numbers involved. It avoids many of the complexities of regex while still support wildcards such as `*` (zero or more characters) and `?` (any one character). Note that since Kyverno supports overlay-style patterns and wildcards, use of `pattern_match()` is typically not needed in these scenarios. This filter is more valuable in dynamic lookup scenarios by using JMESPath variables for one or both inputs as exemplified below.

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| String             | String             | Boolean  |
| String             | Number             | Boolean  |

<br>

**Example:** This policy uses `pattern_match()` with dynamic inputs by fetching a pattern stored in a ConfigMap against an incoming Namespace label value.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: pattern-match-demo
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - match:
      any:
      - resources:
          kinds:
          - Namespace
    name: dept-billing-check
    context:
    - name: deptbillingcodes
      configMap:
        name: deptbillingcodes
        namespace: default
    validate:
      message: The department {{request.object.metadata.labels.dept}} must supply a matching billing code.
      deny:
        conditions:
          any:
            - key: "{{pattern_match('{{deptbillingcodes.data.{{request.object.metadata.labels.dept}}}}', '{{ request.object.metadata.labels.segbill}}') }}"
              operator: Equals
              value: false
```

The ConfigMap used as the source of the patterns may look like below.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: deptbillingcodes
data:
  eng_china: 158-6?-3*
  eng_india: 158-7?-4*
  busops: 145-0?-9*
  finops: 145-1?-5*
```

And a Namespace upon which the above ClusterPolicy may act can look like below.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ind-go
  labels:
    dept: eng_india
    segbill: 158-73-417
```

</p>
</details>

### Random

<details><summary>Expand</summary>
<p>

The `random()` filter is used to generate a random sequence of string data based upon the input pattern, expressed as regex. The input it takes is a combination of the composition of the pattern and the length of each pattern. This filter is useful in a variety of ways including generating unique resource names. Some other use cases include creating Pod hashes, auth tokens, license keys, GUIDs, and more.

For example, `random('[0-9a-z]{5}')` will produce a string output of exactly 5 characters long composed of numbers in the collection `0-9` and lower-case letters in the collection `a-z`. The output might be `"91t6f"`. More complex random output can be created by chaining multiple pattern and length combinations together. For example, to create a faux license key you could use the expression `random('[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}')` which may generate the output `"K284DW7Y-7LMT-XHR3-ZZ53-36366O8JVDG9"`.

| Input 1            | Output   |
|--------------------|----------|
| String             | String   |

<br>

**Example:** This policy uses `random()` to mutate a new Secret to add a label with key `randomoutput` and the value of which is `random-` followed by 6 random characters composed of lower-case letters `a-z` and numbers `0-9`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: ver-test
spec:
  rules:
  - name: test-ver-ver
    match:
      any:
      - resources:
          kinds:
          - Secret
    preconditions:
      all:
      - key: "{{request.operation}}"
        operator: In
        value:
        - CREATE
    context:
    - name: randomtest
      variable:
        jmesPath: random('[a-z0-9]{6}')
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            randomoutput: random-{{randomtest}}
```

</p>
</details>

### Regex_match

<details><summary>Expand</summary>
<p>

The `regex_match()` filter is similar to the [`pattern_match()`](#pattern_match) filter except it accepts standard [regular expressions](https://en.wikipedia.org/wiki/Regular_expression) as the comparison format. The first input is the pattern, specified in regex format, while the second is the string compared to the pattern which accepts either string or number. The output is always a boolean response. For example, the following two expressions, which check to ensure a number is in the range of one to seven, both evaluate to `true`.

```
regex_match('^[1-7]$',`1`)
regex_match('^[1-7]$','1')
```

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| String             | String             | Boolean  |
| String             | Number             | Boolean  |

<br>

**Example:** This policy checks that a PersistentVolumeClaim resource contains an annotation named `backup-schedule` and its value conforms to a standard Cron expression string. Note that the regular expression in the first input has had an additional backslash added to each backslash to be valid YAML. To use this sample regex in other applications, remove one of each double backslash pair.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: regex-match-demo
spec:
  background: true
  validationFailureAction: enforce
  rules:
  - name: validate-backup-schedule-annotation-cron
    match:
      any:
      - resources:
          kinds:
          - PersistentVolumeClaim
    validate:
      message: The annotation `backup-schedule` must be present and in cron format.
      deny:
        conditions:
          any:
          - key: "{{ regex_match('^((?:\\*|[0-5]?[0-9](?:(?:-[0-5]?[0-9])|(?:,[0-5]?[0-9])+)?)(?:\\/[0-9]+)?)\\s+((?:\\*|(?:1?[0-9]|2[0-3])(?:(?:-(?:1?[0-9]|2[0-3]))|(?:,(?:1?[0-9]|2[0-3]))+)?)(?:\\/[0-9]+)?)\\s+((?:\\*|(?:[1-9]|[1-2][0-9]|3[0-1])(?:(?:-(?:[1-9]|[1-2][0-9]|3[0-1]))|(?:,(?:[1-9]|[1-2][0-9]|3[0-1]))+)?)(?:\\/[0-9]+)?)\\s+((?:\\*|(?:[1-9]|1[0-2])(?:(?:-(?:[1-9]|1[0-2]))|(?:,(?:[1-9]|1[0-2]))+)?)(?:\\/[0-9]+)?)\\s+((?:\\*|[0-7](?:-[0-7]|(?:,[0-7])+)?)(?:\\/[0-9]+)?)$', '{{request.object.metadata.annotations.\"backup-schedule\" || ''}}') }}"
            operator: Equals
            value: false
```

</p>
</details>

### Regex_replace_all

<details><summary>Expand</summary>
<p>

The `regex_replace_all()` filter is similar to the [`replace_all()`](#replace_all) filter only differing by the first and third inputs being a valid [regular expression](https://en.wikipedia.org/wiki/Regular_expression) rather than a static string. For literal replacement, see [`regex_replace_all_literal()`](#regex_replace_all_literal). If numbers are supplied for the second and third inputs, they will internally be converted to string. The output is always a string. For example, the expression `regex_replace_all('([0-9])([0-9])', 'hello im 42 months old', '${1}1')` results in the output `hello im 41 months old`. The first input provides the regex which should be used to match against the second input, and the third serves as the replacement which, in this case, replaces the first capture group from the end with the number `1`.

| Input 1                    | Input 2            | Input 3            | Output        |
|----------------------------|--------------------|--------------------|---------------|
| Regex (String)             | String             | Regex (String)     | String        |
| Regex (String)             | Number             | Number             | String        |

<br>

**Example:** This policy mutates a Deployment having label named `retention` to set the last number to `0`. For example, an incoming Deployment with the label value of `days_37` would result in the value `days_30` after mutation.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: regex-replace-all-demo
spec:
  background: false
  rules:
  - name: retention-adjust
    match:
      any:
      - resources:
          kinds:
          - Deployment
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            retention: "{{ regex_replace_all('([0-9])([0-9])', '{{ @ }}', '${1}0') }}"
```

</p>
</details>

### Regex_replace_all_literal

<details><summary>Expand</summary>
<p>

The `regex_replace_all_literal()` filter is similar to the [`regex_replace_all()`](#regex_replace_all) filter with the third input being a static string used for literal replacement. If numbers are supplied for the second and third inputs, they will internally be converted to string. The output is always a string. For example, the expression `regex_replace_all_literal('^(\d{3}-?\d{2}-?\d{4})$', '123-45-6789', 'redacted')` would return `redacted` as the regex filter matches the faux social security number of `123-45-6789`.

| Input 1                    | Input 2            | Input 3            | Output        |
|----------------------------|--------------------|--------------------|---------------|
| Regex (String)             | String             | String             | String        |
| Regex (String)             | Number             | Number             | String        |

<br>

**Example:** This policy replaces the image registry for each image in every container so it comes from `myregistry.corp.com`. Note that, for images without an explicit registry such as `nginx:latest`, Kyverno will internally replace this to be `docker.io/nginx:latest` and thereby ensuring the regex pattern below matches.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: regex-replace-all-literal-demo
spec:
  background: false
  rules:
    - name: replace-image-registry
      match:
        any:
        - resources:
            kinds:
              - Pod
      mutate:
        foreach:
        - list: "request.object.spec.containers"
          patchStrategicMerge:
            spec:
              containers:
              - name: "{{ element.name }}"
                image: "{{ regex_replace_all_literal('^[^/]+', '{{element.image}}', 'myregistry.corp.com' )}}"
```

</p>
</details>

### Replace

<details><summary>Expand</summary>
<p>

The `replace()` filter is similar to the [`replace_all()`](#replace_all) filter except it takes a fourth input (a number) to specify how many instances of the source string should be replaced with the replacement string in a parent. For example, the expression shown below results in the value `Lorem muspi dolor sit amet foo muspi bar ipsum` because only two instances of the string `ipsum` were requested to be replaced. String replacement begins at the left and proceeds to the right halting once the desired count has been reached. If `-1` is specified for the four input, it results in all instances of the source string being replaced (effectively the same behavior as `replace_all()`).

```
replace('Lorem ipsum dolor sit amet foo ipsum bar ipsum', 'ipsum', 'muspi', `2`)
```

| Input 1            | Input 2            | Input 3            | Input 4            | Output        |
|--------------------|--------------------|--------------------|--------------------|---------------|
| String             | String             | String             | Number             | String        |

<br>

**Example:** This policy replaces the rule on an Ingress resource so that the path field will replace the first instance of `/cart` with `/shoppingcart`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: replace-demo
spec:
  background: false
  rules:
    - name: replace-path
      match:
        any:
        - resources:
            kinds:
              - Ingress
      mutate:
        foreach:
        - list: "request.object.spec.rules[].http.paths[]"
          patchStrategicMerge:
            spec:
              rules:
              - http:
                  paths:
                  - backend:
                      service: 
                        name: kuard
                        port: 
                          number: 8080
                    path: "{{ replace('{{element.path}}', '/cart', '/shoppingcart', `1`) }}"
                    pathType: ImplementationSpecific
```

</p>
</details>

### Replace_all

<details><summary>Expand</summary>
<p>

The `replace_all()` filter is used to find and replace all instances of one string with another in an overall parent string. Input strings are assumed to be literal and do not support wildcards. For example, the expression `replace_all('Lorem ipsum dolor sit amet', 'ipsum', 'muspi')` results in the value `Lorem muspi dolor sit amet` as the string `ipsum` has been replaced with `muspi`. If there were multiple instances of `ipsum` in the parent string, they would all be replaced with `muspi`.

| Input 1            | Input 2            | Input 3            | Output        |
|--------------------|--------------------|--------------------|---------------|
| String             | String             | String             | String        |

<br>

**Example:** This policy uses `replace_all()` to replace the string `release-name---` with the contents of the annotation `meta.helm.sh/release-name` in the `workingDir` field under a container entry within a Deployment.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: replace-all-demo
spec:
  background: false
  rules:
    - name: replace-workingdir
      match:
        any:
        - resources:
            kinds:
              - Deployment
      mutate:
        patchStrategicMerge:
          spec:
            template:
              spec:
                containers:
                  - (name): "*"
                    workingDir: "{{ replace_all('{{@}}', 'release-name---', '{{request.object.metadata.annotations.\"meta.helm.sh/release-name\"}}') }}"
```

</p>
</details>

### Semver_compare

<details><summary>Expand</summary>
<p>

The `semver_compare()` filter compares two strings which comply with the [semantic versioning](https://semver.org/) schema and outputs a boolean response as to the position of the second relative to the first. The first input is the "base" semver string for comparison while the second is the version is compared against the first. The second string accepts an [operator prefix](/docs/writing-policies/validate/#operators) and supports AND and OR logic. It also supports the special placeholder variable "x" in any position. For some examples, `semver_compare('1.2.3','1.2.4')` results in the output `false` because version 1.2.4 is not equal to version 1.2.3. `semver_compare('4.1.3','>=4.1.x')` results in the output `true` because 4.1.3 is greater than or equal to 4.1.x. `semver_compare('4.1.3','!4.x.x')` returns `false` because 4.1.3 is equal to 4.x.x. `semver_compare('1.8.6','>1.0.0 <2.0.0')` returns `true` because the second input is an AND expression and 1.8.6 is both greater than 1.0.0 and less than 2.0.0. And `semver_compare('2.1.5','<2.0.0 || >=3.0.0')` returns `false` because 2.1.5 is neither less than 2.0.0 nor greater than or equal to 3.0.0.

| Input 1            | Input 2            | Output        |
|--------------------|--------------------|---------------|
| String             | String             | Boolean       |

<br>

**Example:** This policy uses `semver_compare()` to check the attestations on a container image and denies it has been built with httpclient greater than version 4.5.0.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: semver-compare-demo
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: check-sbom
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - image: "ghcr.io/kyverno/test-verify-image*"
        key: |-
          -----BEGIN PUBLIC KEY-----
          MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEHMmDjK65krAyDaGaeyWNzgvIu155
          JI50B2vezCw8+3CVeE0lJTL5dbL3OP98Za0oAEBJcOxky8Riy/XcmfKZbw==
          -----END PUBLIC KEY-----
        attestations:
        - predicateType: https://example.com/CycloneDX/v1
          conditions:
            - all:
              - key: "{{ components[?name == 'commons-logging'].version | [0] }}"
                operator: GreaterThanOrEquals
                value: "1.2.0"
              - key: "{{ semver_compare( {{ components[?name == 'httpclient'].version | [0] }}, '>4.5.0') }}"
                operator: Equals
                value: true
```

</p>
</details>

### Split

<details><summary>Expand</summary>
<p>

The `split()` filter is used to take in an input string, a character or sequence found within that string, and split the source into an array of strings. For example, the string `cat,dog,horse` can be split on the comma (`,`) character resulting in three separate strings in the collection `["cat","dog","horse"]`. This filter is often most useful when looping over a number of different strings within a single value and performing some comparison or expression.

| Input 1            | Input 2            | Output        |
|--------------------|--------------------|---------------|
| String             | String             | Array/string  |

<br>

**Example:** This policy checks an incoming Ingress to ensure its root path does not conflict with another root path in a different Namespace. It requires that incoming Ingress resources have a single rule with a single path only and assumes the root path is specified explicitly in an existing Ingress rule (ex., when blocking /foo/bar /foo must exist by itself and not part of /foo/baz).

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: split-demo
spec:
  validationFailureAction: audit
  background: false
  rules:
    - name: check-path
      match:
        resources:
          kinds:
            - Ingress
      context:
        # Looks up the Ingress paths across the whole cluster.
        - name: allpaths
          apiCall:
            urlPath: "/apis/networking.k8s.io/v1/ingresses"
            jmesPath: "items[].spec.rules[].http.paths[].path"
        # Looks up the Ingress paths in the same Namespace where the incoming request is targeted.
        - name: nspath
          apiCall:
            urlPath: "/apis/networking.k8s.io/v1/namespaces/{{request.object.metadata.namespace}}/ingresses"
            jmesPath: "items[].spec.rules[].http.paths[].path"
      preconditions:
        - key: "{{request.operation}}"
          operator: Equals
          value: "CREATE"
      validate:
        message: >-
          The root path /{{request.object.spec.rules[].http.paths[].path | to_string(@) | split(@, '/') | [1]}}/ exists
          in another Ingress rule elsewhere in the cluster.
        deny:
          conditions:
            all:
              # Deny if the root path of the request exists somewhere else in the cluster other than the same Namespace.
              - key: /{{request.object.spec.rules[].http.paths[].path | to_string(@) | split(@, '/') | [1]}}/
                operator: In
                value: "{{allpaths}}"
              - key: /{{request.object.spec.rules[].http.paths[].path | to_string(@) | split(@, '/') | [1]}}/
                operator: NotIn
                value: "{{nspath}}"
```

</p>
</details>

### Subtract

<details><summary>Expand</summary>
<p>

The `subtract()` filter performs arithmetic subtraction capabilities between two input fields (terms) and produces an output difference. Like other arithmetic custom filters, it is input aware based on the type passed and, for quantities, allows auto conversion between units of measure. For example, subtracting 10Mi (ten mebibytes) minus 5Ki (five kibibytes) results in the value 10235Ki. The `subtract()` filter is currently under development to better account for all permutations of input types, however the below table captures the most common and practical use cases.

Arithmetic filters like `subtract()` currently accept inputs in the following formats.

* Number (ex., \`10\`)
* Quantity (ex., '10Mi')
* Duration (ex., '10h')

Note that how the inputs are enclosed determines how Kyverno interprets their type. Numbers enclosed in back ticks are scalar values while quantities and durations are enclosed in single quotes thus treating them as strings. Using the correct enclosing character is important because, in Kubernetes "regular" numbers are treated implicitly as units of measure. The number written \`10\` is interpreted as an integer or "the number ten" whereas '10' is interpreted as a string or "ten bytes". See the [Formatting](#formatting) section above for more details.

| Input 1            | Input 2            | Output   |
|--------------------|--------------------|----------|
| Number             | Number             | Number   |
| Quantity           | Quantity           | Number   |
| Duration           | Duration           | Duration |

<br>

**Example:** This policy sets the value of a new label called `lessreplicas` to the value of the current number of replicas in a Deployment minus two so long as there are more than two replicas to start with.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: subtract-demo
spec:
  background: false
  rules:
  - name: subtract-demo
    match:
      any:
      - resources:
          kinds:
          - Deployment
    preconditions:
      any:
      - key: "{{ request.object.spec.replicas }}"
        operator: GreaterThan
        value: 2
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            lessreplicas: "{{ subtract('{{ request.object.spec.replicas }}',`2`) }}"
```

</p>
</details>

### Time_since

<details><summary>Expand</summary>
<p>

The `time_since()` filter is used to calculate the difference between a start and end period of time where the end may either be a static definition or the then-current time. The time formats currently supported are [RFC3339](https://datatracker.ietf.org/doc/html/rfc3339) (the same as used by Kubernetes) or a user-definable time format as supported by the `time.Parse()` Go function as documented [here](https://pkg.go.dev/time#Parse). The output time difference is always given in hours, minutes, and seconds where seconds may either be an integer or floating point. For example, the expression `time_since('','2022-04-10T03:14:05-07:00','2022-04-11T03:14:05-07:00')` will result in the output of `"24h0m0s"`. The first input for time format defaults to RFC3339. The expression `time_since('Mon Jan _2 15:04:05 MST 2006', 'Mon Jan 02 15:04:05 MST 2021', 'Mon Jan 10 03:14:16 MST 2021')` uses Unix date format for the inputs (the same as when running the `date` program) and will result in the output `"180h10m11s"`. Helm time format is also parsable, for example `time_since('2006-Jan-02','2020-Jan-14','2020-Jan-17')` resulting in `"72h0m0s"`. And the expression `time_since('','2022-04-10T03:14:05-07:00','')` will result in the difference between the current time and the second input. The output will be given in which seconds is a floating point value, for example `"28h0m33.8257394s"`.

The time format (layout) parameter is optional and will be defaulted to RFC3339 if left empty (i.e., ''). It may not be set explicitly to an RFC3339 format. The time end (third input) may be set to an empty string indicating the current time (i.e., now) when the expression is evaluated.

| Input 1                          | Input 2                         | Input 3                       | Output                     |
|----------------------------------|---------------------------------|-------------------------------|----------------------------|
| Time format (String)             | Time start (String)             | Time end (String)             | Time difference (String)   |

<br>

**Example:** This policy uses `time_since()` to compare the time a container image was created to the present time, blocking if that difference is greater than six months.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: time-since-demo
spec:
  validationFailureAction: audit 
  rules:
    - name: block-stale-images
      match:
        any:
        - resources:
            kinds:
            - Pod
      validate:
        message: "Images built more than 6 months ago are prohibited."
        foreach:
        - list: "request.object.spec.containers"
          context:
          - name: imageData
            imageRegistry:
              reference: "{{ element.image }}"
          deny:
            conditions:
              all:
                - key: "{{ time_since('', '{{ imageData.configData.created }}', '') }}"
                  operator: GreaterThan
                  value: 4380h
```

</p>
</details>

### To_lower

<details><summary>Expand</summary>
<p>

The `to_lower()` filter takes in a string and outputs the same string with all lower-case letters. It is the opposite of [`to_upper()`](#to_upper).

| Input 1            | Output  |
|--------------------|---------|
| String             | String  |

<br>

**Example:** This policy sets the value of a label named `zonekey` to all caps.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: to-lower-demo
spec:
  rules:
  - name: format-deploy-zone
    match:
      any:
      - resources:
          kinds:
          - Service
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            zonekey: "{{ to_lower('{{@}}') }}"
```

</p>
</details>

### To_upper

<details><summary>Expand</summary>
<p>

The `to_upper()` filter takes in a string and outputs the same string with all upper-case letters. It is the opposite of [`to_lower()`](#to_lower).

| Input 1            | Output  |
|--------------------|---------|
| String             | String  |

<br>

**Example:** This policy sets the value of a label named `deployzone` to all caps.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: to-upper-demo
spec:
  rules:
  - name: format-deploy-zone
    match:
      any:
      - resources:
          kinds:
          - Service
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            deployzone: "{{ to_upper('{{@}}') }}"
```

</p>
</details>

### Trim

<details><summary>Expand</summary>
<p>

The `trim()` filter takes a string containing a "source" string, a second string representing a collection of discrete characters, and outputs the remainder of the source when both ends of the source string are trimmed by characters appearing in the collection. For example, inputs of `¡¡¡Hello, Gophers!!!` and `!¡` will result in the output `Hello, Gophers` since the characters `¡` and `!` are found at the beginning and end of the input string and will be trimmed. In the case of `trim('foocorpcom','mo')` the output returned is `foocorpc` since letters `m` and `o` are found at the end of `foocorpcom`. Notice that ordering of the letters in the second input is irrelevant. Interior characters will not be stripped unless exterior characters have also been removed. For example, `trim('foocorpcom','o')` will return the input of `foocorpcom` because `o` does not occur at the beginning or end of the input string. Characters named in the second input will be deduplicated from the source string so long as outside characters have been trimmed first. For example, `trim('foocorpcom','mcof')` will result in the output of `rp` since the other four characters in the second input collection can be stripped from the beginning and end of the input string.

This filter is similar to [`truncate()`](#truncate). The `trim()` filter can be useful to remove exact portions of a string when they are known literally.

| Input 1            | Input 2            | Output  |
|--------------------|--------------------|---------|
| String             | String             | String  |

<br>

**Example:** This policy uses the `trim()` filter to remove the domain from an email value set in an annotation.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: trim-demo
spec:
  rules:
  - name: trim-extnameemail
    match:
      any:
      - resources:
          kinds:
          - Service
    mutate:
      patchStrategicMerge:
        metadata:
          annotations:
            extnameemail: "{{ trim('{{@}}','@corp.com') }}"
```

</p>
</details>

### Truncate

<details><summary>Expand</summary>
<p>

The `truncate()` filter takes a string, a number, and shortens (truncates) that string from the beginning to only include the desired number of characters. For example, calling `truncate()` on the string `foobar` by the number `3` would result in the output of `foo` because only three character positions were requested. This can be a useful filter when formulating values of names, labels, annotations, or other pieces of metadata to conform to a given length and to avoid overruns.

| Input 1            | Input 2            | Output  |
|--------------------|--------------------|---------|
| String             | Number             | String  |

<br>

**Example:** This policy truncates the value of a label called `buildhash` to only take the first twelve characters.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: truncate-demo
spec:
  rules:
  - name: truncate-buildhash
    match:
      any:
      - resources:
          kinds:
          - Namespace
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            buildhash: "{{ truncate('{{@}}',`12`) }}"
```

</p>
</details>

### x509_decode

<details><summary>Expand</summary>
<p>

The `x509_decode()` filter takes in a string which is a PEM-encoded X509 certificate, and outputs a JSON object with the decoded certificate details. It may often be required to first decode a base64-encoded string using [base64_decode()](#base64_decode). This filter can be used to check and validate attributes within a certificate such as subject, issuer, SAN fields, and expiration time. An example of such a decoded object may look like the following:

```json
{
  "AuthorityKeyId": null,
  "BasicConstraintsValid": true,
  "CRLDistributionPoints": null,
  "DNSNames": null,
  "EmailAddresses": null,
  "ExcludedDNSDomains": null,
  "ExcludedEmailAddresses": null,
  "ExcludedIPRanges": null,
  "ExcludedURIDomains": null,
  "ExtKeyUsage": null,
  "Extensions": [
    {
      "Critical": true,
      "Id": [
        2,
        5,
        29,
        15
      ],
      "Value": "AwICpA=="
    },
    {
      "Critical": true,
      "Id": [
        2,
        5,
        29,
        19
      ],
      "Value": "MAMBAf8="
    },
    {
      "Critical": false,
      "Id": [
        2,
        5,
        29,
        14
      ],
      "Value": "BBSWivt1n53+61ZGAczAi0mleejTKg=="
    }
  ],
  "ExtraExtensions": null,
  "IPAddresses": null,
  "IsCA": true,
  "Issuer": {
    "CommonName": "*.kyverno.svc",
    "Country": null,
    "ExtraNames": null,
    "Locality": null,
    "Names": [
      {
        "Type": [
          2,
          5,
          4,
          3
        ],
        "Value": "*.kyverno.svc"
      }
    ],
    "Organization": null,
    "OrganizationalUnit": null,
    "PostalCode": null,
    "Province": null,
    "SerialNumber": "",
    "StreetAddress": null
  },
  "IssuingCertificateURL": null,
  "KeyUsage": 37,
  "MaxPathLen": -1,
  "MaxPathLenZero": false,
  "NotAfter": "2023-10-10T12:46:32Z",
  "NotBefore": "2022-10-10T11:46:32Z",
  "OCSPServer": null,
  "PermittedDNSDomains": null,
  "PermittedDNSDomainsCritical": false,
  "PermittedEmailAddresses": null,
  "PermittedIPRanges": null,
  "PermittedURIDomains": null,
  "PolicyIdentifiers": null,
  "PublicKey": {
    "E": 65537,
    "N": "28595925905962223424520947352207105451744616797088171943239289907331901888529856098458304611629660120574607501039902142361333982065793213267074854658525100799280158707840279479550961169213763526857247298653141711003931642606662052674943191476488665842309583311097351331994267413776792462637192775240062778036062353517979538994974045127175206597906751521558536719043095219698535279694800624795673809356898452438518041024126624051887044932164506019573725987204208750674129677584956156611454245004918943771571492757639432459688931855526941886354880727024912384140238027697348634609952850513122734230521040730560514233467"
  },
  "PublicKeyAlgorithm": 1,
  "Raw": "MIIC7TCCAdWgAwIBAgIBADANBgkqhkiG9w0BAQsFADAYMRYwFAYDVQQDDA0qLmt5dmVybm8uc3ZjMB4XDTIyMTAxMDExNDYzMloXDTIzMTAxMDEyNDYzMlowGDEWMBQGA1UEAwwNKi5reXZlcm5vLnN2YzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOKF+2P0Ufp855hpdsGD4lYkd6oU7HZAOWm1XskAMwrdsqWwTNNAinyHRoPQIbNbGDQ+r6Cggc2mlxHJ90PnC2weHj5otaD17Z+ARZpJZ4HMWkEfFt8sxwo9vuQJRWihqNwFheowjswoSB1DHnPufrZHfztkMoRx278ZfHaIMdlSTg50ektkNDoHA3OJsxxw54X3HR1iq6SZwN8xNT0TI6B6BbfAYWMNmKCiZ2iV6kW//XnTEqGd2WcmhuP0SjwO4tCJbj9oV6+Bj/uhFr7J4foErMaodYDBtQs/ul2tcAwSBHfnC2KcLbiZTZsC0Rs0WPJ4YwF/cOsD7Z/RmLs4FHsCAwEAAaNCMEAwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFJaK+3Wfnf7rVkYBzMCLSaV56NMqMA0GCSqGSIb3DQEBCwUAA4IBAQDY7F6b+t9BX7098JyGk6zeT39MoLdSv+8IaKXn+m8GyOKn3CZkruko57ycvPd4taC0gggtmUYynFhwPMQr+boNrrK9rat8Jw3yPPsBq/8D/s6tvwxSNXBfPUI5OvNIB/hA5XpJpdHQaCkYm+FWkcJsolkkbSOfVjUjImW26JHBnnPPtR4Y7dx0SVoPS19IC0T5RmdvgqlXj4XbhTnX3QOujVHn8u+wQ8po7EngHDQs+onfkp8ipe0QpEJL1ZdW2LhyDXGKrZ2y8UPZ9wYNzxHWaj1Thu4B9YFdsPUwWqSxn9e+FygpoktlD8YgT7jwgiVKX7Koz++zyvMIdhvRrtgS",
  "RawIssuer": "MBgxFjAUBgNVBAMMDSoua3l2ZXJuby5zdmM=",
  "RawSubject": "MBgxFjAUBgNVBAMMDSoua3l2ZXJuby5zdmM=",
  "RawSubjectPublicKeyInfo": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4oX7Y/RR+nznmGl2wYPiViR3qhTsdkA5abVeyQAzCt2ypbBM00CKfIdGg9Ahs1sYND6voKCBzaaXEcn3Q+cLbB4ePmi1oPXtn4BFmklngcxaQR8W3yzHCj2+5AlFaKGo3AWF6jCOzChIHUMec+5+tkd/O2QyhHHbvxl8dogx2VJODnR6S2Q0OgcDc4mzHHDnhfcdHWKrpJnA3zE1PRMjoHoFt8BhYw2YoKJnaJXqRb/9edMSoZ3ZZyaG4/RKPA7i0IluP2hXr4GP+6EWvsnh+gSsxqh1gMG1Cz+6Xa1wDBIEd+cLYpwtuJlNmwLRGzRY8nhjAX9w6wPtn9GYuzgUewIDAQAB",
  "RawTBSCertificate": "MIIB1aADAgECAgEAMA0GCSqGSIb3DQEBCwUAMBgxFjAUBgNVBAMMDSoua3l2ZXJuby5zdmMwHhcNMjIxMDEwMTE0NjMyWhcNMjMxMDEwMTI0NjMyWjAYMRYwFAYDVQQDDA0qLmt5dmVybm8uc3ZjMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4oX7Y/RR+nznmGl2wYPiViR3qhTsdkA5abVeyQAzCt2ypbBM00CKfIdGg9Ahs1sYND6voKCBzaaXEcn3Q+cLbB4ePmi1oPXtn4BFmklngcxaQR8W3yzHCj2+5AlFaKGo3AWF6jCOzChIHUMec+5+tkd/O2QyhHHbvxl8dogx2VJODnR6S2Q0OgcDc4mzHHDnhfcdHWKrpJnA3zE1PRMjoHoFt8BhYw2YoKJnaJXqRb/9edMSoZ3ZZyaG4/RKPA7i0IluP2hXr4GP+6EWvsnh+gSsxqh1gMG1Cz+6Xa1wDBIEd+cLYpwtuJlNmwLRGzRY8nhjAX9w6wPtn9GYuzgUewIDAQABo0IwQDAOBgNVHQ8BAf8EBAMCAqQwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUlor7dZ+d/utWRgHMwItJpXno0yo=",
  "SerialNumber": 0,
  "Signature": "2Oxem/rfQV+9PfCchpOs3k9/TKC3Ur/vCGil5/pvBsjip9wmZK7pKOe8nLz3eLWgtIIILZlGMpxYcDzEK/m6Da6yva2rfCcN8jz7Aav/A/7Orb8MUjVwXz1COTrzSAf4QOV6SaXR0GgpGJvhVpHCbKJZJG0jn1Y1IyJltuiRwZ5zz7UeGO3cdElaD0tfSAtE+UZnb4KpV4+F24U5190Dro1R5/LvsEPKaOxJ4Bw0LPqJ35KfIqXtEKRCS9WXVti4cg1xiq2dsvFD2fcGDc8R1mo9U4buAfWBXbD1MFqksZ/XvhcoKaJLZQ/GIE+48IIlSl+yqM/vs8rzCHYb0a7YEg==",
  "SignatureAlgorithm": 4,
  "Subject": {
    "CommonName": "*.kyverno.svc",
    "Country": null,
    "ExtraNames": null,
    "Locality": null,
    "Names": [
      {
        "Type": [
          2,
          5,
          4,
          3
        ],
        "Value": "*.kyverno.svc"
      }
    ],
    "Organization": null,
    "OrganizationalUnit": null,
    "PostalCode": null,
    "Province": null,
    "SerialNumber": "",
    "StreetAddress": null
  },
  "SubjectKeyId": "lor7dZ+d/utWRgHMwItJpXno0yo=",
  "URIs": null,
  "UnhandledCriticalExtensions": null,
  "UnknownExtKeyUsage": null,
  "Version": 3
}
```

| Input 1            | Output  |
|--------------------|---------|
| String             | Object  |

<br>

**Example:** This policy, designed to operate in background mode only, checks the certificates configured for webhooks and fails if any have an expiration time in the next week.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: test-x509-decode
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: test-x509-decode
    match:
      any:
      - resources:
          kinds:
          - ValidatingWebhookConfiguration
          - MutatingWebhookConfiguration
    validate:
      message: "Certificate will expire in less than a week."
      deny:
        conditions:
          any:
            - key: "{{ base64_decode('{{ request.object.webhooks[0].clientConfig.caBundle }}').x509_decode(@).time_since('',NotBefore,NotAfter) }}"
              operator: LessThan
              value: 168h0m0s
```

</p>
</details>
