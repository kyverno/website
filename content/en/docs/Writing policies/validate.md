---
title: Validate Resources
description: Check resource configurations for policy compliance.
weight: 4
---

Validation rules are probably the most common and practical types of rules you will be working with, and the main use case for admission controllers such as Kyverno. In a typical validation rule, one defines the mandatory properties with which a given resource should be created. When a new resource is created by a user or process, the properties of that resource are checked by Kyverno against the validate rule. If those properties are validated, meaning there is agreement, the resource is allowed to be created. If those properties are different, the creation is blocked. The behavior of how Kyverno responds to a failed validation check is determined by the `validationFailureAction` field. It can either be blocked (`enforce`) or noted in a policy report (`audit`). Validation rules in `audit` mode can also be used to get a report on matching resources which violate the rule(s), both upon initial creation and when Kyverno initiates periodic scans of Kubernetes resources. Resources in violation of an existing rule placed in `audit` mode will also surface in an event on the resource in question.

To validate resource data, define a [pattern](#patterns) in the validation rule. To deny certain API requests define a [deny](#deny-rules) element in the validation rule along with a set of conditions that control when to allow or deny the request.

## Basic Validations

As a basic example, consider the below `ClusterPolicy` which validates that any new Namespace that is created has the label `purpose` with the value of `production`.

```yaml
apiVersion: kyverno.io/v1
# The `ClusterPolicy` kind applies to the entire cluster.
kind: ClusterPolicy
metadata:
  name: require-ns-purpose-label
# The `spec` defines properties of the policy.
spec:
  # The `validationFailureAction` tells Kyverno if the resource being validated should be allowed but reported (`audit`) or blocked (`enforce`).
  validationFailureAction: enforce
  # The `rules` is one or more rules which must be true.
  rules:
  - name: require-ns-purpose-label
    # The `match` statement sets the scope of what will be checked. In this case, it is any `Namespace` resource.
    match:
      resources:
        kinds:
        - Namespace
    # The `validate` statement tries to positively check what is defined. If the statement, when compared with the requested resource, is true, it is allowed. If false, it is blocked.
    validate:
      # The `message` is what gets displayed to a user if this rule fails validation and is therefore blocked.
      message: "You must have label `purpose` with value `production` set on all new namespaces."
      # The `pattern` object defines what pattern will be checked in the resource. In this case, it is looking for `metadata.labels` with `purpose=production`.
      pattern:
        metadata:
          labels:
            purpose: production
```

If a new Namespace with the following definition is submitted to Kyverno, given the `ClusterPolicy` above, it will be **allowed** (validated). This is because it contains the label of `purpose=production`, which is the only pattern being validated in the rule.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: prod-bus-app1
  labels:
    purpose: production
```

By contrast, if a new Namespace with the below definition is submitted, given the `ClusterPolicy` above, it will be **blocked** (invalidated). As you can see, its value of the `purpose` label differs from that required in the policy. But this isn't the only way a validation can fail. If, for example, the same Namespace is requested which has no labels defined whatsoever, it too will be blocked for the same reason.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: prod-bus-app1
  labels:
    purpose: development
```

Save the above manifest as `ns.yaml` and try to create it with your sample `ClusterPolicy` in place.

```sh
$ kubectl create -f ns.yaml
Error from server: error when creating "ns.yaml": admission webhook "validate.kyverno.svc" denied the request: 

resource Namespace//prod-bus-app1 was blocked due to the following policies

require-ns-purpose-label:
  require-ns-purpose-label: 'Validation error: You must have label `purpose` with value `production` set on all new namespaces.; Validation rule require-ns-purpose-label failed at path /metadata/labels/purpose/'
```

Change the `development` value to `production` and try again. Kyverno permits creation of your new Namespace resource.

## Validation Failure Action

The `validationFailureAction` attribute controls admission control behaviors for resources that are not compliant with a policy. If the value is set to `enforce`, resource creation or updates are blocked when the resource does not comply. When the value is set to `audit`, a policy violation is logged in a `PolicyReport` or `ClusterPolicyReport` but the resource creation or update is allowed.

## Patterns

A validation rule which checks resource data is defined as an overlay pattern that provides the desired configuration. Resource configurations must match fields and expressions defined in the pattern to pass the validation rule. The following rules are followed when processing the overlay pattern:

1. Validation will fail if a field is defined in the pattern and if the field does not exist in the configuration.
1. Undefined fields are treated as wildcards.
1. A validation pattern field with the wildcard value '*' will match zero or more alphanumeric characters. Empty values are matched. Missing fields are not matched.
1. A validation pattern field with the wildcard value '?' will match any single alphanumeric character. Empty or missing fields are not matched.
1. A validation pattern field with the wildcard value '?*' will match any alphanumeric characters and requires the field to be present with non-empty values.
1. A validation pattern field with the value `null` or "" (empty string) requires that the field not be defined or has no value.
1. The validation of siblings is performed only when one of the field values matches the value defined in the pattern. You can use the [conditional anchor](#anchors) to explicitly specify a field value that must be matched. This allows writing rules like 'if fieldA equals X, then fieldB must equal Y'.
1. Validation of child values is only performed if the parent matches the pattern.

### Wildcards

1. `*` - matches zero or more alphanumeric characters
1. `?` - matches a single alphanumeric character

For a couple of examples on how wildcards work in rules, see the following.

This policy requires that all containers in all Pods have CPU and memory resource requests and limits defined:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: all-containers-need-requests-and-limits
spec:
  validationFailureAction: enforce
  rules:
  - name: check-container-resources
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "All containers must have CPU and memory resource requests and limits defined."
      pattern:
        spec:
          containers:
          # Select all containers in the pod. The `name` field here is not specifically required but serves
          # as a visual aid for instructional purposes.
          - name: "*"
            resources:
              limits:
                # '?' requires 1 alphanumeric character and '*' means that
                # there can be 0 or more characters. Using them together
                # e.g. '?*' requires at least one character.
                memory: "?*"
                cpu: "?*"
              requests:
                memory: "?*"
                cpu: "?*"
```

The following validation rule checks for a label in Deployment, StatefulSet, and DaemonSet resources:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-label-app
spec:
  validationFailureAction: enforce
  rules:
    - name: check-label-app
      match:
        resources:
          kinds:
          - Deployment
          - StatefulSet
          - DaemonSet
      validate:
        message: "The label `app` is required."
        pattern:
          spec:
            template:
              metadata:
                labels:
                  app: "?*"
```

### Operators

Operators in the following support list values as of Kyverno 1.3.6 in addition to scalar values.

| Operator   | Meaning                   |
|------------|---------------------------|
| `>`        | greater than              |
| `<`        | less than                 |
| `>=`       | greater than or equals to |
| `<=`       | less than or equals to    |
| `!`        | not equals                |
| `\|`       | logical or                |
| `&`        | logical and               |

{{% alert title="Note" color="info" %}}
There is no operator for `equals` as providing a field value in the pattern requires equality to the value.
{{% /alert %}}

### Anchors

Anchors allow conditional processing (i.e. "if-then-else") and other logical checks in validation patterns. The following types of anchors are supported:

| Anchor     | Tag | Behavior                                                                                                                                                                                                                                     |
|-------------|-----|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Conditional | ()  | If tag with the given value (including child elements) is specified, then peer elements will be processed. <br/>e.g. If image has tag latest then imagePullPolicy cannot be IfNotPresent. <br/>&nbsp;&nbsp;&nbsp;&nbsp;(image): "*:latest" <br>&nbsp;&nbsp;&nbsp;&nbsp;imagePullPolicy: "!IfNotPresent"<br/>                                             |
| Equality    | =() | If tag is specified, then processing continues. For tags with scalar values, the value must match. For tags with child elements, the child element is further evaluated as a validation pattern.  <br/>e.g. If hostPath is defined then the path cannot be /var/lib<br/>&nbsp;&nbsp;&nbsp;&nbsp;=(hostPath):<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;path: "!/var/lib"<br/>                                                                                  |
| Existence   | ^() | Works on the list/array type only. If at least one element in the list satisfies the pattern. In contrast, a conditional anchor would validate that all elements in the list match the pattern. <br/>e.g. At least one container with image nginx:latest must exist. <br/>&nbsp;&nbsp;&nbsp;&nbsp;^(containers):<br/>&nbsp;&nbsp;&nbsp;&nbsp;- image: nginx:latest<br/>  |
| Negation    | X() | The tag cannot be specified. The value of the tag is not evaluated (use exclamation point to negate a value). The value should ideally be set to `null`. <br/>e.g. Hostpath tag cannot be defined.<br/>&nbsp;&nbsp;&nbsp;&nbsp;X(hostPath):<br/>|

#### Anchors and child elements: Conditional and Equality

Child elements are handled differently for conditional and equality anchors.

For conditional anchors, the child element is considered to be part of the "if" clause, and all peer elements are considered to be part of the "then" clause. For example, consider the following `ClusterPolicy` pattern statement:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: conditional-anchor-dockersock
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: conditional-anchor-dockersock
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "If a hostPath volume exists and is set to `/var/run/docker.sock`, the label `allow-docker` must equal `true`."
      pattern:
        metadata:
          labels:
            allow-docker: "true"
        (spec):
          (volumes):
          - (hostPath):
              path: "/var/run/docker.sock"
```

This reads as "If a hostPath volume exists and the path equals /var/run/docker.sock, then a label "allow-docker" must be specified with a value of true." In this case, the conditional checks the `spec.volumes` and `spec.volumes.hostPath` map. The child element of `spec.volumes.hostPath` is the `path` key and so the check ends the "If" evaluation at `path`. The entire `metadata` object is a peer element to the `spec` object because these reside at the same hierarchy within a Pod definition. Therefore, conditional anchors can not only compare peers when they are simple key/value, but also when peers are objects or YAML maps.

For equality anchors, a child element is considered to be part of the "then" clause. Now, consider the same `ClusterPolicy` as above but using equality anchors:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: equality-anchor-no-dockersock
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: equality-anchor-no-dockersock
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "If a hostPath volume exists, it must not be set to `/var/run/docker.sock`."
      pattern:
        =(spec):
          =(volumes):
          - =(hostPath):
              path: "!/var/run/docker.sock"
```

This is read as "If a hostPath volume exists, then the path must not be equal to /var/run/docker.sock". In this sample, the object `spec.volumes.hostPath` is being checked, which is where the "If" evaluation ends. Similar to the conditional example above, the `path` key is a child to `hostPath` and therefore is the one being evaluated under the "then" check.

{{% alert title="Note" color="info" %}}
In both of these examples, the validation rule merely checks for the existence of a `hostPath` volume definition. It does not validate whether a container is actually consuming the volume.
{{% /alert %}}


#### Existence anchor: At Least One

The existence anchor is used to check that, in a list of elements, at least one element exists that matches the pattern. This is done by using the `^()` notation for the field. The existence anchor only works on array/list type data.

For example, this pattern will check that at least one container is using an image named `nginx:latest`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: existence-anchor-at-least-one-nginx
spec:
  validationFailureAction: enforce
  rules:
  - name: existence-anchor-at-least-one-nginx
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "At least one container must use the image `nginx:latest`."
      pattern:
        spec:
          ^(containers):
            - image: nginx:latest
```

Contrast this existence anchor, which checks for at least one instance, with a [wildcard](#wildcards) which checks for every instance.

```yaml
      pattern:
        spec:
          containers:
          - name: "*"
            image: nginx:latest
```

This snippet above instead states that *every* entry in the array of containers, regardless of name, must have the `image` set to `nginx:latest`.

### anyPattern

In some cases, content can be defined at different levels. For example, a security context can be defined at the Pod or Container level. The validation rule should pass if either one of the conditions is met.

The `anyPattern` tag is a logical OR across multiple validation patterns and can be used to check if any one of the patterns in the list match.

{{% alert title="Note" color="info" %}}
Either one of `pattern` or `anyPattern` is allowed in a rule; they both can't be declared in the same rule.
{{% /alert %}}

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-root-user
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: check-root-user
    exclude:
      resources:
        namespaces:
        - kube-system
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Root user is not allowed. Set runAsNonRoot to true."
      anyPattern:
      # Checks for `runAsNonRoot` on the Pod.
      - spec:
          securityContext:
            runAsNonRoot: true
      # Checks for `runAsNonRoot` on every container.
      - spec:
          containers:
          # The `name` field here is not specifically required but rather used
          # as a visual aid for instructional purposes.
          - name: "*"
            securityContext:
              runAsNonRoot: true
```

The `anyPattern` method is best suited for validation cases which do not use a negated condition. In the above example, only one of the `spec` contents must be valid. The same is true of negated conditions, however in the below example, this is slightly more difficult to reason about in that when negated, the `anyPattern` option allows any resource to pass so long as it doesn't have at least one of the patterns.

```yaml
validate:
  message: Cannot use Flux v1 annotation.
  anyPattern:
  - metadata:
      =(annotations):
        X(fluxcd.io/*): "*?"
  - metadata:
      =(annotations):
        X(flux.weave.works/*): "*?"
```

If the desire is to state, "neither annotation named `fluxcd.io/` nor `flux.weave.works/` may be present", then this would need two separate rules to express as including either one would mean the other is valid and therefore the resource is allowed.

## Deny rules

In addition to applying patterns to check resources, a validation rule can deny a request based on a set of conditions. A `deny` condition is useful for applying fine-grained access controls that cannot otherwise be performed using native Kubernetes RBAC, or when wanting to explicitly deny requests based upon operations performed against existing objects.

You can use `match` and `exclude` to select when the rule should be applied and then use additional conditions in the `deny` declaration to apply fine-grained controls.

{{% alert title="Note" color="info" %}}
When using a `deny` statement, `validationFailureAction` must be set to `enforce` to block the request.
{{% /alert %}}

Also see using [Preconditions](/docs/writing-policies/preconditions) for matching rules based on variables. `deny` statements can similarly use `any` and `all` blocks like those available to `preconditions`.

In addition to admission review request data, user information, and built-in variables, `deny` rules and preconditions can also operate on ConfigMap data, and in the future data from API server lookups, etc.

### Deny DELETE requests based on labels

This policy denies `delete` requests for objects with the label `app.kubernetes.io/managed-by: kyverno` and for all users who do not have the `cluster-admin` role.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-deletes
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: block-deletes-for-kyverno-resources
    match:
      resources:
        selector:
          matchLabels:
            app.kubernetes.io/managed-by: kyverno
    exclude:
      clusterRoles:
      - cluster-admin
    validate:
      message: "Deleting {{request.oldObject.kind}}/{{request.oldObject.metadata.name}} is not allowed"
      deny:
        conditions:
        - key: "{{request.operation}}"
          operator: In
          value:
          - DELETE
```

### Block changes to a custom resource

This policy denies admission review requests for updates or deletes to a custom resource, unless the request is from a specific service account or matches specified roles.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-updates-to-custom-resource
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: block-updates-to-custom-resource
    match:
      resources:
        kinds:
        - SomeCustomResource
    exclude:
      subjects:
      - kind: ServiceAccount
        name: custom-controller
      clusterRoles:
      - custom-controller:*
      - cluster-admin
    validate:
      message: "Modifying or deleting this custom resource is forbidden."
      deny: {}
```

### Prevent changing NetworkPolicy resources

This policy prevents users from changing NetworkPolicy resources with names that end with `-default`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-netpol-changes
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: deny-netpol-changes
    match:
      resources:
        kinds:
        - NetworkPolicy
        name: "*-default"
    exclude:
      clusterRoles:
      - cluster-admin
    validate:
      message: "Changing default network policies is not allowed."
      deny: {}
```

## foreach

The `foreach` declaration simplifies validation of sub-elements in resource declarations, for example Containers in a Pod. 

A `foreach` declaration can contain multiple entries to process different sub-elements e.g. one to process a list of containers and another to process the list of initContainers in a Pod.

Each `foreach` entry must contain a `list` attribute that defines the sub-elements it processes. For example, iterating over the list of containers in a Pod is performed using this `list` declaration:

```yaml
list: request.object.spec.containers
```

When a `foreach` is processed, the Kyverno engine will evaluate `list` as a JMESPath expression to retrieve zero or more sub-elements for further processing.

A variable `element` is added to the processing context on each interation. This allows referencing data in the element using `element.<name>` where name is the attribute name. For example, using the list `request.object.spec.containers` when the `request.object` is a Pod allows referencing the container image as `element.name` withing a `foreach`.

The following child declarations are permitted in a `foreach`:
- [Patterns](/docs/writing-policies/validate/#patterns)
- [AnyPatterns](/docs/writing-policies/validate/#anypattern)
- [Deny](/docs/writing-policies/validate/#deny-rules)


In addition, each `foreach` declaration can contain the following declarations:
- [Context](/docs/writing-policies/external-data-sources/): to add additional external data only available per loop iteration. 
- [Preconditions](/docs/writing-policies/preconditions/): to control when a loop iteration is skipped

Here is a complete example to enforce that all container images are from a trusted registry:

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-images
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: check-registry
    match:
      resources:
        kinds:
        - Pod
    preconditions:
      - key: "{{request.type}}"
        operator: NotEquals
        value: "DELETE"
    validate:
      message: "unknown registry"  
      foreach:
      - list: "request.object.spec.initContainers"
        pattern:
          image: "trusted-registry.io/*"      
      - list: "request.object.spec.containers"
        pattern:
          image: "trusted-registry.io/*"
```

Note that the `pattern` is applied to the `element` and hence does not need to specify `spec.containers` and can directly reference the attributes of the `element`, which is a `container` in the example above.

