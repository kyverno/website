---
title: Selecting Resources
description: Use `Match` and `Exclude` to filter and select resources.
weight: 2
---

The `match` and `exclude` filters control which resources policies are applied to.

The `match` and `exclude` clauses have the same structure and can each contain the following elements:

* `resources`: select resources by name, namespaces, kinds, label selectors, and annotations.
* `subjects`: select users, user groups, and service accounts
* `roles`: select namespaced roles
* `clusterRoles`: select cluster wide roles

At least one element must be specified in a `match` or `exclude` block. The `kind` attribute is optional when working with the `resources` element, but if it's not specified the policy rule will only be applicable to metadata that is common across all resource kinds.

When Kyverno receives an admission controller request (i.e., a validation or mutation webhook), it first checks to see if the resource and user information matches or should be excluded from processing. If both checks pass, then the rule logic to mutate, validate, or generate resources is applied.

## Match statements

In any `rule` statement, there must be a single `match` statement to function as the filter to which the rule will apply. Although the `match` statement can be complex having many different elements, there must be at least one. The most common type of element in a `match` statement is one which filters on categories of Kubernetes resources, for example Pods, Deployments, Services, Namespaces, etc. Variable substitution is not currently supported in `match` or `exclude` statements.

In this snippet, the `match` statement matches on any and all resources that have the kind `Service`. It does not take any other criteria into consideration, only that it be of kind `Service`.

```yaml
spec:
  rules:
  - name: no-LoadBalancer
    match:
      resources:
        kinds:
        - Service
```

By combining multiple elements in the `match` statement, you can be more selective as to which resources you wish to process. For example, by adding the `resources.name` field, the previous `match` statement can further filter out Services that begin with the text "prod-".

```yaml
spec:
  rules:
  - name: no-LoadBalancer
    match:
      resources:
        name: "prod-*"
        kinds:
        - Service
```

This will now match on only Services that begin with the name "prod-" but not those which begin with "dev-" nor any other prefix. In both `match` and `exclude` statements, [wildcards](/docs/writing-policies/validate/#wildcards) are supported to make selection more flexible.

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
        # AND across resources and selector
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
          # Optional resource name. Supports wildcards (* and ?)
          name: "mongo*"
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
        clusterroles: cluster-admin
```

{{% alert title="Note" color="info" %}}
Although the above snippet is useful for showing the types of matching that you can use, most policies either use one or just a couple different elements within their `match` statements.
{{% /alert %}}

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
      clusterroles:
      - cluster-admin
```

### Exclude `kube-system` namespace

This rule matches all Pods except those in the `kube-system` Namespace.

{{% alert title="Note" color="info" %}}
Exclusion of selected Namespaces by name is supported beginning in Kyverno v1.3.0.
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

```yaml
spec:
  rules:
    - name: match-criticals-except-given-rbac
      match:
        resources:
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
