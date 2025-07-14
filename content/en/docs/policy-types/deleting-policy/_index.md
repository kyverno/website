---
title: DeletingPolicy
description: >-
  Deletes pre-existing resources from cluster on scheduled time
weight: 20
---

## Introduction

`DeletingPolicy` is a Kyverno custom resource that allows cluster administrators to automatically delete Kubernetes resources matching specified criteria, based on a cron schedule. This policy is helpful for implementing lifecycle management, garbage collection, or enforcing retention policies.

Unlike admission policies that react to API requests, DeletingPolicy:

- Runs periodically at scheduled times

- Evaluates existing resources in the cluster

- Deletes resources when matching rules and conditions are satisfied

## Key Use Cases
- Clean up old pods or jobs periodically

- Remove expired secrets or configmaps

- Enforce TTLs on temporary workloads

- Automatically delete unused preview environments

## Spec Fields
`schedule` 
A cron expression that defines when the policy will be evaluated.
```yaml
schedule: "0 0 * * *" #everyday at midnight
```
- Must follow standard cron format

- Minimum granularity is 1 minute

`namespaceSelector / objectSelector`
Use Kubernetes label selectors to narrow down namespaces or objects:
```yaml
namespaceSelector:
  matchLabels:
    team: dev

objectSelector:
  matchExpressions:
    - key: environment
      operator: In
      values: ["staging", "prod"]
```
- `namespaceSelector` applies to the namespace of namespaced resources

- `objectSelector` applies to the resource itself (metadata.labels)

`resourceRules`
Specify API groups, versions, resources, operations, and optional scope.
```yaml
resourceRules:
  - apiGroups: ["apps"]
    apiVersions: ["v1"]
    operations: ["DELETE"]
    resources: ["deployments"]
    scope: "Namespaced"
```
- `operations`: Always include DELETE or * since deletion is the purpose
- `resources`: Can use wildcards like pods/* or */*
- `scope`: Can be Namespaced, Cluster, or *

`excludeResourceRules`
Rules to explicitly exclude certain resources from being evaluated.
```yaml
excludeResourceRules:
  - apiGroups: ["apps"]
    apiVersions: ["v1"]
    resources: ["deployments"]
```
- If a resource matches both include and exclude rules, it is excluded.

`matchPolicy`
Controls how rules are matched against the API request:
```yaml
matchPolicy: "Equivalent"
```
- Exact: strict matching on group/version

- Equivalent: match across equivalent group/versions (recommended)

`conditions`
List of CEL expressions that must evaluate to true at execution time. All conditions must be satisfied for the resource to be deleted.
```yaml
conditions:
  - name: isOld
    expression: "now() - object.metadata.creationTimestamp > duration('72h')"
```
- A maximum of 64 conditions is allowed

- If any condition returns false, deletion is skipped

`variables`
Reusable CEL expressions that can be referred in match conditions or actions.
```yaml
variables:
  - name: isTest
    expression: "object.metadata.namespace.startsWith('test-')"
  - name: ageInDays
    expression: "(now() - object.metadata.creationTimestamp).days()"
```
- Variables must be acyclic and ordered

- Accessible in conditions via variables.<name>

- Not available in matchConditions (evaluated before variables)

## Example
This `DeletingPolicy` named cleanup-old-test-pods is configured to automatically delete pods in Kubernetes once per day at 1 AM. It targets pods that are:

- Located in namespaces labeled environment: test

- Are older than 72 hours

The policy uses a cron schedule to run periodically and applies conditions using CEL expressions to ensure only stale pods are cleaned up. Additionally, it defines a variable (isEphemeral) that could be used to further refine deletion logic, such as deleting only temporary or ephemeral pods.

`policy:`
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: DeletingPolicy
metadata:
  name: cleanup-old-test-pods
spec:
  schedule: "0 1 * * *"  # Run daily at 1 AM
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["*"]
        resources: ["pods"]
        scope: "Namespaced"
    namespaceSelector:
      matchLabels:
        environment: test
  conditions:
    - name: isOld
      expression: "now() - object.metadata.creationTimestamp > duration('72h')"
  variables:
    - name: isEphemeral
      expression: "has(object.metadata.labels.ephermal) && object.metadata.labels.ephemeral == 'true'"
```
`resource:`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example
  namespace: default
spec:
  containers:
  - image: nginx:latest
    name: example

```


## Observability: Tracking Deletion Events
Kyverno's DeletingPolicy not only removes resources on a schedule but also **emits a Kubernetes** `event` each time a deletion is executed. This event allows administrators and users to **trace exactly which policy deleted which resource**, improving transparency, auditing and troubleshooting.

### How to View Events
To view deletion events:

1. List policy-applied events (summary view):
```bash
kubectl get events --field-selector reason=PolicyApplied -A
```

2. Get the event name:
```bash
kubectl get events -n <namespace> \
  -o custom-columns=NAME:.metadata.name,REASON:.reason,MESSAGE:.message
```

3. Get full event details:
```bash
kubectl get event <event-name> -n <namespace> -o yaml
```

### Example Event
```yaml
apiVersion: v1
kind: Event
metadata:
  name: cleanup-old-test-pods.184c935c5c7c52c0
  namespace: default
  creationTimestamp: "2025-06-26T11:13:00Z"
  resourceVersion: "3894"
  uid: 064e08ef-4547-43a3-b199-d2bbadd93b65
action: Resource Cleaned Up
reason: PolicyApplied
message: successfully deleted the target resource Pod/default/example
involvedObject:
  apiVersion: policies.kyverno.io/v1alpha1
  kind: DeletingPolicy
  name: deleting-pod
  uid: cc44fb71-9413-4bbf-bc37-036a10f02c7c
related:
  apiVersion: v1
  kind: Pod
  name: example
  namespace: default
reportingComponent: kyverno-cleanup
reportingInstance: kyverno-cleanup-kyverno-cleanup-controller-76c8b69df6-89mjj
type: Normal
```

### What Gets Logged

When a `DeletingPolicy` triggers a deletion, Kyverno creates an event with:

- `action:` Resource cleaned-up
- `reason:` PolicyApplied
- `message:` human-readable success message
- `involvedObject:` the DeletingPolicy that triggered the action
- `related:` the resource that was deleted
- `reportingComponent:` kyverno-cleanup

> **Caution**
> 
> `DeletingPolicy` performs destructive actions. Always test your policies in a staging or dry run environment before applying them to production clusters. Ensure your selectors and conditions are strict enough to avoid accidental deletions.

## RBAC Requirements
The kyverno cleanup controller requires RBAC permissions to delete the targeted resources. Ensure that the following verbs are allowed in the cluster role:

-  `get`, `list`, `watch`, and `delete` on the targeted resources.

For example, to delete Configmaps:
```yaml
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch", "delete"]
```

> Kyverno cleanup-controller always requires RBAC permissions for deleting resources (even pods). But In some testing clusters like `Minikube` and `Kind` often already includes permissions to manage core resources like: 
- `pods`, `configmaps`, `secrets`, etc.
>So you may notice RBAC issues when deleting pods, because:
  - Kyverno already has access to them
  - There are no extra CRDs or cluster-scoped permissions needed
> But for other resources like `deployments`, `networkpolicies` etc, they are not always included in kyverno's default permissions. You must explicitly grants `delete` RBAC for those resources.

## Tips & Best Practices
- Use dry runs or audit mode before enabling destructive deletes

- Be careful when using wildcards * in resources

- Always validate your CEL expressions with Kyverno CLI

- Use meaningful variable/condition names for observability