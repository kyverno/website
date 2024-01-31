---
title: Validate Rules
description: >
  Check resources configurations for policy compliance.
weight: 30
---

Validation rules are probably the most common and practical types of rules you will be working with, and the main use case for admission controllers such as Kyverno. In a typical validation rule, one defines the mandatory properties with which a given resource should be created. When a new resource is created by a user or process, the properties of that resource are checked by Kyverno against the validate rule. If those properties are validated, meaning there is agreement, the resource is allowed to be created. If those properties are different, the creation is blocked. The behavior of how Kyverno responds to a failed validation check is determined by the `validationFailureAction` field. It can either be blocked (`Enforce`) or allowed yet recorded in a [policy report](/docs/policy-reports/) (`Audit`). Validation rules in `Audit` mode can also be used to get a report on matching resources which violate the rule(s), both upon initial creation and when Kyverno initiates periodic scans of Kubernetes resources. Resources in violation of an existing rule placed in `Audit` mode will also surface in an event on the resource in question.

To validate resource data, define a [pattern](#patterns) in the validation rule. For more advanced processing using tripartite expressions (key-operator-value), define a [deny](#deny-rules) element in the validation rule along with a set of conditions that control when to allow or deny the request.

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
  # The `validationFailureAction` tells Kyverno if the resource being validated should be allowed but reported (`Audit`) or blocked (`Enforce`).
  validationFailureAction: Enforce
  # The `rules` is one or more rules which must be true.
  rules:
  - name: require-ns-purpose-label
    # The `match` statement sets the scope of what will be checked. In this case, it is any `Namespace` resource.
    match:
      any:
      - resources:
          kinds:
          - Namespace
    # The `validate` statement tries to positively check what is defined. If the statement, when compared with the requested resource, is true, it is allowed. If false, it is blocked.
    validate:
      # The `message` is what gets displayed to a user if this rule fails validation.
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

The `validationFailureAction` attribute controls admission control behaviors for resources that are not compliant with a policy. If the value is set to `Enforce`, resource creation or updates are blocked when the resource does not comply. When the value is set to `Audit`, a policy violation is logged in a `PolicyReport` or `ClusterPolicyReport` but the resource creation or update is allowed. For preexisting resources which violate a newly-created policy set to `Enforce` mode, Kyverno will allow subsequent updates to those resources which continue to violate the policy as a way to ensure no existing resources are impacted. However, should a subsequent update to the violating resource(s) make them compliant, any further updates which would produce a violation are blocked.

## Validation Failure Action Overrides

Using `validationFailureActionOverrides`, you can specify which actions to apply per Namespace. This attribute is only available for ClusterPolicies.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-label-app
spec:
  validationFailureAction: Audit
  validationFailureActionOverrides:
    - action: Enforce     # Action to apply
      namespaces:       # List of affected namespaces
        - default
    - action: Audit
      namespaces:
        - test
  rules:
    - name: check-label-app
      match:
        any:
        - resources:
            kinds:
            - Pod
      validate:
        message: "The label `app` is required."
        pattern:
          metadata:
            labels:
              app: "?*"
```

In the above policy, for Namespace `default`, `validationFailureAction` is set to `Enforce` and for Namespace `test`, it's set to `Audit`. For all other Namespaces, the action defaults to the `validationFailureAction` field.

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

This policy requires that all containers in all Pods have resource requests and limits defined (CPU limits intentionally omitted):

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: all-containers-need-requests-and-limits
spec:
  validationFailureAction: Enforce
  rules:
  - name: check-container-resources
    match:
      any:
      - resources:
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
  validationFailureAction: Enforce
  rules:
    - name: check-label-app
      match:
        any:
        - resources:
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

In order to treat special characters like wildcards as literals, see [this section](/docs/writing-policies/jmespath/#matching-special-characters) in the JMESPath page.

### Operators

Operators in the following support list values in addition to scalar values. Many of these operators also support checking of durations (ex., 12h) and semver (ex., 1.4.1).

| Operator   | Meaning                   |
|------------|---------------------------|
| `>`        | greater than              |
| `<`        | less than                 |
| `>=`       | greater than or equals to |
| `<=`       | less than or equals to    |
| `!`        | not equals                |
| `\|`       | logical or                |
| `&`        | logical and               |
| `-`        | within a range            |
| `!-`       | outside a range           |

{{% alert title="Note" color="info" %}}
The `-` operator provides an easier way of validating the value in question falls within a closed interval `[a,b]`. Thus, constructing the `a-b` condition is equivalent of writing the `value >= a & value <= b`. Likewise, the `!-` operator can be used to negate a range. Thus, constructing the `a!-b` condition is equivalent of writing the `value < a | value > b`.
{{% /alert %}}

{{% alert title="Note" color="info" %}}
There is no operator for `equals` as providing a field value in the pattern requires equality to the value.
{{% /alert %}}

An example of using an operator in a pattern style validation rule is shown below.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: validate
spec:
  validationFailureAction: Enforce
  rules:
    - name: validate-replica-count
      match:
        any:
        - resources:
            kinds:
            - Deployment
      validate:
        message: "Replica count for a Deployment must be greater than or equal to 2."
        pattern:
          spec:
            replicas: ">=2"
```

### Anchors

Anchors allow conditional processing (i.e. "if-then-else") and other logical checks in validation patterns. The following types of anchors are supported:

| Anchor     | Tag | Behavior                                                                                                                                                                                                                                     |
|-------------|-----|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Conditional | ()  | If tag with the given value (including child elements) is specified, then peer elements will be processed. <br/>e.g. If image has tag latest then imagePullPolicy cannot be IfNotPresent. <br/>&nbsp;&nbsp;&nbsp;&nbsp;(image): "*:latest" <br>&nbsp;&nbsp;&nbsp;&nbsp;imagePullPolicy: "!IfNotPresent"<br/> |
| Equality    | =() | If tag is specified, then processing continues. For tags with scalar values, the value must match. For tags with child elements, the child element is further evaluated as a validation pattern.  <br/>e.g. If hostPath is defined then the path cannot be /var/lib<br/>&nbsp;&nbsp;&nbsp;&nbsp;=(hostPath):<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;path: "!/var/lib"<br/> |
| Existence   | ^() | Works on the list/array type only. If at least one element in the list satisfies the pattern. In contrast, a conditional anchor would validate that all elements in the list match the pattern. <br/>e.g. At least one container with image nginx:latest must exist. <br/>&nbsp;&nbsp;&nbsp;&nbsp;^(containers):<br/>&nbsp;&nbsp;&nbsp;&nbsp;- image: nginx:latest<br/> |
| Negation    | X() | The tag cannot be specified. The value of the tag is not evaluated (use exclamation point to negate a value). The value should ideally be set to `"null"` (quotes surrounding null). <br/>e.g. Hostpath tag cannot be defined.<br/>&nbsp;&nbsp;&nbsp;&nbsp;X(hostPath): "null"<br/> |
| Global      | <() | The content of this condition, if false, will cause the entire rule to be skipped. Valid for both validate and strategic merge patches. |

#### Anchors and child elements: Conditional and Equality

Child elements are handled differently for conditional and equality anchors.

For conditional anchors, the child element is considered to be part of the "if" clause, and all peer elements are considered to be part of the "then" clause. For example, consider the following `ClusterPolicy` pattern statement:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: conditional-anchor-dockersock
spec:
  validationFailureAction: Enforce
  background: false
  rules:
  - name: conditional-anchor-dockersock
    match:
      any:
      - resources:
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
  validationFailureAction: Enforce
  background: false
  rules:
  - name: equality-anchor-no-dockersock
    match:
      any:
      - resources:
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
  validationFailureAction: Enforce
  rules:
  - name: existence-anchor-at-least-one-nginx
    match:
      any:
      - resources:
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

#### Global Anchor

The global anchor is a way to use a condition anywhere in a resource to base a decision. If the condition enclosed in the global anchor is true, the rest of the rule must apply. If the condition enclosed in the global anchor is false, the rule is skipped.

In this example, a container image coming from a registry called `corp.reg.com` is required to mount an imagePullSecret called `my-registry-secret`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sample
spec:
  validationFailureAction: Enforce
  rules:
  - name: check-container-image
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: Images coming from corp.reg.com must use the correct imagePullSecret.
      pattern:
        spec:
          containers:
          - name: "*"
            <(image): "corp.reg.com/*"
          imagePullSecrets:
          - name: my-registry-secret
```

The below Pod has a single container which meets the global anchor's specifications, but the rest of the pattern does not match. The Pod is therefore blocked.

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
  imagePullSecrets:
  - name: other-secret
```

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
  name: require-run-as-non-root
spec:
  background: true
  validationFailureAction: Enforce
  rules:
  - name: check-containers
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: >-
        Running as root is not allowed. The fields spec.securityContext.runAsNonRoot,
        spec.containers[*].securityContext.runAsNonRoot, and
        spec.initContainers[*].securityContext.runAsNonRoot must be `true`.        
      anyPattern:
      # spec.securityContext.runAsNonRoot must be set to true. If containers and/or initContainers exist which declare a securityContext field, those must have runAsNonRoot also set to true.
      - spec:
          securityContext:
            runAsNonRoot: true
          containers:
          - =(securityContext):
              =(runAsNonRoot): true
          =(initContainers):
          - =(securityContext):
              =(runAsNonRoot): true
      # All containers and initContainers must define (not optional) runAsNonRoot=true.
      - spec:
          containers:
          - securityContext:
              runAsNonRoot: true
          =(initContainers):
          - securityContext:
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

{{% alert title="Note" color="info" %}}
Due to a bug in Kubernetes v1.23 which was fixed in v1.23.3, use of `anyPattern` in the v1.23 release requires v1.23.3 at a minimum.
{{% /alert %}}

## Deny rules

In addition to applying patterns to check resources, a validate rule can deny a request based on a set of conditions written as expressions. A `deny` condition is an expression constructed of key, [operator](/docs/writing-policies/preconditions/#operators), value, and an optional message field. Unlike a pattern, when a `deny` condition evaluates to `true` it blocks a resource. Pattern expressions by contrast, when true, allow a resource.

Deny rules are more powerful and expressive than simple patterns but are also more complex to write. Use deny rules when:

* You need advanced selection logic with multiple "if" conditions.
* You need access to the full contents of the [AdmissionReview](/docs/writing-policies/jmespath/#admissionreview).
* You need access to more built-in [variables](/docs/writing-policies/variables/).
* You need access to the complete [JMESPath filtering system](/docs/writing-policies/jmespath/).

An example of a deny rule is shown below. In deny rules, you write expressions similar to those in Kubernetes resources such as selectors. Deny rules, or "conditions", must be nested under an `any`, `all`, or potentially both in order to control the decision-making logic. In this snippet, a resource will be denied if ANY of the following expressions are true.

1. `{{ request.object.data.team }}` Equals eng
2. `{{ request.object.data.unit }}` Equals green

```yaml
validate:
  message: Main message is here.
  deny:
    conditions:
      any:
      - key: "{{ request.object.data.team }}"
        operator: Equals
        value: eng
        message: The expression team = eng failed.
      - key: "{{ request.object.data.unit }}"
        operator: Equals
        value: green
        message: The expression unit = green failed.
```

Placing these two conditions under an `all` block instead would require that both of them be true to produce the deny behavior.

Kyverno performs [short-circuiting](https://en.wikipedia.org/wiki/Short-circuit_evaluation) on deny conditions to abort processing when a decision can be reached. The first expression to evaluate to a `true` in an `any` block discontinues further evaluation. The first expression to evaluate to `false` in an `all` block does the same.

If the optional `message` field is included, it will be printed for a condition which evaluates to `false` keeping in mind how short-circuiting works.

See also [Preconditions](/docs/writing-policies/preconditions).

### Deny DELETE requests based on labels

This policy denies `delete` requests for objects with the label `app.kubernetes.io/managed-by: kyverno` and for all users who do not have the `cluster-admin` role.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-deletes
spec:
  validationFailureAction: Enforce
  background: false
  rules:
  - name: block-deletes-for-kyverno-resources
    match:
      any:
      - resources:
          selector:
            matchLabels:
              app.kubernetes.io/managed-by: kyverno
    exclude:
      any:
      - clusterRoles:
        - cluster-admin
    validate:
      message: "Deleting {{request.oldObject.kind}}/{{request.oldObject.metadata.name}} is not allowed"
      deny:
        conditions:
          any:
          - key: "{{request.operation}}"
            operator: Equals
            value: DELETE
```

### Block changes to a custom resource

This policy denies admission review requests for updates or deletes to a custom resource, unless the request is from a specific ServiceAccount or matches specified Roles.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-updates-to-custom-resource
spec:
  validationFailureAction: Enforce
  background: false
  rules:
  - name: block-updates-to-custom-resource
    match:
      any:
      - resources:
          kinds:
          - SomeCustomResource
    exclude:
      any:
      - subjects:
        - kind: ServiceAccount
          name: custom-controller
      - clusterRoles:
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
  validationFailureAction: Enforce
  background: false
  rules:
  - name: deny-netpol-changes
    match:
      any:
      - resources:
          kinds:
          - NetworkPolicy
          names:
          - "*-default"
    exclude:
      any:
      - clusterRoles:
        - cluster-admin
    validate:
      message: "Changing default network policies is not allowed."
      deny: {}
```

## foreach

The `foreach` declaration simplifies validation of sub-elements in resource declarations, for example containers in a Pod.

A `foreach` declaration can contain multiple entries to process different sub-elements e.g. one to process a list of containers and another to process the list of initContainers in a Pod.

Each `foreach` entry must contain a `list` attribute, written as a JMESPath expression without braces, that defines the sub-elements it processes. For example, iterating over the list of containers in a Pod is performed using this `list` declaration:

```yaml
list: request.object.spec.containers
```

When a `foreach` is processed, the Kyverno engine will evaluate `list` as a JMESPath expression to retrieve zero or more sub-elements for further processing. The value of the `list` field may also resolve to a simple array of strings, for example as defined in a context variable. The value of the `list` field should not be enclosed in braces even though it is a JMESPath expression.

A variable `element` is added to the processing context on each iteration. This allows referencing data in the element using `element.<name>` where name is the attribute name. For example, using the list `request.object.spec.containers` when the `request.object` is a Pod allows referencing the container image as `element.image` within a `foreach`.

The following child declarations are permitted in a `foreach`:

- [Patterns](/docs/writing-policies/validate/#patterns)
- [AnyPatterns](/docs/writing-policies/validate/#anypattern)
- [Deny](/docs/writing-policies/validate/#deny-rules)

In addition, each `foreach` declaration can contain the following declarations:

- [Context](/docs/writing-policies/external-data-sources/): to add additional external data only available per loop iteration.
- [Preconditions](/docs/writing-policies/preconditions/): to control when a loop iteration is skipped
- `elementScope`: controls whether to use the current list element as the scope for validation. Defaults to "true" if not specified.

Here is a complete example to enforce that all container images are from a trusted registry:

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-images
spec:
  validationFailureAction: Enforce
  background: false
  rules:
  - name: check-registry
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      any:
      - key: "{{request.operation}}"
        operator: NotEquals
        value: DELETE
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

### Nested foreach

The `foreach` object also supports nesting multiple foreach declarations to form loops within loops. When using nested loops, the special variable `{{elementIndex}}` requires a loop number to identify which element to process. Preconditions are supported only at the top-level loop and not per inner loop.

This sample illustrates using nested foreach loops to validate that every hostname does not ends with `new.com`.

```yaml
apiVersion : kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: check-ingress
spec:
  validationFailureAction: Enforce
  background: false
  rules:
  - name: check-tls-secret-host
    match:
      any:
      - resources:
          kinds:
          - Ingress
    validate:
      message: "All TLS hosts must use a domain of old.com."  
      foreach:
      - list: request.object.spec.tls[]
        foreach:
        - list: "element.hosts"
          deny:
            conditions:
              all:
              - key: "{{element}}"
                operator: Equals
                value: "*.new.com"
```

A sample Ingress which may get blocked by this look like the below.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kuard
  labels:
    app: kuard
spec:
  rules:
  - host: kuard.old.com
    http:
      paths:
      - backend:
          service: 
            name: kuard
            port: 
              number: 8080
        path: /
        pathType: ImplementationSpecific
  - host: hr.old.com
    http:
      paths:
      - backend:
          service: 
            name: kuard
            port: 
              number: 8090
        path: /myhr
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - kuard.old.com
    - kuard-foo.new.com
    secretName: foosecret.old.com
  - hosts:
    - hr.old.com
    secretName: hr.old.com
```

Nested foreach statements are also supported in mutate rules. See the documentation [here](/docs/writing-policies/mutate/#nested-foreach) for further details.

## Manifest Validation

Kyverno has the ability to verify signed Kubernetes YAML manifests created with the Sigstore [k8s-manifest-sigstore project](https://github.com/sigstore/k8s-manifest-sigstore). Using this capability, a Kubernetes YAML manifest is signed using one or multiple methods, which includes support for both keyed and keyless signing like in [image verification](/docs/writing-policies/verify-images/), and through a policy definition Kyverno can validate these signatures prior to creation. This capability also includes support for field exclusions, multiple signatures, and dry-run mode.

Generate a key pair used to sign a manifest by using the [`cosign`](https://github.com/sigstore/cosign#installation) command-line tool.

```sh
cosign generate-key-pair
```

Install the [`kubectl-sigstore`](https://github.com/sigstore/k8s-manifest-sigstore#installation) command-line tool using one of the provided methods.

Sign the YAML manifest using the private key generated in the first step.

```sh
$ kubectl-sigstore sign -f secret.yaml -k cosign.key --tarball no -o secret-signed.yaml
Enter password for private key: 
Using payload from: /tmp/kubectl-sigstore-temp-dir1572288324/tmp-blob-file
0D 7ѫO2�Ď��D)�I��!@t�0���X� Xmj���7���+u
                                        ���_ڑ)ۆ�d�0�qHINFO[0004] signed manifest generated at secret-signed.yaml
```

The `secret.yaml` manifest provided as an input has been signed using your private key and the signed version is output at `secret-signed.yaml`.

```yaml
apiVersion: v1
data:
  api_token: MDEyMzQ1Njc4OWFiY2RlZg==
kind: Secret
metadata:
  annotations:
    cosign.sigstore.dev/message: H4sIAAAAAAAA/zTMPQrCQBBA4X5OMVeIWA2kU7sYVFC0kXEzyJr9c3cirKcXlXSv+R4ne5RcbAyErwYGViZA5GSvGkcJhN1qXbv3rtk+zLI/bex5sXeXe9vCaMNAeBCTRcGL8owd38SVbyG6aFh/d5lyTAKIgb0Q+lr+UmsSwj7xcxL4BAAA//+dVuynjwAAAA==
    cosign.sigstore.dev/signature: MEQCIDfRq08y5MSOFo3iiEQUKdRJw9YhQHTjMAXwgO0eWO+hAiBYbR5qpa3wBjfN+d4rdQy5iNFf2pEp24aHZJgwyHEaSA==
  labels:
    location: europe
  name: mysecret
type: Opaque
```

Create the Kyverno policy which matches on Secrets and will be used to validate the signatures.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: validate-secrets
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: validate-secrets
      match:
        any:
        - resources:
            kinds:
              - Secret
      validate:
        manifests:
          attestors:
          - count: 1
            entries:
            - keys:
                publicKeys: |-
                  -----BEGIN PUBLIC KEY-----
                  MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEStoX3dPCFYFD2uPgTjZOf1I5UFTa
                  1tIu7uoGoyTxJqqEq7K2aqU+vy+aK76uQ5mcllc+TymVtcLk10kcKvb3FQ==
                  -----END PUBLIC KEY-----
```

To test the operation of this rule, modify the signed Secret to change some aspect of the manifest. For example, by changing even the value of the `location` label from `europe` to `asia` will cause the signed manifest to be invalid. Kyverno will reject the altered manifest because the signature was only valid for the original Secret manifest.

```sh
$ kubectl apply -f secret-signed.yaml 
Error from server: error when creating "secret-signed.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

policy Secret/default/mysecret for resource violation: 

validate-secrets:
  validate-secrets: 'manifest verification failed; verifiedCount 0; requiredCount
    1; message .attestors[0].entries[0].keys: failed to verify signature. diff found;
    {"items":[{"key":"metadata.labels.location","values":{"after":"asia","before":"europe"}}]}'
```

The difference between the signed manifest and supplied manifest is shown as part of the failure message.

Change the value of the `location` label back to `europe` and attempt to create the manifest once again.

```sh
$ kubectl apply -f secret-signed.yaml 
secret/mysecret created
```

The creation is allowed since the signature was validated according to the original contents.

In many cases, you may wish to secure a portion of a manifest while allowing alterations to other portions. For example, you may wish to sign manifests for Deployments which prevent tampering with any fields other than the replica count. Use the `ignoreFields` portion to define the object type and allowed fields which can differ from the signed original.

The below policy example shows how to match on Deployments and verify signed manifests while allowing changes to the `spec.replicas` field.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: validate-deployment
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: validate-deployment
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        manifests:
          attestors:
          - count: 1
            entries:
            - keys:
                publicKeys: |-
                  -----BEGIN PUBLIC KEY-----
                  MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEStoX3dPCFYFD2uPgTjZOf1I5UFTa
                  1tIu7uoGoyTxJqqEq7K2aqU+vy+aK76uQ5mcllc+TymVtcLk10kcKvb3FQ==
                  -----END PUBLIC KEY-----
          ignoreFields:
          - objects:
            - kind: Deployment
            fields:
            - spec.replicas
```

Kyverno will permit the creation of a signed Deployment as long as the only difference between the signed original and the submitted manifest is the `spec.replicas` field. Modifications to any other field(s) will trigger a failure, for example if the `spec.template.spec.containers[0].image` field is changed from the default of `busybox:1.28` to `evilimage:1.28`.

Rather than using ignoreFields to handle expected controller mutations, the `dryRun` object can be used to eliminate default changes by these and admission controllers. Set `enable` to `true` under the `dryRun` object as shown below and specify a Namespace in which the dry run will occur. Using other Namespaces or dry running with cluster-scoped or custom resources may entail giving additional privileges to the Kyverno ServiceAccount.

```yaml
validate:
  manifests:
    dryRun: 
      enable: true
      namespace: my-dryrun-ns
```

The manifest validation feature shares many of the same abilities as the [verify images](/docs/writing-policies/verify-images/) rule type. For a more thorough explanation of the available fields, use the `kubectl explain clusterpolicy.spec.rules.validate.manifests` command.

## Pod Security

Starting in Kyverno 1.8, a new subrule type called `podSecurity` is available. This subrule type dramatically simplifies the process of writing and applying [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) profiles and controls. By integrating the same libraries as used in Kubernetes' [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/), enabled by default in 1.23 and stable in 1.25, Kyverno is able to apply all or some of the controls and profiles in a single rule while providing capabilities not possible in Pod Security Admission. Standard `match` and `exclude` processing is available just like with other rules. This subrule type is enabled when a `validate` rule is written with a `podSecurity` object, detailed below.

The podSecurity feature has the following advantages over the Kubernetes built-in Pod Security Admission feature:

1. Cluster-wide application of Pod Security Standards does not require an [AdmissionConfiguration](https://kubernetes.io/docs/tasks/configure-pod-container/enforce-standards-admission-controller/#configure-the-admission-controller) file nor any modifications to any control plane components.
2. Namespace application of Pod Security Standards does not require assignment of a label.
3. Specific controls may be exempted from a given profile.
4. Container images may be exempted along with a control exemption.
5. Enforcement of Pod controllers is [automatic](/docs/writing-policies/autogen/).
6. Auditing of Pods in violation may be viewed in-cluster by examining a [Policy Report](/docs/policy-reports/) Custom Resource.
7. Testing of Pods and Pod controller manifests in a CI/CD pipeline is enabled via the [Kyverno CLI](/docs/kyverno-cli/).

For example, this policy enforces the latest version of the Pod Security Standards [baseline profile](https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline) in a single rule across the entire cluster.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa
spec:
  background: true
  validationFailureAction: Enforce
  rules:
  - name: baseline
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      podSecurity:
        level: baseline
        version: latest
```

The `podSecurity.level` field indicates the [profile](https://kubernetes.io/docs/concepts/security/pod-security-standards/#profile-details) to be applied. Applying the `baseline` profile automatically includes all the controls outlined in the [baseline profile](https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline).

The `podSecurity.version` field indicates which version of the Pod Security Standards should be applied. Use of the `latest` version indicates the latest version of the Pod Security Standards should be applied. This field allows prior versions, for example `v1.24`, to support the pinning to specific versions of the Pod Security Standards.

Attempting to apply a Pod which does not meet all of the controls included in the baseline profile will result in a blocking action.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: badpod01
spec:
  hostIPC: true
  containers:
  - name: container01
    image: dummyimagename
```

The failure message returned indicates which level, version, and specific control(s) were responsible for the failure.

```sh
Error from server: error when creating "bad.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

policy Pod/default/badpod01 for resource violation: 

psa:
  baseline: |
    Validation rule 'baseline' failed. It violates PodSecurity "baseline:latest": ({Allowed:false ForbiddenReason:host namespaces ForbiddenDetail:hostIPC=true})
```

Similarly, the restricted profile may be applied by changing the `level` field.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa
spec:
  background: true
  validationFailureAction: Enforce
  rules:
  - name: restricted
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      podSecurity:
        level: restricted
        version: latest
```

Applying the same Pod as above will now return additional information in the message about the cumulative violations.

```
Error from server: error when creating "bad.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

policy Pod/default/badpod01 for resource violation: 

psa:
  baseline: |
    Validation rule 'baseline' failed. It violates PodSecurity "restricted:latest": ({Allowed:false ForbiddenReason:allowPrivilegeEscalation != false ForbiddenDetail:container "container01" must set securityContext.allowPrivilegeEscalation=false})
    ({Allowed:false ForbiddenReason:unrestricted capabilities ForbiddenDetail:container "container01" must set securityContext.capabilities.drop=["ALL"]})
    ({Allowed:false ForbiddenReason:host namespaces ForbiddenDetail:hostIPC=true})
    ({Allowed:false ForbiddenReason:runAsNonRoot != true ForbiddenDetail:pod or container "container01" must set securityContext.runAsNonRoot=true})
    ({Allowed:false ForbiddenReason:seccompProfile ForbiddenDetail:pod or container "container01" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost"})
```

{{% alert title="Note" color="info" %}}
The `restricted` profile is inclusive of the `baseline` profile. Therefore, any Pod in violation of `baseline` is implicitly in violation of `restricted`.
{{% /alert %}}

### Exemptions

When it is necessary to exempt specific controls within a profile while applying all others, the `podSecurity.exclude[]` object may be used. Controls which have restricted fields at the Pod `spec` level need only specify the `controlName` field, the value of which must be a valid name of a Pod Security Standard control. Controls which have restricted fields at the Pod `containers[]` level must additionally specify the `images[]` list. Wildcards are supported in the value of `images[]` allowing for flexible exemption. And controls which have restricted fields at both `spec` and `containers[]` levels must specify two objects in the `exclude[]` field: once with `controlName` and the other with both `controlName` and `images[]`.

For example, the below policy applies the [baseline profile](https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline) across the entire cluster while exempting any Pod that violates the Host Namespaces control.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa
spec:
  background: true
  validationFailureAction: Enforce
  rules:
  - name: baseline
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      podSecurity:
        level: baseline
        version: latest
        exclude:
        - controlName: Host Namespaces
```

The following Pod violates the Host Namespaces control because it sets `spec.hostIPC: true` yet is allowed due to the exclusion.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: badpod01
spec:
  hostIPC: true
  containers:
  - name: container01
    image: dummyimagename
```

When a control exemption is requested where the control defines only container-level fields, the `images[]` list must be present with at least one entry. Wildcards (`*`) are supported both as the sole value and as a component of an image name.

For example, the below policy enforces the restricted profile but exempts containers running either the `nginx` or `redis` image from following the Capabilities control.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa
spec:
  background: true
  validationFailureAction: Enforce
  rules:
  - name: restricted
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      podSecurity:
        level: restricted
        version: latest
        exclude:
        - controlName: Capabilities
          images:
          - nginx*
          - redis*
```

The following Pod, running the `nginx:1.1.9` image, will be allowed although it violates the Capabilities control by virtue of it adding a forbidden capability.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: goodpod01
spec:
  containers:
  - name: container01
    image: nginx:1.1.9
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      seccompProfile:
        type: RuntimeDefault
      capabilities:
        add:
        - SYS_ADMIN
        drop:
        - ALL
```

The same policy would result in blocking a Pod in which a container running the `busybox:1.28` image attempted the same thing.

```
Error from server: error when creating "temp.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

policy Pod/default/badpod01 for resource violation: 

psa:
  restricted: |
    Validation rule 'restricted' failed. It violates PodSecurity "restricted:latest": ({Allowed:false ForbiddenReason:non-default capabilities ForbiddenDetail:container "container01" must not include "SYS_ADMIN" in securityContext.capabilities.add})
    ({Allowed:false ForbiddenReason:unrestricted capabilities ForbiddenDetail:container "container01" must not include "SYS_ADMIN" in securityContext.capabilities.add})
```

{{% alert title="Note" color="info" %}}
Note that in the above error message, the Pod is in violation of the Capabilities control at both the baseline and restricted profiles, hence the multiple entries.
{{% /alert %}}

When a control is to be excluded which contains fields at both the `spec` and `containers[]` level, in order for that control to be fully excluded it must have exclusions for both. The `controlName` field assumes `spec` level while `controlName` plus `images[]` assumes the `containers[]` level.

For example, the Seccomp control in the restricted profile mandates that the `securityContext.seccompProfile.type` field be set to either `RuntimeDefault` or `Localhost`. The `securityContext` object may be defined at one or both the `spec` or `container[]` levels. The `container[]` fields may be undefined/nil if the Pod-level field is set appropriately. Conversely, the Pod-level field may be undefined/nil if _all_ container- level fields are set. In order to completely exclude this control, two entries must exist in the `podSecurity.exclude[]` object. The below policy enforces the restricted profile across the entire cluster while fully exempting the Seccomp control from all images.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa
spec:
  background: true
  validationFailureAction: Enforce
  rules:
  - name: restricted
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      podSecurity:
        level: restricted
        version: latest
        exclude:
        - controlName: Seccomp
        - controlName: Seccomp
          images:
          - '*'
```

An example Pod which satisfies all controls in the restricted profile except the Seccomp control is therefore allowed.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: goodpod01
spec:
  securityContext:
    seccompProfile:
      type: Unconfined
  containers:
  - name: container01
    image: busybox:1.28
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      # seccompProfile:
      #   type: Unconfined
      capabilities:
        drop:
        - ALL
```

Regardless of where the disallowed `type: Unconfined` field is specified, Kyverno allows the Pod.

Multiple control names may be excluded by listing them individually keeping in mind the previously-described rules. Refer to the [Pod Security Standards documentation](https://kubernetes.io/docs/concepts/security/pod-security-standards/) for a listing of all present controls, restricted fields, and allowed values.

### PSA Interoperability

Kyverno's podSecurity validate subrule type and Kubernetes' Pod Security Admission (PSA) are compatible and may be used together in a single cluster with an understanding of where each begins and ends. These are a few of the most common strategies when employing both technologies.

{{% alert title="Note" color="info" %}}
Pods which are blocked by PSA in enforce mode do not result in an AdmissionReview request being sent to admission controllers. Therefore, if a Pod is blocked by PSA, Kyverno cannot apply policies to it.
{{% /alert %}}

1. Use PSA to enforce the baseline profile cluster-wide and use Kyverno podSecurity subrule to enforce or audit the restricted profile with more granularity.

    **Advantage**: Reduces some of the processing on Kyverno by blocking non-compliant Pods at the source while allowing more flexible control on exclusions not possible with PSA.

2. Use PSA to enforce either baseline or restricted on a per-Namespace basis and use Kyverno podSecurity cluster-wide or on different Namespaces.

    **Advantage**: Does not require configuring an AdmissionConfiguration file for PSA.

3. Use PSA to enforce the baseline profile cluster-wide, relax certain Namespaces to the privileged profile, and use Kyverno podSecurity at the baseline or restricted profile.

    **Advantage**: Combines both AdmissionConfiguration with Namespace labeling while layering in Kyverno for granular control over baseline and restricted. A Kyverno mutate rule may also be separately employed here to handle the Namespace labeling as desired.

4. Use both PSA and Kyverno to enforce the same profile at the same scope.

    **Advantage**: Provides a safety net in case either technology is inadvertently/maliciously disabled or becomes unavailable.

## Common Expression Language (CEL)

Starting in Kyverno 1.11, a new subrule type called `cel` is available. This subrule type allows users to write CEL expressions for resource validation. CEL was initially introduced to Kubernetes for the validation rules of CustomResourceDefinitions and is now also utilized by Kubernetes `ValidatingAdmissionPolicies`. Standard `match` and `exclude` processing is available just like with other rules. This subrule type is enabled when a validate rule is written with a `cel` object, detailed below.

For example, this policy ensures that deployment replicas are less than 4.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-deployment-replicas
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: check-deployment-replicas
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        cel:
          expressions:
            - expression: "object.spec.replicas < 4"
              message:  "Deployment spec.replicas must be less than 4."
```

The `cel.expressions` contains CEL expressions which use the [Common Expression Language (CEL)](https://github.com/google/cel-spec) to validate the request. If an expression evaluates to false, the validation check is enforced according to the `spec.validationFailureAction` field.

{{% alert title="Note" color="info" %}}
You can quickly test CEL expressions in [CEL Playground](https://playcel.undistro.io/).
{{% /alert %}}

When trying to create a Deployment with replicas set not satisfying the validation expression, the creation of the Deployment will be blocked.

```
Error from server: error when creating "STDIN": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Deployment/default/nginx was blocked due to the following policies

check-deployment-replicas:
  check-deployment-replicas: Deployment spec.replicas must be less than 4.
```

The following policy ensures that any StatefulSet is created in the `production` namespace. The CEL expression access the namespace that the incoming object belongs to via `namespaceObject`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-statefulset-namespace
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: statefulset-namespace
      match:
        any:
        - resources:
            kinds:
              - StatefulSet
      validate:
        cel:
          expressions:
            - expression: "namespaceObject.metadata.name == 'production'"
              message: "The StatefulSet must be created in the 'production' namespace."
```

When trying to create a StatefulSet in the `default` namespace, the creation of the StatefulSet will be blocked.

```
Error from server: error when creating "STDIN": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource StatefulSet/default/bad-statefulset was blocked due to the following policies 

check-statefulset-namespace:
  statefulset-namespace: The StatefulSet must be created in the 'production' namespace.
```

CEL expressions have access to the contents of the Admission request/response, organized into CEL variables as well as some other useful variables:

- `object` - The object from the incoming request. The value is null for DELETE requests.
- `oldObject` - The existing object. The value is null for CREATE requests.
- `request` - Attributes of the [admission request](https://kubernetes.io/docs/reference/config-api/apiserver-admission.v1/#admission-k8s-io-v1-AdmissionRequest).
- `params` - Parameter resource referred to by `cel.paramKind` and `cel.paramRef`.
- `namespaceObject` - The namespace, as a Kubernetes resource, that the incoming object belongs to. The value is null if the incoming object is cluster-scoped.
- `authorizer` - It can be used to perform authorization checks.
- `authorizer.requestResource` - A shortcut for an authorization check configured with the request resource (group, resource, (subresource), namespace, name).

Read [Supported evaluation on CEL](https://github.com/google/cel-spec/blob/v0.6.0/doc/langdef.md#evaluation) for more information about CEL rules.

`validate.cel` subrules also supports autogen rules for higher-level controllers that directly or indirectly manage Pods: Deployment, DaemonSet, StatefulSet, Job, and CronJob resources. Check the [autogen](/docs/writing-policies/autogen/) section for more information.

```yaml
status:
  autogen:
    rules:
    - exclude:
        resources: {}
      generate:
        clone: {}
        cloneList: {}
      match:
        any:
        - resources:
            kinds:
            - DaemonSet
            - Deployment
            - Job
            - StatefulSet
            - ReplicaSet
            - ReplicationController
        resources: {}
      mutate: {}
      name: autogen-disallow-latest-tag
      validate:
        cel:
          expressions:
          - expression: object.spec.template.spec.containers.all(container, !container.image.contains('latest'))
            message: Using a mutable image tag e.g. 'latest' is not allowed.
    - exclude:
        resources: {}
      generate:
        clone: {}
        cloneList: {}
      match:
        any:
        - resources:
            kinds:
            - CronJob
        resources: {}
      mutate: {}
      name: autogen-cronjob-disallow-latest-tag
      validate:
        cel:
          expressions:
          - expression: object.spec.jobTemplate.spec.template.spec.containers.all(container,
              !container.image.contains('latest'))
            message: Using a mutable image tag e.g. 'latest' is not allowed.
```

### Parameter Resources

Parameter resources enable a policy configuration to be separated from its definition. A policy can define `cel.paramKind`, which outlines the GVK of the parameter resource, and then associate the policy with a specific parameter resource via `cel.paramRef`.

For example, the above policy can be modified to make it configurable:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-deployment-replicas
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: check-deployment-replicas
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        cel:
          paramKind: 
            apiVersion: rules.example.com/v1
            kind: ReplicaLimit
          paramRef:
            name: "replica-limit"
            parameterNotFoundAction: "Deny"
          expressions:
            - expression: "object.spec.replicas < params.maxReplicas"
              messageExpression:  "'Deployment spec.replicas must be less than ' + string(params.maxReplicas)"
```

Here, `cel.paramKind` defines the resources used to configure the policy and the expression uses the `params` variable to access the parameter resource. The `cel.paramRef` is used to bind the policy to a specific resource. 

The parameter resource could be as following:

```yaml
apiVersion: rules.example.com/v1
kind: ReplicaLimit
metadata:
  name: "replica-limit"
maxReplicas: 4
```

This policy parameter resource limits deployments to a max of 4 replicas.

{{% alert title="Note" color="info" %}}
The native types such like ConfigMap could also be used as parameter reference.
{{% /alert %}}

#### Per-namespace Parameters 

There are two types of parameter resources: cluster-wide parameters and per-namespace parameters. If you specify a namespace for the policy `cel.paramRef`, then Kyverno only searches for parameters in that namespace.

However, if namespace is not specified in `cel.paramRef`, then Kyverno can search for relevant parameters in the namespace that a request is against. For example, if you make a request to modify a ConfigMap in the default namespace and there is a relevant policy with no namespace set in `cel.paramRef`, then Kyverno looks for a parameter object in default.

#### Parameter selector

In addition to specify a parameter in `cel.paramRef` by name, you may choose instead to specify label selector, such that all resources of the policy's `paramKind`, and the param's namespace (if applicable) that match the label selector are selected for evaluation.

If multiple parameters are found to meet the condition, the policy's rule is evaluated for each parameter found and the results will be ANDed together.

If `cel.paramRef.namespace` is provided, only objects of the `paramKind` in the provided namespace are eligible for selection. Otherwise, when namespace is empty and `paramKind` is namespace-scoped, the namespace used in the request being admitted will be used.

### CEL Preconditions

CEL Preconditions allow for more fine-grained selection of resources than the options allowed by match and exclude statements. Preconditions consist of one or more CEL expressions which are evaluated after a resource has been successfully matched (and not excluded) by a rule. When preconditions are evaluated to an overall TRUE result, processing of the rule body begins.

For example, if you wished to apply policy to all Kubernetes Services which were of type NodePort, since neither the match/exclude blocks provide access to fields within a resource’s spec, a CEL precondition could be used. In the below rule, while all Services are initially selected by Kyverno, only the ones which have the field `spec.type` set to NodePort will go on to be processed to ensure the field `spec.externalTrafficPolicy` equals a value of `Local`.

```yaml
rules:
  - name: validate-nodeport-trafficpolicy
    match:
      any:
      - resources:
          kinds:
            - Service
    celPreconditions:
        - name: check-service-type
          expression: "object.spec.type.matches('NodePort')"
    validate:
      cel:
        expressions:
        - expression: "object.spec.externalTrafficPolicy.matches('Local')"
          message: "All NodePort Services must use an externalTrafficPolicy of Local."
```

Attempting to apply a `Service` of type `NodePort` with `externalTrafficPolicy` set to `Cluster` will result in a blocking action.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: "NodePort"
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - port: 80
      targetPort: 80
  externalTrafficPolicy: "Cluster"
```

{{% alert title="Note" color="info" %}}
CEL Preconditions can be used only with `validate.cel` subrules.
{{% /alert %}}

### CEL Variables

If an expression grows too complicated, or part of the expression is reusable and computationally expensive to evaluate. We can extract some parts of the expressions into variables. A variable is a named expression that can be referred later as variables in other expressions.

The order of variables is important because a variable can refer to other variables defined before it. This ordering prevents circular references.

The below policy enforces that image repo names match the environment defined in its namespace. It enforces that all containers of deployment have the image repo match the environment label of its namespace except for "exempt" deployments or any containers that do not belong to the "example.com" organization (e.g., common sidecars). For example, if the namespace has a label of {"environment": "staging"}, all container images must be either staging.example.com/* or do not contain "example.com" at all, unless the deployment has {"exempt": "true"} label.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: image-matches-namespace-environment.policy.example.com
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: image-matches-namespace-environment
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        cel:
          variables:
            - name: environment
              expression: "'environment' in namespaceObject.metadata.labels ? namespaceObject.metadata.labels['environment'] : 'prod'"
            - name: exempt
              expression: "has(object.metadata.labels) && 'exempt' in object.metadata.labels && object.metadata.labels['exempt'] == 'true'"
            - name: containers
              expression: "object.spec.template.spec.containers"
            - name: containersToCheck
              expression: "variables.containers.filter(c, c.image.contains('example.com/'))"
          expressions:
            - expression: "variables.exempt || variables.containersToCheck.all(c, c.image.startsWith(variables.environment + '.'))"
              messageExpression: "'only ' + variables.environment + ' images are allowed in namespace ' + namespaceObject.metadata.name"
```

Attempting to apply a deployment whose image is `example.com/nginx` in the `staging-ns` namespace will result in a blocking action.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-fail
  namespace: staging-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: container2
        image: example.com/nginx
```

However, setting the deployment image as `staging.example.com/nginx` will allow it to be created.

## Validating Admission Policies

A ValidatingAdmissionPolicy provides a declarative, in-process option for validating admission webhooks using the [Common Expression Language](https://github.com/google/cel-spec) (CEL) to perform resource validation checks directly in the API server.

Kubernetes [ValidatingAdmissionPolicy](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) was first introduced in 1.26, and it's not fully enabled by default as of Kubernetes versions up to and including 1.28.

{{% alert title="Tip" color="info" %}}
The Kyverno Command Line Interface (CLI) enables the validation and testing of ValidatingAdmissionPolicies on resources before adding them to a cluster. It can be integrated into CI/CD pipelines to help with the resource authoring process, ensuring that they adhere to the required standards before deployment.

Check the below sections for more information:
1. [Apply ValidatingAdmissionPolicies to resources using `kyverno apply`](/docs/kyverno-cli/#applying-validatingadmissionpolicies).
2. [Test ValidatingAdmissionPolicies aganist resources using `kyverno test`](/docs/kyverno-cli/#testing-validatingadmissionpolicies)
{{% /alert %}}

The ValidatingAdmissionPolicy is designed to perform basic validation checks for an admission request. In contrast, Kyverno is capable of performing complex validation checks, validation across resources with API lookups, mutation, generation, image verification, exception management, reporting, and off-cluster validation.

To unify the policy management, Kyverno policies can be used to generate and manage the lifecycle of Kubernetes ValidatingAdmissionPolicies. This allows the process of resource validation to take place directly in the API server, whenever possible, and extends Kyverno's reporting and testing capabilities for ValidatingAdmissionPolicy resources.

When Kyverno manages ValidatingAdmissionPolicies and their bindings it is necessary to grant the Kyverno admission controller’s ServiceAccount additional permissions. To enable Kyverno to generate these types, see the section on [customizing permissions](/docs/installation/customization/#customizing-permissions). Kyverno will assist you in these situations by validating and informing you if the admission controller does not have the level of permissions required at the time the policy is installed.

To generate ValidatingAdmissionPolicies, make sure to:

1. Enable `ValidatingAdmissionPolicy` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/).

2. For 1.27, enable `admissionregistration.k8s.io/v1alpha1` API, and for 1.28 enable both `admissionregistration.k8s.io/v1alpha1` and `admissionregistration.k8s.io/v1beta1` API.

    Here is the minikube command to enable ValidatingAdmissionPolicy:

   ```
   minikube start --extra-config=apiserver.runtime-config=admissionregistration.k8s.io/v1beta1,apiserver.runtime-config=admissionregistration.k8s.io/v1alpha1  --feature-gates='ValidatingAdmissionPolicy=true'
   ```

3. Configure Kyverno to manage ValidatingAdmissionPolicies using the `--generateValidatingAdmissionPolicy=true` flag in the admission controller.

4. Configure Kyverno to generate reports for ValidatingAdmissionPolicies using the `--validatingAdmissionPolicyReports=true` flag in the reports controller.

5. Grant the admission controller’s ServiceAccount permissions to manage ValidatingAdmissionPolicies.

    Here is an aggregated cluster role you can apply:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      labels:
        app.kubernetes.io/component: admission-controller
        app.kubernetes.io/instance: kyverno
        app.kubernetes.io/part-of: kyverno
      name: kyverno:generate-validatingadmissionpolicy
    rules:
    - apiGroups:
      - admissionregistration.k8s.io
      resources:
      - validatingadmissionpolicies
      - validatingadmissionpolicybindings
      verbs:
      - create
      - update
      - delete
      - list
    ```

ValidatingAdmissionPolicies can only be generated from the `validate.cel` sub-rules in Kyverno policies. Refer to the [CEL subrule](/docs/writing-policies/validate/#common-expression-language-cel) section on the validate page for more information.

Below is an example of a Kyverno policy that can be used to generate a ValidatingAdmissionPolicy and its binding:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-path
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: host-path
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        cel:
          expressions:
            - expression: "!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))"
              message: "HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset."
```

Once the policy is created, it is possible to check whether there is a corresponding ValidatingAdmissionPolicy was generated under the `status` object.

```yaml
status:
  validatingadmissionpolicy:
    generated: true
    message: ""
```

The generated ValidatingAdmissionPolicy:

```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicy
metadata:
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path
  ownerReferences:
  - apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    name: disallow-host-path
spec:
  failurePolicy: Fail
  matchConstraints:
    matchPolicy: Equivalent
    namespaceSelector: {}
    objectSelector: {}
    resourceRules:
    - apiGroups:
      - apps
      apiVersions:
      - v1
      operations:
      - CREATE
      - UPDATE
      resources:
      - deployments
      scope: '*'
  validations:
  - expression: '!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume,
      !has(volume.hostPath))'
    message: HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath
      must be unset.
```

The generated ValidatingAdmissionPolicyBinding:

```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicyBinding
metadata:
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path-binding
  ownerReferences:
  - apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    name: disallow-host-path
spec:
  policyName: disallow-host-path
  validationActions:
  - Deny
```

Both the ValidatingAdmissionPolicy and its binding have the same naming convention as the Kyverno policy they originate from, with the binding having a "-binding" suffix.

If there is a request to create the following deployment given the generated ValidatingAdmissionPolicy above, it will be denied by the API server.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
        volumeMounts:
          - name: udev
            mountPath: /data
      volumes:
      - name: udev
        hostPath:
          path: /etc/udev
```

The response returned from the API server.

```sh
The deployments "nginx" is invalid:  ValidatingAdmissionPolicy 'disallow-host-path' with binding 'disallow-host-path-binding' denied request: HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset.
```

{{% alert title="Warning" color="warning" %}}
Since Kubernetes ValidatingAdmissionPolicies are cluster-scoped resources, ClusterPolicies can only be used to generate them.
{{% /alert %}}

The generated ValidatingAdmissionPolicy with its binding is totally managed by the Kyverno admission controller which means deleting/modifying these generated resources will be reverted. Any updates to Kyverno policy triggers synchronization in the corresponding ValidatingAdmissionPolicy.
