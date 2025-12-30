---
title: MutatingPolicy
description: >-
    Mutate new or existing resources
weight: 20
---

{{< feature-state state="beta" version="v1.16" />}}

The Kyverno `MutatingPolicy` type extends the Kubernetes `MutatingAdmissionPolicy` type for complex mutation operations and other features required for Policy-as-Code. A `MutatingPolicy` is a superset of a `MutatingAdmissionPolicy` and contains additional fields for Kyverno specific features.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: add-label
spec:
  matchConstraints:
    resourceRules:
    - apiGroups: [ "" ]
      apiVersions: [ "v1" ]
      operations: [ "CREATE" ]
      resources: [ "pods" ]
  mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: >
        Object{
          metadata: Object.metadata{
            labels: Object.metadata.labels{
              foo: "bar"
            }
          }
        } 
```

## Comparison with MutatingAdmissionPolicy

The table below compares major features across the Kubernetes `MutatingAdmissionPolicy` and Kyverno `MutatingPolicy` types.

| Feature            | MutatingAdmissionPolicy    |  MutatingPolicy         |
|--------------------|------------------------------|---------------------------------------------|
| Enforcement        | Admission                    | Admission, Background, Pipelines, ...       |
| Payloads           | Kubernetes                   | Kubernetes               |
| Distribution       | Kubernetes                   | Helm, CLI, Web Service, API, SDK            |
| CEL Library        | Basic                        | Extended                                    |
| Bindings           | Manual                       | Automatic                                   |
| Auto-generation    | -                            | Pod Controllers, MutatingAdmissionPolicy    |
| External Data      | -                            | Kubernetes resources or API calls           |
| Caching            | -                            | Global Context, image verification results  |
| Background scans   | -                            | Periodic, On policy creation or change      |
| Exceptions         | -                            | Fine-grained exceptions                     |
| Reporting          | -                            | Policy WG Reports API                       |
| Testing            | -                            | Kyverno CLI (unit), Chainsaw (e2e)          |
| Existing Resources | -                            | Background mutation support                 |

## Additional Fields

The `MutatingPolicy` extends the [Kubernetes MutatingAdmissionPolicy](https://kubernetes.io/docs/reference/access-authn-authz/mutating-admission-policy/) with the following additional fields for Kyverno features. A complete reference is provided in the [API specification](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/main/docs/user/crd/index.html#policies.kyverno.io%2fv1alpha1).

### evaluation

The `spec.evaluation` field defines how the policy is applied and how the payload is processed. It can be used to enable, or disable, admission request processing and existing resource mutation for a policy.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: sample
spec:
  evaluation:
    admission:
      enabled: true
    mutateExisting:
      enabled: false
  ...
```

- **`admission.enabled`**: When set to `true`, the policy is applied during admission requests (CREATE, UPDATE operations). This is the primary use case for mutating resources as they are being created or updated.

- **`mutateExisting.enabled`**: When set to `true`, the policy is applied to existing resources in the cluster through background processing. This allows you to mutate resources that already exist without requiring them to be recreated or updated.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/main/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.EvaluationConfiguration) for details.

### webhookConfiguration

The `spec.webhookConfiguration` field defines properties used to manage the Kyverno admission controller webhook settings.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: add-labels
spec:
  webhookConfiguration:
   timeoutSeconds: 15
  ...
```

In the policy above, `webhookConfiguration.timeoutSeconds` is set to `15`, which defines how long the admission request waits for policy evaluation. The default is `10` seconds, and the allowed range is `1` to `30` seconds. After this timeout, the request will fail or ignore the result based on the failure policy. Kyverno reflects this setting in the generated `MutatingWebhookConfiguration`.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/main/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.WebhookConfiguration) for details.

### autogen

The `spec.autogen` field defines policy auto-generation behaviors, to automatically generate policies for pod controllers and generate `MutatingAdmissionPolicy` types for Kubernetes API server execution.

Here is an example of generating policies for deployments, jobs, cronjobs, and statefulsets and also generating a `MutatingAdmissionPolicy` from the `MutatingPolicy` declaration:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: add-default-labels
spec:
  autogen:
   mutatingAdmissionPolicy:
    enabled: true
   podControllers:
     controllers:
      - deployments
      - jobs
      - cronjobs
      - statefulsets
```

Generating a `MutatingAdmissionPolicy` from a `MutatingPolicy` provides the benefits of faster and more resilient execution during admission controls while leveraging all features of Kyverno.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/main/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.AutogenConfiguration) for details.

## Policy Scope

MutatingPolicy comes in both cluster-scoped and namespaced versions:

- **`MutatingPolicy`**: Cluster-scoped, applies to resources across all namespaces
- **`NamespacedMutatingPolicy`**: Namespace-scoped, applies only to resources within the same namespace

Both policy types have identical functionality and field structure. The only difference is the scope of resource selection.

### Example NamespacedMutatingPolicy

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: NamespacedMutatingPolicy
metadata:
  name: add-labels
  namespace: production
spec:
  matchConstraints:
    resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["pods"]
  mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: >
        Object{
          metadata: Object.metadata{
            labels: Object.metadata.labels{
              environment: "production",
              managed: "true"
            }
          }
        }
```

As the name suggests, the `NamespacedMutatingPolicy` allows namespace owners to manage mutation policies without requiring cluster-admin permissions, improving multi-tenancy and security isolation.

## Kyverno CEL Libraries

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex mutation logic and advanced features. For comprehensive documentation of all available CEL libraries, see the [CEL Libraries documentation](/docs/policy-types/cel-libraries/).

## Patches with ApplyConfiguration

ApplyConfiguration patches use a merge-style approach, written as CEL expressions that return an Object. This method is more intuitive and less error-prone than JSONPatch for most mutations.

### Basic ApplyConfiguration

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: add-service-account
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE"]
  mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: >
        Object{
          metadata: Object.metadata{
            labels: Object.metadata.labels{
              foo: "bar"
            }
          }
        } 
```

### Conditional ApplyConfiguration

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: conditional-labels
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE", "UPDATE"]
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          has(object.metadata.labels) && has(object.metadata.labels.environment) ?
          Object{
            metadata: Object.metadata{
              labels: {"managed": "true"}
            }
          } : 
          Object{
            metadata: Object.metadata{
              labels: {"environment": "dev", "managed": "true"}
            }
          }
```

## RFC 6902 JSON Patches

JSONPatch provides fine-grained control over mutations using RFC 6902 JSON Patch operations. This method is useful for complex mutations that require precise control over the patch operations.

### Basic JSONPatch

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: add-labels-jsonpatch
spec:
    matchConstraints:
        resourceRules:
      - apiGroups: [""]
            apiVersions: ["v1"]
        resources: ["pods"]
            operations: ["CREATE"]
    mutations:
    - patchType: JSONPatch
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

### Multiple JSONPatch Operations

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: complex-jsonpatch
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE", "UPDATE"]
  mutations:
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          [
            JSONPatch{
              op: "add",
              path: "/metadata/labels/environment",
              value: "production"
            },
            JSONPatch{
              op: "add",
              path: "/metadata/annotations/kyverno.io~1managed",
              value: "true"
            },
            JSONPatch{
              op: "replace",
              path: "/spec/securityContext/runAsNonRoot",
              value: true
            }
          ]
```

### Conditional JSONPatch with Escape

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata: 
  name: escape-jsonpatch
spec:
    matchConstraints: 
        resourceRules:
      - apiGroups: [""]
                apiVersions: ["v1"]
                resources: ["pods"]
                operations: ["CREATE"]
    mutations:
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          [
            JSONPatch{
              op: "add",
              path: "/metadata/labels/" + jsonpatch.escapeKey("app.kubernetes.io/name"),
              value: "my-app"
            }
          ]
```

## Looping with CEL Functions

Kyverno supports looping through elements within resources using CEL functions like `map()`, allowing you to apply mutations to multiple elements within a resource.

### Iterating Through Containers

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: foreach
spec:
  matchConstraints:
    resourceRules:
    - apiGroups: [ "" ]
      apiVersions: [ "v1" ]
      operations: [ "CREATE" ]
      resources: [ "pods" ]
  mutations:
  - patchType: ApplyConfiguration
            applyConfiguration: 
      expression: >
        Object{
          spec: Object.spec{
            containers: object.spec.containers.map(container, Object.spec.containers{
              name: container.name,
              securityContext: Object.spec.containers.securityContext{
                allowPrivilegeEscalation: false
              }
            }
          } 
        } 
```

This example uses CEL's `map()` function to iterate through all containers in a pod and add a `securityContext` with `allowPrivilegeEscalation: false` to each container.

### Conditional Iteration with Filter

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: foreach-conditional
spec:
matchConstraints:
  resourceRules:
      - apiGroups: [""]
      apiVersions: ["v1"]
        resources: ["pods"]
      operations: ["CREATE", "UPDATE"]
  mutations:
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.spec.containers.map(c, 
            c.image.startsWith("nginx:") ?
            JSONPatch{
              op: "add",
              path: "/spec/containers/" + string(object.spec.containers.indexOf(c)) + "/env",
              value: [{"name": "NGINX_ENV", "value": "production"}]
            } : null
          ).filter(p, p != null)
```

This example uses CEL's `map()` and `filter()` functions to conditionally add environment variables only to containers that use nginx images.

## Mutating Existing Resources

MutatingPolicy supports background processing to mutate existing resources in the cluster, not just during admission. This is enabled by setting `spec.evaluation.mutateExisting.enabled: true`.

### Important Considerations

1. **Asynchronous Processing**: Mutation for existing resources is an asynchronous process. There will be a variable amount of delay between when the trigger is observed and when the existing resource is mutated.

2. **Custom Permissions**: Custom permissions are almost always required. Because these mutations occur on existing resources and not during an AdmissionReview, Kyverno may need additional permissions which it does not have by default. See the section on [customizing permissions](/docs/installation/customization.md#customizing-permissions) for how to grant additional permissions to the Kyverno background controller's ServiceAccount. Kyverno will perform these permissions checks when a mutate existing policy is installed.

### Same Trigger and Target

When the trigger and target are the same resource type, the policy will mutate ALL existing resources of that type when a trigger occurs:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: same-trigger-target
spec:
  evaluation:
    mutateExisting:
      enabled: true
  matchConstraints:
    resourceRules:
    - apiGroups: [ "" ]
      apiVersions: [ "v1" ]
      operations: [ "CREATE", "UPDATE"]
      resources: [ "namespaces" ]
  mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: >
        Object{
          metadata: Object.metadata{
            labels: Object.metadata.labels{
              foo: "bar"
            }
          }
        }
```

In this example, when any namespace is created or updated, Kyverno will:
1. Mutate the namespace that triggered the policy
2. Fetch and mutate ALL existing namespaces that match the criteria

This means if you have 10 existing namespaces and create a new one, all 11 namespaces will be mutated to add the `foo: "bar"` label.

### Different Trigger and Target

You can specify different trigger and target resources using `targetMatchConstraints`. When a trigger occurs, Kyverno will mutate ALL existing resources that match the target criteria:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: different-trigger-target
spec:
  evaluation:
    mutateExisting:
      enabled: true
  matchConstraints:
    resourceRules:
    - apiGroups: [ "" ]
      apiVersions: [ "v1" ]
      operations: [ "CREATE", "UPDATE"]
      resources: [ "namespaces" ]
      resourceNames: ["test-namespace"]
  targetMatchConstraints:
  namespaceSelector:
    matchLabels:
        test: "enabled"
    resourceRules:
    - apiGroups: [ "" ]
      apiVersions: [ "v1" ]
      operations: [ "CREATE", "UPDATE"]
      resources: [ "configmaps" ]
  mutations:
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: >
        Object{
          metadata: Object.metadata{
            labels: Object.metadata.labels{
              foo: "bar"
            }
          }
        }
```

In this example:
- **Trigger**: When the namespace `test-namespace` is created or updated
- **Target**: ALL existing ConfigMaps in namespaces with the label `test: enabled` will be mutated to add the `foo: "bar"` label

This means if you have 5 ConfigMaps in matching namespaces and update the trigger namespace, all 5 ConfigMaps will be mutated.

## Mutate Ordering

The order of mutations is important when multiple mutations are applied. Kyverno processes mutations in the order they appear in the policy. However, **the order is not guaranteed across multiple MutatingPolicies** - if multiple policies apply to the same resource, their execution order is not deterministic.

### Sequential Mutations

When multiple mutations are defined within the same policy, they are processed in order. This allows you to create mutations that depend on the results of previous mutations:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: simple-database-policy
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE"]
  mutations:
    # First mutation
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        object.spec.containers.exists(c, c.image.contains("cassandra") || c.image.contains("mongo")) ?
        Object{
          metadata: Object.metadata{
            labels: Object.metadata.labels{
              type: "database"
            }
          }
        } : Object{}

  # Second mutation  
  - patchType: ApplyConfiguration
    applyConfiguration:
      expression: |
        object.metadata.labels.type == "database" ?
        Object{
          metadata: Object.metadata{
            labels: Object.metadata.labels{
              backup: "yes"
            }
          }
        } : Object{}
```

In this example:
1. **First mutation**: Checks if any container uses cassandra or mongo images and adds `type: database` label
2. **Second mutation**: Checks if the `type: database` label exists, then adds `backup: yes`

The mutations must be ordered from top to bottom in the order of their dependencies within the same policy to ensure consistent results.

### Reinvocation Policy

The `reinvocationPolicy` controls whether mutations are reapplied when earlier mutations modify the object:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: reinvocation-example
spec:
  reinvocationPolicy: IfNeeded
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE"]
mutations:
    - patchType: ApplyConfiguration
        applyConfiguration:
        expression: |
            Object{
                metadata: Object.metadata{
              labels: {"stage": "initial"}
                }
            }
```

**Reinvocation Policy Options:**
- **`Never`**: Apply mutation once per binding (default)
- **`IfNeeded`**: Re-apply if a previous mutation modifies the object

## GitOps Considerations

While GitOps is great at managing configurations, some changes such as label propagations are best handled using mutating policies. 

Kyverno's MutatingPolicies are designed to interoperate nicely with GitOps solutions. 

For comprehensive guidance on GitOps integration, including specific configurations for Flux and ArgoCD, see the [GitOps Considerations section](/docs/policy-types/cluster-policy/mutate.md#gitops-considerations) in the ClusterPolicy mutate documentation.
