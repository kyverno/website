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

`matchConditions` 
A list of CEL expressions that must evaluate to `true` for a resource to match.
```yaml
matchConditions:
  - name: isTestNamespace
    expression: "object.metadata.namespace.startsWith('test-')"
```

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

`status`
This field contains the latest execution metadata and readiness of the policy

```yaml
status:
  conditionStatus:
    ready: true
    message: "Successfully evaluated"
    conditions:
      - type: Ready
        status: "True"
        reason: "AllMatched"
        message: "Policy applied"
        lastTransitionTime: "2025-06-18T15:04:05Z"
  lastExecutionTime: "2025-06-18T01:00:00Z"
```

## Example
This `DeletingPolicy` named cleanup-old-test-pods is configured to automatically delete pods in Kubernetes once per day at 1 AM. It targets pods that are:

- Located in namespaces labeled environment: test

- Are older than 72 hours

The policy uses a cron schedule to run periodically and applies conditions using CEL expressions to ensure only stale pods are cleaned up. Additionally, it defines a variable (isEphemeral) that could be used to further refine deletion logic, such as deleting only temporary or ephemeral pods.


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
      expression: "object.metadata.labels.ephemeral == 'true'"
```

## Tips & Best Practices
- Use dry runs or audit mode before enabling destructive deletes

- Be careful when using wildcards * in resources

- Always validate your CEL expressions with Kyverno CLI

- Use meaningful variable/condition names for observability