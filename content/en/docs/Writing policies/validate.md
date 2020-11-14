---
title: Validating Resources
description: Check resource configurations for policy compliance
weight: 3
---


A validation rule can be used to check resource configurations for compliance during admission control or via periodic scans.

To validate resource data, define a [pattern](#patterns) in the validation rule. To deny certain API requests define a [deny](#deny-rules) element in the validation rule along with a set of conditions that control when to allow or deny the request.

This policy requires that all pods have CPU and memory resource requests and limits:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-cpu-memory
spec:
  # `enforce` blocks the request. `audit` reports violations
  validationFailureAction: enforce
  rules:
    - name: check-pod-resources
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: "CPU and memory resource requests and limits are required"
        pattern:
          spec:
            containers:
              # 'name: *' selects all containers in the pod
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

This policy prevents users from changing network policies with names that end with `-default`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-netpol-changes
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: check-netpol-updates
      match:
        resources:
          kinds:
            - NetworkPolicy
          name:
            - *-default
      exclude:
        clusterRoles:
          - cluster-admin
      validate:
        message: "Changing default network policies is not allowed"
        deny: {}
```

## Patterns

A validation rule that checks resource data is defined as an overlay pattern that provides the desired configuration. Resource configurations must match fields and expressions defined in the pattern to pass the validation rule. The following rules are followed when processing the overlay pattern:

1. Validation will fail if a field is defined in the pattern and if the field does not exist in the configuration.
2. Undefined fields are treated as wildcards.
3. A validation pattern field with the wildcard value '*' will match zero or more alphanumeric characters. Empty values are matched. Missing fields are not matched.
4. A validation pattern field with the wildcard value '?' will match any single alphanumeric character. Empty or missing fields are not matched.
5. A validation pattern field with the wildcard value '?*' will match any alphanumeric characters and requires the field to be present with non-empty values.
6. A validation pattern field with the value `null` or "" (empty string) requires that the field not be defined or has no value.
7. The validation of siblings is performed only when one of the field values matches the value defined in the pattern. You can use the parenthesis operator to explicitly specify a field value that must be matched. This allows writing rules like 'if fieldA equals X, then fieldB must equal Y'.
8. Validation of child values is only performed if the parent matches the pattern.

### Wildcards

1. `*` - matches zero or more alphanumeric characters
2. `?` - matches a single alphanumeric character

The following validation rule checks for a label in Deployment, StatefulSet, and DaemonSet resources:

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: validation-example
spec:
  rules:
    - name: check-label
      match:
        resources:
          kinds:
            - Deployment
            - StatefulSet
            - DaemonSet
      validate:
        message: "The label app is required"
        pattern:
          spec:
            template:
              metadata:
                labels:
                  app: "?*"

````

### Operators

| Operator   | Meaning                   |
|------------|---------------------------|
| `>`        | greater than              |
| `<`        | less than                 |
| `>=`       | greater than or equals to |
| `<=`       | less than or equals to    |
| `!`        | not equals                |
|  \|        | logical or                |

There is no operator for `equals` as providing a field value in the pattern requires equality to the value.

### Anchors

Anchors allow conditional processing (i.e. "if-then-else") and other logical checks in validation patterns. The following types of anchors are supported:

| Anchor     | Tag | Behavior                                                                                                                                                                                                                                     |
|-------------|-----|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Conditional | ()  | If tag with the given value (including child elements) is specified, then peer elements will be processed. <br/>e.g. If image has tag latest then imagePullPolicy cannot be IfNotPresent. <br/>&nbsp;&nbsp;&nbsp;&nbsp;(image): "*:latest" <br>&nbsp;&nbsp;&nbsp;&nbsp;imagePullPolicy: "!IfNotPresent"<br/>                                             |
| Equality    | =() | If tag is specified, then processing continues. For tags with scalar values, the value must match. For tags with child elements, the child element is further evaluated as a validation pattern.  <br/>e.g. If hostPath is defined then the path cannot be /var/lib<br/>&nbsp;&nbsp;&nbsp;&nbsp;=(hostPath):<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;path: "!/var/lib"<br/>                                                                                  |
| Existence   | ^() | Works on the list/array type only. If at least one element in the list satisfies the pattern. In contrast, a conditional anchor would validate that all elements in the list match the pattern. <br/>e.g. At least one container with image nginx:latest must exist. <br/>&nbsp;&nbsp;&nbsp;&nbsp;^(containers):<br/>&nbsp;&nbsp;&nbsp;&nbsp;- image: nginx:latest<br/>  |
| Negation    | X() | The tag cannot be specified. The value of the tag is not evaluated. <br/>e.g. Hostpath tag cannot be defined.<br/>&nbsp;&nbsp;&nbsp;&nbsp;X(hostPath):<br/>|

### Anchors and child elements

Child elements are handled differently for conditional and equality anchors.

For conditional anchors, the child element is considered to be part of the "if" clause, and all peer elements are considered to be part of the "then" clause. For example, consider the pattern:

````yaml
  pattern:
    metadata:
      labels:
        allow-docker: "true"
    spec:
      (volumes):
      - (hostPath):
          path: "/var/run/docker.sock"
````

This reads as "If a hostPath volume exists and the path equals /var/run/docker.sock, then a label "allow-docker" must be specified with a value of true."

For equality anchors, a child element is considered to be part of the "then" clause. Consider this pattern:

````yaml
  pattern:
    spec:
      =(volumes):
        =(hostPath):
          path: "!/var/run/docker.sock"
````

This is read as "If a hostPath volume exists, then the path must not be equal to /var/run/docker.sock".

#### Existence anchor: at least one

A variation of an anchor, is to check that in a list of elements at least one element exists that matches the pattern. This is done by using the ^(...) notation for the field.

For example, this pattern will check that at least one container has memory requests and limits defined and that the request is less than the limit:

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: validation-example2
spec:
  rules:
    - name: check-memory_requests_link_in_yaml_relative
      match:
        resources:
          # Kind specifies one or more resource types to match
          kinds:
            - Deployment
          # Name is optional and can use wildcards
          name: "*"
      validate:
        pattern:
          spec:
            template:
                spec:
                    ^(containers):
                    - resources:
                        requests:
                            memory: "$(<=./../../limits/memory)"
                        limits:
                            memory: "2048Mi"
````

#### `anyPattern` - logical OR across multiple validation patterns

In some cases content can be defined at a different level. For example, a security context can be defined at the Pod or Container level. The validation rule should pass if either one of the conditions is met.

The `anyPattern` tag can be used to check if any one of the patterns in the list match.

<small>*Note: either one of `pattern` or `anyPattern` is allowed in a rule; they both can't be declared in the same rule.*</small>

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-container-security-context
spec:
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
        - spec:
            securityContext:
              runAsNonRoot: true
        - spec:
            containers:
            - name: "*"
              securityContext:
                runAsNonRoot: true
````

## Validation Failure Action

The `validationFailureAction` attribute controls admission control behaviors for resources that are not compliant with a policy. If the value is set to `enforce`, resource creation or updates are blocked when the resource does not comply. When the value is set to `audit`, a policy violation is reported but the resource creation or update is allowed.

## Deny rules

In addition to applying patterns to check resources, a validation rule can `deny` a request based on a set of conditions. This is useful for applying fine-grained access controls that cannot be performed using Kubernetes RBAC.

You can use `match` and `exclude` to select when the rule should be applied and then use additional conditions in the `deny` declaration to apply fine-grained controls.

Note that the `validationFailureAction` must be set to `enforce` to block the request.

Also see using [Preconditions](/docs/writing-policies/writing-policies-preconditions) for matching rules based on variables.

### Deny DELETE based on labels

This policy denies `delete` requests for objects with the label `app.kubernetes.io/managed-by: kyverno` and for all users who do not have the `cluster-admin` role:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: multi-tenancy
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

### Block changes for a custom resource

This policy denies admission review requests for updates or deletes on a custom resource, unless the request is from a specific service account or matches specified roles.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: pv-access-controls
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: block-updates
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
        - clusterAdmin
      validate:
        message: "Access denied"
        deny:
```
