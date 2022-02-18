---
title: Mutate Resources
description: >
  Modify resources during admission control.
weight: 3
---

A `mutate` rule can be used to modify matching resources and is written as either a RFC 6902 JSON Patch or a strategic merge patch.

By using a patch in the [JSONPatch - RFC 6902](http://jsonpatch.com/) format, you can make precise changes to the resource being created. A strategic merge patch is useful for controlling merge behaviors on elements with lists. Regardless of the method, a `mutate` rule is used when an object needs to be modified in a given way.

Resource mutation occurs before validation, so the validation rules should not contradict the changes performed by the mutation section.

This policy sets the `imagePullPolicy` to `IfNotPresent` if the image tag is `latest`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: set-image-pull-policy
spec:
  rules:
    - name: set-image-pull-policy
      match:
        any:
        - resources:
            kinds:
            - Pod
      mutate:
        patchStrategicMerge:
          spec:
            containers:
              # match images which end with :latest
              - (image): "*:latest"
                # set the imagePullPolicy to "IfNotPresent"
                imagePullPolicy: "IfNotPresent"
```

## RFC 6902 JSONPatch

A [JSON Patch](http://jsonpatch.com/), implemented as a mutation method called `patchesJson6902`, provides a precise way to mutate resources and supports the following operations (in the `op` field):

* `add`
* `replace`
* `remove`

With Kyverno, the `add` and `replace` have the same behavior (i.e., both operations will add or replace the target element).

The `patchesJson6902` method can be useful when a specific mutation is needed which cannot be performed by `patchesStrategicMerge`. For example, when needing to mutate a specific object within an array, the index can be specified as part of a `patchesJson6902` mutation rule.

One distinction between this and other mutation methods is that `patchesJson6902` does not support the use of conditional anchors. Use [preconditions](/docs/writing-policies/preconditions/) instead. Also, mutations using `patchesJson6902` to Pods directly is not supported as the rules are not converted to higher-level controllers such as Deployments and StatefulSets through the use of the [auto-gen feature](/docs/writing-policies/autogen/). Therefore, when writing such mutation rules for Pods, it may be necessary to create multiple rules to cover all relevant Pod controllers.

This patch policy adds, or replaces, entries in a ConfigMap with the name `config-game` in any namespace.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: policy-patch-cm
spec:
  rules:
    - name: pCM1
      match:
        any:
        - resources:
            names:
              - config-game
            kinds:
              - ConfigMap
      mutate:
        patchesJson6902: |-
          - path: "/data/ship.properties"
            op: add
            value: |
              type=starship
              owner=utany.corp
          - path: "/data/newKey1"
            op: add
            value: newValue1
```

If your ConfigMap has empty data, the following policy adds an entry to `config-game`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: policy-add-cm
spec:
  rules:
    - name: pCM1
      match:
        any:
        - resources:
            names:
              - config-game
            kinds:
            - ConfigMap
      mutate:
        patchesJson6902: |-
          - path: "/data"
            op: add
            value: {"ship.properties": "{\"type\": \"starship\", \"owner\": \"utany.corp\"}"}
```

This is an example of a patch that removes a label from a Secret:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: policy-remove-label
spec:
  rules:
    - name: "Remove unwanted label"
      match:
        any:
        - resources:
            kinds:
            - Secret
      mutate:
        patchesJson6902: |-
          - path: "/metadata/labels/purpose"
            op: remove
```

This policy rule adds elements to a list. In this case, it adds a new busybox container and a command. Note that because the `path` statement is a precise schema element, this will only work on a direct Pod and not higher-level objects such as Deployments.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: insert-container
spec:
  rules:
  - name: insert-container
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchesJson6902: |-
        - op: add
          path: "/spec/containers/1"
          value: {"name":"busybox","image":"busybox:latest"}
        - op: add
          path: "/spec/containers/1/command"
          value:
          - ls
```

{{% alert title="Note" color="warning" %}}
Mutations using `patchesJson6902` which match on Pods are not translated to higher-level Pod controllers as noted above.
{{% /alert %}}

When needing to append an object to an array of objects, for example in `pod.spec.tolerations`, use a dash (`-`) at the end of the path.

```yaml
mutate:
  patchesJson6902: |-
    - op: add
      path: "/spec/tolerations/-"
      value: {"key":"networkzone","operator":"Equal","value":"dmz","effect":"NoSchedule"}
```

JSON Patch uses [JSON Pointer](http://jsonpatch.com/#json-pointer) to reference keys, and keys with tilde (`~`) and forward slash (`/`) characters need to be escaped with `~0` and `~1`, respectively. For example, the following adds an annotation with the key of `config.linkerd.io/skip-outbound-ports` with the value of `"8200"`.

```yaml
- op: add
  path: /spec/template/metadata/annotations/config.linkerd.io~1skip-outbound-ports
  value: "8200"
```

Some other capabilities of the `patchesJson6902` method include:

* Adding non-existent paths
* Adding non-existent arrays
* Adding an element to the end of an array (use negative index `-1`)

## Strategic Merge Patch

The `kubectl` command uses a [strategic merge patch](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-api-machinery/strategic-merge-patch.md) with special directives to control element merge behaviors. Kyverno supports this style of patch to mutate resources. The `patchStrategicMerge` overlay resolves to a partial resource definition.

This policy adds a new container to the Pod, sets the `imagePullPolicy`, adds a command, and sets a label with the key of `name` and value set to the name of the Pod from AdmissionReview data. Once again, the overlay in this case names a specific schema path which is relevant only to a Pod and not higher-level resources like a Deployment.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: strategic-merge-patch
spec:
  rules:
  - name: set-image-pull-policy-add-command
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            name: "{{request.object.metadata.name}}"
        spec:
          containers:
            - name: "nginx"
              image: "nginx:latest"
              imagePullPolicy: "Never"
              command:
              - ls
```

Note that when using `patchStrategicMerge` to mutate the `pod.spec.containers[]` array, the `name` key must be specified as a conditional anchor (i.e., `(name): "*"`) in order for the merge to occur on other fields.

## Conditional logic using anchors

Like with `validate` rules, conditional anchors are supported on `mutate` rules. Refer to the [anchors section](/docs/writing-policies/validate/#anchors) for more general information on conditionals.

An **anchor** field, marked by parentheses and an optional preceding character, allows conditional processing for mutations.

The mutate overlay rules support two types of anchors:

| Anchor             | Tag  | Behavior                                             |
|--------------------|----- |----------------------------------------------------- |
| Conditional        | ()   | Use the tag and value as an "if" condition           |
| Add if not present | +()  | Add the tag value if the tag is not already present  |
| Global             | <()  | Add the pattern when the global anchor is true       |

The **anchors** values support **wildcards**:

1. `*` - matches zero or more alphanumeric characters
2. `?` - matches a single alphanumeric character

Conditional anchors are only supported with the `patchStrategicMerge` mutation method.

### Conditional anchor

A conditional anchor evaluates to `true` if the anchor tag exists and if the value matches the specified value. Processing stops if a tag does not exist or when the value does not match. Once processing stops, any child elements or any remaining siblings in a list will not be processed.

For example, this overlay will add or replace the value `6443` for the `port` field, for all ports with a name value that starts with "secure":

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: policy-set-port
spec:
  rules:
  - name: "Set port"
    match:
      any:
      - resources:
          kinds :
            - Endpoints
    mutate:
      patchStrategicMerge:
        subsets:
        - ports:
          - (name): "secure*"
            port: 6443
```

If the anchor tag value is an object or array, the entire object or array must match. In other words, the entire object or array becomes part of the "if" clause. Nested conditional anchor tags are not supported.

### Add if not present anchor

A variation of an anchor is to add a field value if it is not already defined. This is done by using the **add** anchor (short for "add if not present" anchor) with the notation `+(...)` for the tag.

An add anchor is processed as part of applying the mutation. Typically, every non-anchor tag-value is applied as part of the mutation. If the add anchor is set on a tag, the tag and value are only applied if they do not exist in the resource.

For example, this policy matches and mutates pods with an `emptyDir` volume to add the `safe-to-evict` annotation if it is not specified.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-safe-to-evict
  annotations:
    pod-policies.kyverno.io/autogen-controllers: none
spec:
  rules:
  - name: "annotate-empty-dir"
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          annotations:
            +(cluster-autoscaler.kubernetes.io/safe-to-evict): true
        spec:
          volumes:
          - <(emptyDir): {}
```

### Global Anchor

Similar to validate rules, mutate rules can use the global anchor. When a global anchor is used, the condition inside the anchor, when true, means the rest of the pattern will be applied regardless of how it may relate to the global anchor.

For example, the below policy will add an imagePullSecret called `my-secret` to any Pod if it has a container image beginning with `corp.reg.com`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-imagepullsecrets
spec:
  rules:
  - name: add-imagepullsecret
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        spec:
          containers:
          - <(image): "corp.reg.com/*"
          imagePullSecrets:
          - name: my-secret
```

The below Pod meets this criteria and so the imagePullSecret called `my-secret` is added.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    role: myrole
spec:
  containers:
    - name: web
      image: corp.reg.com/nginx
      ports:
        - name: web
          containerPort: 80
          protocol: TCP
```

### Anchor processing flow

The anchor processing behavior for mutate conditions is as follows:

1. First, all conditional anchors are processed. Processing stops when the first conditional anchor returns a `false`. Mutation proceeds only of all conditional anchors return a `true`. Note that for conditional anchor tags with complex (object or array) values, the entire value (child) object is treated as part of the condition as explained above.

2. Next, all tag-values without anchors and all add anchor tags are processed to apply the mutation.

## Mutate Rule Ordering (Cascading)

In some cases, it might be desired to have multiple levels of mutation rules apply to incoming resources. The `match` statement in rule A would apply a mutation to the resource, and the result of that mutation would trigger a `match` statement in rule B that would apply a second mutation. In such cases, Kyverno can accommodate more complex mutation rules, however rule ordering matters to guarantee consistent results.

For example, assume you wished to assign a label to each incoming Pod describing the type of application it contained. For those with an `image` having the string either `cassandra` or `mongo` you wished to apply the label `type=database`. This could be done with the following sample policy.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: database-type-labeling
spec:
  rules:
    - name: assign-type-database
      match:
        any:
        - resources:
            kinds:
            - Pod
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              type: database
          spec:
            (containers):
            - (image): "*cassandra* | *mongo*"
```

Also, assume that for certain application types a backup strategy needs to be defined. For those applications where `type=database`, this would be designated with an additional label with the key name of `backup-needed` and value of either `yes` or `no`. The label would only be added if not already specified since operators can choose if they want protection or not. This policy would be defined like the following.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: database-backup-labeling
spec:
  rules:
    - name: assign-backup-database
      match:
        any:
        - resources:
            kinds:
              - Pod
            selector:
              matchLabels:
                type: database
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              +(backup-needed): "yes"
```

In such a case, Kyverno is able to perform cascading mutations whereby an incoming Pod that matched in the first rule and was mutated would potentially be further mutated by the second rule. In these cases, the rules must be ordered from top to bottom in the order of their dependencies and stored within the same policy. The resulting policy definition would look like the following:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: database-protection
spec:
  rules:
  - name: assign-type-database
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            type: database
        spec:
          (containers):
          - (image): "*cassandra* | *mongo*"
  - name: assign-backup-database
    match:
      any:
      - resources:
          kinds:
          - Pod
          selector:
            matchLabels:
              type: database
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            +(backup-needed): "yes"
```

Test the cascading mutation policy by creating a Pod using the Cassandra image.

```sh
$ kubectl run cassandra --image=cassandra:latest
pod/cassandra created
```

Perform a `get` or `describe` on the Pod to see the result of the metadata.

```sh
$ kubectl describe po cassandra
Name:         cassandra
Namespace:    default
<snip>
Labels:       backup-needed=yes
              run=cassandra
              type=database
<snip>
```

As can be seen, both `type=database` and `backup-needed=yes` were applied according to the mutation rules.

Verify that applying your own `backup-needed` label with the value of `no` triggers the first mutation rule but not the second.

```sh
$ kubectl run cassandra --image=cassandra:latest --labels backup-needed=no
```

Perform another `get` or `describe` to verify the `backup-needed` label was not altered by the mutation rule.

```sh
$ kubectl describe po cassandra
Name:         cassandra
Namespace:    default
<snip>
Labels:       backup-needed=no
              type=database
<snip>
```

## foreach

A `foreach` declaration can contain multiple entries to process different sub-elements e.g. one to process a list of containers and another to process the list of initContainers in a Pod.

A `foreach` must contain a `list` attribute that defines the list of elements it processes and either a `patchStrategicMerge` or `patchesJson6902` declaration. For example, iterating over the list of containers in a Pod is performed using this `list` declaration:

```yaml
list: request.object.spec.containers
patchStrategicMerge:
  spec:
    containers:
      ...
```

When a `foreach` is processed, the Kyverno engine will evaluate `list` as a JMESPath expression to retrieve zero or more sub-elements for further processing. The value of the `list` field should not be enclosed in braces even though it is a JMESPath expression.

A variable `element` is added to the processing context on each iteration. This allows referencing data in the element using `element.<name>` where name is the attribute name. For example, using the list `request.object.spec.containers` when the `request.object` is a Pod allows referencing the container image as `element.image` within a `foreach`.

Each `foreach` declaration can optionally contain the following declarations:

* [Context](/docs/writing-policies/external-data-sources/): to add additional external data only available per loop iteration.
* [Preconditions](/docs/writing-policies/preconditions/): to control when a loop iteration is skipped

For a `patchesJson6902` type of `foreach` declaration, an additional variable called `elementIndex` is made available which allows the current index number to be referenced in a loop.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: foreach-json-patch
spec:
  rules:
    - name: add-security-context
      match:
        any:
        - resources:
            kinds:
              - Pod
      preconditions:
        any:
        - key: "{{ request.operation }}"
          operator: Equals
          value: CREATE
      mutate:
        foreach: 
        - list: "request.object.spec.containers"
          patchesJson6902: |-
            - path: /spec/containers/{{elementIndex}}/securityContext
              op: add
              value: {"runAsNonRoot" : true}
```

For a complete example of the `patchStrategicMerge` method that mutates the image to prepend the address of a trusted registry, see below.

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: prepend-registry
spec:
  background: false
  rules:
  - name: prepend-registry-containers
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      all:
      - key: "{{request.operation}}"
        operator: In
        value:
        - CREATE
        - UPDATE
    mutate:
      foreach:
      - list: "request.object.spec.containers"
        patchStrategicMerge:
          spec:
            containers:
            - name: "{{ element.name }}"           
              image: registry.io/{{ images.containers."{{element.name}}".name}}:{{images.containers."{{element.name}}".tag}}
```

Note that the `patchStrategicMerge` is applied to the `request.object`. Hence, the patch needs to begin with `spec`. Since container names may have dashes in them (which must be escaped), the `{{element.name}}` variable is specified in double quotes.
