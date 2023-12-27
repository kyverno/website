---
title: "Cleanup Rules"
description: >
  Remove Kubernetes resources.
weight: 70
---

{{% alert title="Warning" color="warning" %}}
Cleanup policies are a **beta** feature. It is not ready for production usage and there may be breaking changes. Normal semantic versioning and compatibility rules will not apply.
{{% /alert %}}

Kyverno has the ability to cleanup (i.e., delete) existing resources in a cluster in two different ways. The first way is via a declarative policy definition in either a `CleanupPolicy` or `ClusterCleanupPolicy`. See the section on [cleanup policies](#cleanup-policy) below for more details. The second way is via a reserved time-to-live (TTL) label added to a resource. See the [cleanup label](#cleanup-label) section for further details.

## Cleanup Policy

Similar to other policies which can validate, mutate, generate, or verify images in resources, Kyverno can cleanup resources by defining a new policy type called a `CleanupPolicy`. Cleanup policies come in both cluster-scoped and Namespaced flavors; a `ClusterCleanupPolicy` being cluster scoped and a `CleanupPolicy` being Namespaced. A cleanup policy uses the familiar `match`/`exclude` block to select and exclude resources which are subjected to the cleanup process. A `conditions{}` block (optional) uses common expressions similar to those found in [preconditions](/docs/writing-policies/preconditions/) and [deny rules](/docs/writing-policies/validate/#deny-rules) to query the contents of the selected resources in order to refine the selection process. [Context variables](/docs/writing-policies/external-data-sources/) (optional) can be used to fetch data from other resources to factor into the cleanup process. And, lastly, a `schedule` field defines, in cron format, when the rule should run.

{{% alert title="Note" color="info" %}}
Since cleanup policies always operate against existing resources in a cluster, policies created with `subjects`, `Roles`, or `ClusterRoles` in the `match`/`exclude` block are not allowed since this information is only known at admission time.
{{% /alert %}}

An example ClusterCleanupPolicy is shown below. This cleanup policy removes Deployments which have the label `canremove: "true"` if they have less than two replicas on a schedule of every 5 minutes.

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterCleanupPolicy
metadata:
  name: cleandeploy
spec:
  match:
    any:
    - resources:
        kinds:
          - Deployment
        selector:
          matchLabels:
            canremove: "true"
  conditions:
    any:
    - key: "{{ target.spec.replicas }}"
      operator: LessThan
      value: 2
  schedule: "*/5 * * * *"
```

Values from resources to be evaluated during a policy may be referenced with `target.*` similar to [mutate existing rules](/docs/writing-policies/mutate/#mutate-existing-resources).

Because Kyverno follows the principal of least privilege, depending on the resources you wish to remove it may be necessary to grant additional permissions to the cleanup controller. Kyverno will assist in informing you if additional permissions are required by validating them at the time a new cleanup policy is installed. See the [Customizing Permissions](/docs/installation/customization/#customizing-permissions) section for more details.

An example ClusterRole which allows Kyverno to cleanup Pods is shown below. This may need to be customized based on the values used to deploy Kyverno.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/component: cleanup-controller
    app.kubernetes.io/instance: kyverno
    app.kubernetes.io/part-of: kyverno
  name: kyverno:cleanup-pods
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - watch
  - list
  - delete
```

## Cleanup Label

In addition to policies which can declaratively define what resources to remove and when to remove them, the second option for cleanup involves assignment of a reserved label called `cleanup.kyverno.io/ttl` to the exact resource(s) which should be removed. The value of this label can be one of two supported formats. Any unrecognized formats will trigger a warning.

* An absolute time specified in ISO 8601 format (ex., `2023-10-04T003000Z` or `2023-10-04`)
* A remaining time calculated from when the label was observed (ex., `5m`, `4h`, or `1d`)

This label can be assigned to any resource and so long as Kyverno has the needed permissions to delete the resource (see above section for an example), it will be removed at the designated time.

For example, creation of this Pod will cause Kyverno to clean it up after two minutes and without the presence of a cleanup policy.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    cleanup.kyverno.io/ttl: 2m
  name: foo
spec:
  containers:
  - args:
    - sleep
    - 1d
    image: busybox:1.35
    name: foo
```

Although labeled resources are watched by Kyverno, the cleanup interval (the time resolution at which any cleanup can be performed) is controlled by a flag passed to the cleanup controller called `ttlReconciliationInterval`. This value is set to `1m` by default and can be changed if a longer resolution is required.

Because this is a label, there is opportunity to chain other Kyverno functionality around it. For example, it is possible to use a Kyverno mutate rule to assign this label to matching resources. A validate rule could be written prohibiting, for example, users from the `infra-ops` group from assigning the label to resources in certain Namespaces. Or, Kyverno could generate a new resource with this label as part of the resource definition.
