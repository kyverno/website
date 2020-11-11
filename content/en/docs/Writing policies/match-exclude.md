---
title: Selecting Resources
description: Use `Match` and `Exclude` to filter and select resources
weight: 2
---

The `match` and `exclude` filters control which resources policies are applied to.

The `match` / `exclude` clauses have the same structure, and can each contain the following elements:

* resources: select resources by name, namespaces, kinds, label selectors and annotations.
* subjects: select users, user groups, and service accounts
* roles: select namespaced roles
* clusterroles: select cluster wide roles

At least one element must be specified in a `match` or `exclude` block. The `kind` attribute is optional when working with the `resources` element, but if it's not specified the policy rule will only be applicable to metatdata that is common across all resources kinds.

When Kyverno receives an admission controller request, i.e. a validation or mutation webhook, it first checks to see if the resource and user information matches or should be excluded from processing. If both checks pass, then the rule logic to mutate, validate, or generate resources is applied.

## Match example

The following YAML provides an example for a match clause.

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: policy
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

        ...

````

## Exclude `cluster-admin` role

Here is an example of a rule that matches all pods, excluding pods created by using the `cluster-admin` cluster role.

````yaml
spec:
  rules:
    name: "match-pods-except-admin"
    match:
      resources:
        kinds:
        - Pod
    exclude:
      clusterroles: cluster-admin
````

## Exclude `kube-system` namespace

This rule matches all pods, excluding pods in the `kube-system` namespace.

````yaml
spec:
  rules:
    name: "match-pods-except-admin"
    match:
      resources:
        kinds:
        - Pod
    exclude:
      resources:
        namespaces:
        - "kube-system"
````

## Combining match and exclude

All `match` and `exclude` conditions must be satisfied for a resource to be selected for the policy rule. In other words, the match and exclude conditions are evaluated using a **logical AND** operation.

Condition checks inside the `resources` block follow the logic "**AND across types but an OR within list types**". For example, if a rule match contains a list of kinds and a list of namespaces, the rule will be evaluated if the request contains any one (OR) of the kinds AND any one (OR) of the namespaces. Conditions inside `clusterRoles`, `roles`, and `subjects` are always evaluated using a logical OR operation, as each request can only have a single instance of these values.

## Match a Deployment or StatefulSet with a label

This is an example that selects a Deployment **OR** a StatefulSet with a label `app=critical`.

````yaml
spec:
  rules:
    - name: match-critical-app
      match:
        # AND across resources and selector
        resources:
          # OR inside list of kinds
          kinds:
          - Deployment,StatefulSet
          selector:
            matchLabels:
              app: critical
````

## Match a label and exclude users and roles

The following example matches all resources with label `app=critical` excluding the resource created by ClusterRole `cluster-admin` **OR** by the user `John`.

````yaml
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
````

## Match all pods and exclude using annotations

Here is an example of a rule that matches all pods having 'imageregistry: "https://hub.docker.com/"' annotations.

````yaml
spec:
  rules:
    - name: match-pod-annotations
      match:
        resources:
          annotations:
            imageregistry: "https://hub.docker.com/"
          kinds:
            - Pod
          name: "*"
````
