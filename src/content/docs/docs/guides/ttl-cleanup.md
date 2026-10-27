---
title: TTL Cleanup
excerpt: Delete individual resources after a time-to-live expires.
sidebar:
  order: 80
---

Use the `cleanup.kyverno.io/ttl` label to mark individual resources for deletion without creating a policy. For scheduled deletion based on matching criteria, use [DeletingPolicy](/docs/policy-types/deleting-policy).

## Cleanup Label

The TTL label accepts either:

- An absolute time in ISO 8601 format, such as `2023-10-04T003000Z` or `2023-10-04`.
- A remaining time calculated from when the label was observed, such as `5m`, `4h`, or `1d`.

Unrecognized formats trigger a warning. The cleanup controller must have permission to watch and delete the labeled resource. See [Customizing Permissions](/docs/installation/customization#customizing-permissions).

The following Pod is deleted after two minutes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: temporary-job
  labels:
    cleanup.kyverno.io/ttl: 2m
spec:
  containers:
    - name: worker
      image: busybox:1.35
      args: ['sleep', '1d']
```

The cleanup controller checks labeled resources at the interval configured by `ttlReconciliationInterval`, which defaults to `1m`. See [Container Flags](/docs/installation/customization#container-flags).

You can use a [MutatingPolicy](/docs/policy-types/mutating-policy) to assign this label or a [ValidatingPolicy](/docs/policy-types/validating-policy) to restrict who may set it.

## Deletion Propagation

Set the `cleanup.kyverno.io/propagation-policy` annotation to control dependent resources:

```yaml
metadata:
  labels:
    cleanup.kyverno.io/ttl: 2m
  annotations:
    cleanup.kyverno.io/propagation-policy: Foreground
```

Supported values are `Foreground` (delete dependents first), `Background` (delete dependents asynchronously), and `Orphan` (retain dependents). If omitted, Kubernetes applies its default deletion behavior.
