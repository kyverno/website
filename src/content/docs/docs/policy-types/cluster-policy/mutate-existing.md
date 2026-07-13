---
title: Mutate Existing Resources
description: Retroactively apply mutations to existing resources in your cluster using background policies.
sidebar:
  order: 5
---

In addition to standard mutations applied during the AdmissionReview process, Kyverno supports mutating existing resources already present in the cluster. This feature, often called **background mutation**, allows for retroactive changes or cross-resource synchronization where a change in one resource triggers a mutation in another.

## Overview

Unlike standard mutate rules, "mutate existing" rules are applied asynchronously by the Kyverno background controller. This decoupling provides several unique capabilities:

1.  **Cross-Resource Mutation**: Trigger a mutation on a `Secret` when a `ConfigMap` is updated.
2.  **Retroactive Application**: Apply new policies to resources that were created before the policy existed.
3.  **Policy-Driven Updates**: Optionally trigger mutations on all matching resources when the policy itself is created or updated.

### Key Implications

- **Asynchronous Processing**: There is a variable delay between the trigger event and the actual mutation of the target resource.
- **Permissions Management**: Since these mutations occur in the background, the Kyverno background controller requires explicit RBAC permissions for the target resources.

## Triggers

A background mutation is initiated in three ways:

1.  **Admission Events**: When a resource matching the rule's `match` block is created or updated.
2.  **Policy Events**: When the policy is created or updated (if `mutateExistingOnPolicyUpdate` is set to `true`).
3.  **Background Scanning**: By default, Kyverno performs a "force reconciliation" every hour to ensure all resources comply with the latest policies.

## Targets

The `mutate.targets` field defines which resources should be modified. This is separate from the `match` block, which defines what _triggers_ the rule.

```yaml
mutate:
  targets:
    - apiVersion: v1
      kind: Secret
      name: my-secret
      namespace: '{{ request.namespace }}'
```

### Selection Methods

- **By Name**: Specify the exact `name` and `namespace`.
- **By Selector**: Use a label selector to match multiple resources.
- **Wildcards**: Omitting the `name` field implies a wildcard (`*`), targeting all resources of that kind in the specified namespace.

:::caution[Note]
All target resources within a single rule must share the same OpenAPI V3 schema (except `metadata`). Mutating both a `Pod` and a `Deployment` in the same rule will fail.
:::

## Permissions

Kyverno requires additional permissions to modify existing resources. By default, it does not have `update` permissions for all resource types.

Prior to installing a mutate-existing rule, you must grant the Kyverno background controller's ServiceAccount the necessary RBAC permissions. Use the [customizing permissions](/docs/installation/customization#customizing-permissions) guide for details.

Kyverno validates these permissions when the policy is installed. If permissions are missing, policy creation will fail.

## Policy Update Behavior

Use the `mutateExistingOnPolicyUpdate` attribute to control whether the policy should be applied to existing resources immediately upon policy creation or modification.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: mutate-existing-secret
spec:
  rules:
    - name: mutate-secret-on-configmap-event
      match:
        any:
          - resources:
              kinds:
                - ConfigMap
              names:
                - dictionary-1
              namespaces:
                - staging
      mutate:
        mutateExistingOnPolicyUpdate: true
        targets:
          - apiVersion: v1
            kind: Secret
            name: secret-1
            namespace: '{{ request.object.metadata.namespace }}'
        patchStrategicMerge:
          metadata:
            labels:
              foo: bar
```

If set to `true`, Kyverno will generate `UpdateRequests` for all matching targets as soon as the policy is admitted.

## Examples

### Synchronizing Labels

This policy updates a `Secret` whenever a specific `ConfigMap` is changed.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-secret-labels
spec:
  rules:
    - name: sync-labels
      match:
        any:
          - resources:
              kinds:
                - ConfigMap
              names:
                - dictionary-1
              namespaces:
                - staging
      mutate:
        targets:
          - apiVersion: v1
            kind: Secret
            name: secret-1
            namespace: '{{ request.namespace }}'
        patchStrategicMerge:
          metadata:
            labels:
              sync-status: updated
```

### Restarting Deployments on Secret Change

A common use case is to "roll" a Deployment when its configuration Secret changes.

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: restart-deployment-on-secret-change
spec:
  rules:
    - name: refresh-env
      match:
        any:
          - resources:
              kinds:
                - Secret
              selector:
                matchLabels:
                  kyverno.io/watch: 'true'
              operations:
                - UPDATE
      mutate:
        targets:
          - apiVersion: apps/v1
            kind: Deployment
            namespace: '{{request.namespace}}'
            preconditions:
              all:
                - key: '{{target.metadata.name}}'
                  operator: Equals
                  value: 'testing-*'
        patchStrategicMerge:
          spec:
            template:
              metadata:
                annotations:
                  kyverno.io/last-updated: '{{ time_now() }}'
```

## Troubleshooting

### UpdateRequests

Kyverno uses a Custom Resource called `UpdateRequest` (UR) to manage background tasks. If a mutation fails, check the UR status:

```bash
kubectl get ur -n kyverno
```

To see the detailed error message:

```bash
kubectl describe ur <ur-name> -n kyverno
```

Common error states:

- **Failed**: Typically indicates missing RBAC permissions or a malformed patch.
- **Pending**: The request is queued for processing.

### Success Events

Once a mutation is successful, Kyverno can emit an event on the target resource (if not disabled in configuration):

```bash
kubectl describe <resource-kind> <resource-name>
```

Look for a `Normal` event with the reason `PolicyApplied` from the `kyverno-mutate` source.

## Best Practices

- **Consolidate Rules**: If you need to mutate the same resource multiple times, combine them into a single rule to reduce the number of `UpdateRequests`.
- **Use Preconditions**: Use `preconditions` within the `targets` block to avoid unnecessary mutations on resources that already comply.
- **Sandbox Testing**: Always test background policies in a staging environment, as they can potentially modify many resources at once.
- **Resource Filters**: Note that targets are **not** subject to Kyverno's default [resource filters](/docs/installation/customization#resource-filters).
