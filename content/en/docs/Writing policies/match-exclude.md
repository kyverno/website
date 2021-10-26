---
title: Select Resources
description: Use `match` and `exclude` to filter and select resources.
weight: 2
---

The `match` and `exclude` filters control which resources policies are applied to.

The `match` and `exclude` clauses have the same structure and can each contain **only one** of the two elements:

* `any`: specify [resource filters](#resource-filters) on which Kyverno will perform the logical **OR** operation while choosing resources
* `all`: specify [resource filters](#resource-filters) on which Kyverno will perform the logical **AND** operation while choosing resources

## Resource Filters

The following resource filters can be specified under an `any` or `all` clause.

* `resources`: select resources by names, namespaces, kinds, label selectors, annotations, and namespace selectors.
* `subjects`: select users, user groups, and service accounts
* `roles`: select namespaced roles
* `clusterRoles`: select cluster wide roles

{{% alert title="Note" color="info" %}}
Specifying resource filters directly under `match` and `exclude` has been marked for deprecation and will be removed in a future release. It is highly recommended you specify them under `any` or `all` blocks.
{{% /alert %}}

At least one element must be specified in a `match.(any/all).resources.kinds` or `exclude` block. The `kind` attribute is mandatory when working with the `resources` element. Wildcards (`*`) are currently not supported in the `match.(any/all).resources.kinds` field.

In addition, a user may specify the `group` and `apiVersion` with a kind in the `match` / `exclude` declarations for a policy rule.

Supported formats:

* `Group/Version/Kind`
* `Version/Kind`
* `Kind`

To resolve kind naming conflicts, specify the API group and version. For example, the Kubernetes API, Calico, and Antrea all register a Kind with the name NetworkPolicy.

These can be distinguished as:

* `networking.k8s.io/v1/NetworkPolicy`
* `crd.antrea.io/v1alpha1/NetworkPolicy`

When Kyverno receives an admission controller request (i.e., a validation or mutation webhook), it first checks to see if the resource and user information matches or should be excluded from processing. If both checks pass, then the rule logic to mutate, validate, or generate resources is applied.

## Match statements

In any `rule` statement, there must be a single `match` statement to function as the filter to which the rule will apply. Although the `match` statement can be complex having many different elements, there must be at least one. The most common type of element in a `match` statement is one which filters on categories of Kubernetes resources, for example Pods, Deployments, Services, Namespaces, etc. Variable substitution is not currently supported in `match` or `exclude` statements.

In this snippet, the `match` statement matches on all resources that **EITHER** have the kind Service with name "staging" **OR** have the kind Service and are being created in the "prod" Namespace.

```yaml
spec:
  rules:
  - name: no-LoadBalancer
    match:
      any:
      - resources:
          kinds: 
          - Service
          names: 
          - "staging"
      - resources:
          kinds: 
          - Service
          namespaces:
          - "prod"
```

By combining multiple elements in the `match` statement, you can be more selective as to which resources you wish to process. Additionally, wildcards are supported for even greater control. For example, by adding the `resources.names` field, the previous `match` statement can further filter out Services that begin with the text "prod-" **OR** have the name "staging". `resources.names` takes in a list of names and would match all resources which have either of those names.

```yaml
spec:
  rules:
  - name: no-LoadBalancer
    match:
      any:
      - resources:
          names: 
          - "prod-*"
          - "staging"
          kinds:
          - Service
      - resources:
          kinds:
          - Service
          subjects:
          - kind: User
            name: dave
```

`match.any[0]` will now match on only Services that begin with the name "prod-" **OR** have the name "staging" and not those which begin with "dev-" or any other prefix. `match.any[1]` will match all Services being created by the `dave` user regardless of the name of the Service. And since these two are specified under the `any` key, the entire rule will act on all Services with names `prod-*` or `staging` **OR** on all services being created by the `dave` user. In both `match` and `exclude` statements, [wildcards](/docs/writing-policies/validate/#wildcards) are supported to make selection more flexible.

{{% alert title="Note" color="info" %}}
Kyverno also supports `resources.name` which allows you to pass in only a single name rather than a list, but `resources.name` is being deprecated in favor of `resources.names` and will be removed in a future release.
{{% /alert %}}

In this snippet, the `match` statement matches only resources that have the group `networking.k8s.io`, version `v1` and kind `NetworkPolicy`. By adding Group,Version,Kind in the match statement, you can be more selective as to which resources you wish to process.

```yaml
spec:
  rules:
  - name: no-LoadBalancer
    match:
      resources:
        kinds:
        - networking.k8s.io/v1/NetworkPolicy
```

By specifying the `kind` in `version/kind` format, only specific versions of the resource kind will be matched.

```yaml
spec:
  rules:
  - name: no-LoadBalancer
    match:
      resources:
        kinds:
        - v1/NetworkPolicy
```

As of Kyverno 1.5.0, wildcards are supported in the `kinds` field allowing you to match on every resource type in the cluster.

In the below policy, all resource kinds are checked for the existence of a label having key `app.kubernetes.io/name`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: audit
  background: false
  rules:
  - name: check-for-labels
    match:
      resources:
        kinds:
        - "*"
    preconditions:
    - key: "{{ request.operation }}"
      operator: Equals
      value: CREATE
    validate:
      message: "The label `app.kubernetes.io/name` is required."
      pattern:
        metadata:
          labels:
            app.kubernetes.io/name: "?*"
```

{{% alert title="Note" color="info" %}}
Keep in mind that when matching on all kinds (`*`) the policy you write must be applicable across all of them. Typical uses for this type of wildcard matching are elements within the `metadata` object.
{{% /alert %}}

Here are some other examples of `match` statements.

### Match a Deployment or StatefulSet with a specific label

This is an example that selects a Deployment **OR** a StatefulSet with a label `app=critical`.

Condition checks inside the `resources` block follow the logic "**AND across types but an OR within list types**". For example, if a rule match contains a list of kinds and a list of namespaces, the rule will be evaluated if the request contains any one (OR) of the kinds AND any one (OR) of the namespaces. Conditions inside `clusterRoles`, `roles`, and `subjects` are always evaluated using a logical OR operation, as each request can only have a single instance of these values.

In the below snippet, `kinds` and `selector` are peer/sibling elements, and so they are **AND**ed together.

```yaml
spec:
  rules:
    - name: match-critical-app
      match:
        # AND across kinds and namespaceSelector
        resources:
          # OR inside list of kinds
          kinds:
          - Deployment
          - StatefulSet
          selector:
            matchLabels:
              app: critical
```

This pattern can be leveraged to produce very fine-grained control over the selection of resources, for example the snippet as shown below which combines `match` elements that include `resources`, `subjects`, `roles`, and `clusterRoles`.

### Advanced match statement

```yaml
spec:
  # validationFailureAction controls admission control behaviors,
  # when a policy rule fails:
  # - use 'enforce' to block resource creation or modification
  # - use 'audit' to allow resource updates and report policy violations
  validationFailureAction: enforce
  # Each policy has a list of rules applied in declaration order
  rules:
    # Rules must have a unique name
    - name: "check-pod-controller-labels"
      # Each rule matches specific resource described by "match" field.
      match:
        resources:
          kinds: # Required, list of kinds
          - Deployment
          - StatefulSet
          # Optional resource names. Supports wildcards (* and ?)
          names: 
          - "mongo*"
          - "postgres*"
          # Optional list of namespaces. Supports wildcards (* and ?)
          namespaces:
          - "dev*"
          - test
          # Optional label selectors. Values support wildcards (* and ?)
          selector:
              matchLabels:
                  app: mongodb
              matchExpressions:
                  - {key: tier, operator: In, values: [database]}
        # Optional users or service accounts to be matched
        subjects:
        - kind: User
          name: mary@somecorp.com
        # Optional roles to be matched
        roles:
        # Optional clusterroles to be matched
        clusterRoles: 
        - cluster-admin
```

{{% alert title="Note" color="info" %}}
Although the above snippet is useful for showing the types of matching that you can use, most policies either use one or just a couple different elements within their `match` statements.
{{% /alert %}}

### Match Deployments in Namespaces using labels

This example selects Deployments in Namespaces that have a label `type=connector` or `type=compute` using a `namespaceSelector`.

Here, `kinds` and `namespaceSelector` are peer elements under `match.resources` and are evaluated using a logical **AND** operation. 

```yaml
spec:
  rules:
    - name: check-min-replicas
      match:
        # AND across resources and selector
        resources:
          # OR inside list of kinds
          kinds:
          - Deployment
          namespaceSelector:
            matchExpressions:
              - key: type 
                operator: In
                values: 
                - connector
                - compute
```

## Combining match and exclude

All `match` and `exclude` conditions must be satisfied for a resource to be selected for the policy rule. In other words, the `match` and `exclude` conditions are evaluated using a logical **AND** operation. Elements in the `exclude` block follow the same specifications as those in the `match` block.

### Exclude `cluster-admin` ClusterRole

Here is an example of a rule that matches all Pods excluding those created by using the `cluster-admin` ClusterRole.

```yaml
spec:
  rules:
    name: match-pods-except-cluster-admin
    match:
      resources:
        kinds:
        - Pod
    exclude:
      clusterRoles:
      - cluster-admin
```

### Exclude `kube-system` namespace

This rule matches all Pods except those in the `kube-system` Namespace.

{{% alert title="Note" color="info" %}}
Exclusion of selected Namespaces by name is supported beginning in Kyverno 1.3.0.
{{% /alert %}}

```yaml
spec:
  rules:
    name: match-pods-except-admin
    match:
      resources:
        kinds:
        - Pod
    exclude:
      resources:
        namespaces:
        - kube-system
```

### Match a label and exclude users and roles

The following example matches all resources with label `app=critical` excluding the resources created by ClusterRole `cluster-admin` **OR** by the user `John`.

{{% alert title="Note" color="info" %}}
Since `roles` and `clusterRoles` are built internally by Kyverno from AdmissionReview contents, rules which contain either of these must define `background: false` since the AdmissionReview payload is not available in background mode.
{{% /alert %}}

```yaml
spec:
  rules:
    - name: match-criticals-except-given-rbac
      match:
        resources:
          kind:
          - Pod
          selector:
            matchLabels:
              app: critical
      exclude:
        clusterRoles:
        - cluster-admin
        subjects:
        - kind: User
          name: John
```

### Match a label and exclude users

A variation on the above sample, this snippet uses `any` and `all` statements to exclude multiple users.

```yaml
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: match-criticals-except-given-users
      match:
        all:
        - resources:
            kinds:
            - Pod
            selector:
              matchLabels:
                app: critical
      exclude:
        any:
        - subjects:
          - kind: User
            name: susan
          - kind: User
            name: dave
```

### Match all Pods using annotations

Here is an example of a rule that matches all Pods having `imageregistry: "https://hub.docker.com/"` annotations.

```yaml
spec:
  rules:
    - name: match-pod-annotations
      match:
        resources:
          annotations:
            imageregistry: "https://hub.docker.com/"
          kinds:
            - Pod
```
