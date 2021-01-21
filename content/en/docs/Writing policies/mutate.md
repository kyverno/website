---
title: Mutating Resources
description: >
  Modify resources during admission control.
weight: 4
---

A `mutate` rule can be used to modify matching resources and is written as either a RFC 6902 JSON Patch, a strategic merge patch, or as an overlay pattern.

{{% alert title="Note" color="warning" %}}
Overlay and patches methods are currently deprecated and scheduled for removal in Kyverno 1.5. Please use the [patch strategic merge](#strategic-merge-patch) or [RFC 6902 JSON Patch](#rfc-6902-jsonpatch) methods from now forward.
{{% /alert %}}

By using a `patch` in the [JSONPatch - RFC 6902](http://jsonpatch.com/) format, you can make precise changes to the resource being created. A `strategic merge patch` is useful for controlling merge behaviors on elements with lists. Using an `overlay` is convenient for describing the desired state of the resource. Regardless of the method, a `mutate` rule is used when an object needs to be modified in a given way.

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
        resources:
          kinds:
          - Pod
      mutate:
        overlay:
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
        resources:
          name: "config-game"
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
        resources:
          name: "config-game"
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
        resources:
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
      resources:
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

Note, that if the `remove` operation cannot be applied, it will be skipped with no error.

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

When needing to apply a mutation containing a special character like a forward slash (`/`) such as when adding an annotation, use `~1` as the escape character. The following adds an annotation with the key of `config.linkerd.io/skip-outbound-ports` with the value of `"8200"`.

```yaml
- op: add
  path: /spec/template/metadata/annotations/config.linkerd.io~1skip-outbound-ports
  value: "8200"
```

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
      resources:
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

## Mutate Overlay

A mutation overlay describes the desired form of resource. The existing resource values are replaced with the values specified in the overlay. If a value is specified in the overlay but not present in the target resource, then it will be added to the resource.

The overlay cannot be used to delete values in a resource: use **patches** for this purpose.

The following mutation overlay will add (or replace) the memory request and limit to 10Gi for every Pod with a label `memory=high`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: policy-change-memory-limit
spec:
  rules:
  - name: "Set memory to 10Gi"
    match:
      resources:
        kinds:
        - Pod
        selector:
          matchLabels:
            memory: high
    mutate:
      overlay:
        spec:
          containers:
          # The wildcard * will match all containers. This `name` field is not specifically required
          # but is included for instructional purposes.
          - (name): "*"
            resources:
              requests:
                memory: "10Gi"
              limits:
                memory: "10Gi"
```

### Working with lists

Applying overlays to a list type is fairly straightforward: new items will be added to the list unless they already exist. For example, the next overlay will add the IP "192.168.10.172" to all addresses in all Endpoints:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: policy-endpoints
spec:
  rules:
  - name: "Add IP to subsets"
    match:
      resources:
        kinds:
        - Endpoints
    mutate:
      overlay:
        subsets:
        - addresses:
          - ip: 192.168.42.172
```

### Conditional logic using anchors

Like with `validate` rules, conditional anchors are supported on `mutate` rules. Refer to the [anchors section](/docs/writing-policies/validate/#anchors) for more general information on conditionals.

An **anchor** field, marked by parentheses and an optional preceding character, allows conditional processing for mutations.

The mutate overlay rules support two types of anchors:

| Anchor             | Tag  | Behavior                                             |
|--------------------|----- |----------------------------------------------------- |
| Conditional        | ()   | Use the tag and value as an "if" condition           |
| Add if not present | +()  | Add the tag value if the tag is not already present  |

The **anchors** values support **wildcards**:

1. `*` - matches zero or more alphanumeric characters
2. `?` - matches a single alphanumeric character

Note that conditional anchors are only supported with the `overlay` and `patchStrategicMerge` mutation methods.

#### Conditional anchor

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
      resources:
        kinds :
          - Endpoints
    mutate:
      overlay:
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
      resources:
        kinds:
        - Pod
    mutate:
      overlay:
        metadata:
          annotations:
            +(cluster-autoscaler.kubernetes.io/safe-to-evict): true
        spec:
          volumes:
          - (emptyDir): {}
```

#### Anchor processing flow

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
        resources:
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
        resources:
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
      resources:
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
      resources:
        kinds:
        - Pod
        selector:
          matchLabels:
            type: database
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            +(backup-needed): yes
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
