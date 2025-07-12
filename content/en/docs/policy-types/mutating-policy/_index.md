---
title: MutatingPolicy
description: >-
    Automatically mutates resources by modifying or adding fields, both at admission and in existing resources, based on defined match rules and conditions.
weight: 20
---

## Introduction

`MutatingPolicy` allows you to define Kubernetes-native mutation policies using common expression language (CEL). Kyverno uses this policy to automatically modify resources during admission.
> Think of it as smart rulebook that tells kubernetes how to rewrite your manifests before they hit the etcd store.
---

## Spec Structure


**With JSONPatch**
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
    name: test-mpol-jsonpatch
spec:
    matchConstraints:
        resourceRules:
        -   apiGroups: ["apps"]
            apiVersions: ["v1"]
            operations: ["CREATE"]
            resources: ["deployments"]
    matchConditions:
    -   name: is-dev-namespace
        expression: request.namespace == 'dev'
    mutations:
    -   patchType: JSONPatch
        jsonPatch:
            expression: |
                has(object.metadata.labels) ?
                [
                    JSONPatch{
                        op: "add",
                        path: "/metadata/labels/managed",
                        value: "true"
                    }
                ] : 
                [
                    JSONPatch{
                        op: "add",
                        path: "/metadata/labels",
                        value: {"managed": "true"}
                    }
                ]
```

**With ApplyConfiguration**
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata: 
    name: add-service-account
spec:
    failurePolicy: Fail
    matchConstraints: 
        resourceRules:
            -   apiGroups: [""]
                apiVersions: ["v1"]
                resources: ["pods"]
                operations: ["CREATE"]
    mutations:
        -   patchType: ApplyConfiguration
            applyConfiguration: 
                expression: |
                    Object{
                        spec: Object.spec{
                            serviceAccountName: "default-sa"
                        }
                    
                    }
    reinvocationPolicy: IfNeeded

```


## Spec Fields
`failurePolicy`
- **Values**: `Ignore`, `Fail`
- Controls what happens if CEL evaluation fails(e.g. syntax error)
- **Default**: `Fail`
> ⚠️ Use `Ignore` cautiously - If your mutation fails silently, debugging can get tricky.

`matchConstraints`  
Defines what requests the policy should care about. Includes:
- `resourceRules: ` API groups, versions, operations and resources.
- `namespaceSelector` and `objectSelector: ` Label-based scoping.
- `matchConditions: ` (CEL)[https://cel.dev/] conditions applied before mutation.

**Example**

```yaml
matchConstraints:
  resourceRules:
    - apiGroups: ["apps"]
      apiVersions: ["v1"]
      resources: ["deployments"]
      operations: ["CREATE", "UPDATE"]
  namespaceSelector:
    matchLabels:
      team: "dev"
```

`mutations`     
The actual operations that modify the incoming resource. Two types: 

**ApplyConfiguration**  
A merge-style patch, written as a CEL expression that returns an Object.
```yaml
mutations:
    - patchType: ApplyConfiguration
        applyConfiguration:
        expression: |
            Object{
                metadata: Object.metadata{
                    labels: {"env": "prod"}
                }
            }
```

**JSONPatch**   
A JSON Patch-style mutation using CEL.
```yaml
mutations:
    - patchType: JSONPatch
      jsonPatch:
        expression: |
            [
            JSONPatch{op: "add", path: "/metadata/labels/foo", value: "bar"}
            ]
```
> ⚠️ JSONPatch paths must be valid JSON Pointers. Use jsonpatch.escapeKey() for special characters.

`reinvocationPolicy`
- `Never:` Apply mutation once per binding.
- `IfNeeded:` Re-apply if a previous mutation modifies the object.

Great for when mutations depend on one another. Example: add a label, then use that label in another mutation.

`targetMatchConstraints`
Specifies which resources the mutations target(not just match)
This allows for sophisticated seperation of who triggers the policy and who gets mutated.

## Policy Execution Flow
1. Admission request comes in
2. Kyverno checks `matchConstraints`. If the resource matches, continue.
3. CEL `matchConditions` are evaluated.
4. If they pass, each `mutation` is executed in order.
5. If `reinvocationPolicy` is `IfNeeded`, mutations may re-run if earlier ones changed the object.
6. The final object is passed on the Kubernetes API server.


## Summary
The MutatingAdmissionPolicy is a powerful mechanism to automate Kubernetes resource standardization and compliance. With CEL expressions, reinvocation control, and resource targeting, it provides fine-grained mutation logic that runs before your workload even hits the cluster.

Just remember: with great power comes great re-evaluation responsibility. 😅

Stay declarative, stay sane