---
title: DeletingPolicy
description: >-
  Deletes Matching Resources
weight: 20
---

## Introduction

`DeletingPolicy` is a Kyverno custom resource that allows cluster administrators to automatically delete Kubernetes resources matching specified criteria, based on a cron schedule. This policy is helpful for implementing lifecycle management, garbage collection, or enforcing retention policies.

This policy provides the same functionality as the `CleanupPolicy` but it is designed to use CEL expressions for Kubernetes compatibility. 

Unlike admission policies that react to API requests, DeletingPolicy:

- Runs periodically at scheduled times

- Evaluates existing resources in the cluster

- Deletes resources when matching rules and conditions are satisfied

## Key Use Cases
- Find and delete orphaned resources, like completed jobs, periodically

- Remove expired secrets or configmaps

- Implement time-bound leases for critical resources

## Additional Fields
`schedule`  
A cron expression that defines when the policy will be evaluated.
```yaml
schedule: "0 0 * * *" #everyday at midnight
```
- Must follow standard cron format
- Minimum granularity is 1 minute

`matchPolicy`   
Controls how rules are matched against the API request:
```yaml
matchPolicy: "Equivalent"
```
- **Exact:** strict matching on group/version

- **Equivalent:** match across equivalent group/versions (recommended)

`deletionPropogationPolicy`     
 DeletionPropagationPolicy defines how resources will
 be deleted (Foreground, Background, Orphan)
```yaml
deletionProgrationPolicy: "Orphan"
```
- **Orphan:** Ensures dependent resources are deleted before the primary resource is removed.
- **Foreground:** Deletes the primary resource first, while dependents are removed asynchronously.
- **Background:** Deletes the primary resource but leaves its dependents untouched.

`lastExecutionTime`     
Records last time the `DeletingPolicy` was executed or triggered

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

## Kyverno CEL Libraries
Kyverno extends the standard CEL environment with built-in libraries to support advanced deletion logic. While it includes the standard Kyverno Kyverno CEL Libraries, the **DeletingPolicy** explicitly excludes support for **user** CEL library (user-lib), which are available in other policy types such ImageValidatingPolicy. For comprehensive documentation of all available CEL libraries, see the [Kyverno CEL Libraries documentation](/docs/policy-types/cel-libraries/)


### Resource library Examples
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: DeletingPolicy
metadata:
  name: dpol-resource-lib-check
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
  conditions:
    - name: check-cm-value
      expression: >-
        resource.Get("v1", "configmaps", "default", "clusterregistries").data["registries"] == "enabled"
  schedule: "*/1 * * * *"
```

### HTTP library Examples
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: DeletingPolicy
metadata:
  name: http-delete-check
spec:
  conditions:
  - name: http-200-check
    expression: >
      http.Get("http://test-api-service.default.svc.cluster.local:80").metadata.labels.app == "test"
  matchConstraints:
    resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      resources: ["pods"]
  schedule: "*/1 * * * *"
```

### ImageData library Examples
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: DeletingPolicy
metadata:
  name: image-date-delete
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
  schedule: "*/1 * * * *"
  conditions:
    - name: arch-check
      expression: >
        object.spec.containers.all(c, image.GetMetadata(c.image).config.architecture == "amd64")
```

### Image library Examples
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: DeletingPolicy
metadata:
  name: image-registry-delete
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
  schedule: "*/1 * * * *"
  conditions:
    - name: test-isImage
      expression: >
        object.spec.containers.all(c, isImage(c.image))
```

### GlobalContext library Examples
`policy`
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: DeletingPolicy
metadata:
  name: delete-if-deployment-exists
spec:
  schedule: "*/1 * * * *"
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
  conditions:
    - name: require-deployment
      expression: globalContext.Get("gctxentry-apicall-correct", "") != 0
```
`gctxentry`
```yaml
apiVersion: kyverno.io/v2alpha1
kind: GlobalContextEntry
metadata:
  name: gctxentry-apicall-correct
spec:
  apiCall:
    urlPath: "/apis/apps/v1/namespaces/test-globalcontext-apicall-correct/deployments"
    refreshInterval: 1h
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
Footer
