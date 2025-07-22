---
title: MutatingPolicy
description: >-
    Automatically mutates resources by modifying or adding fields, both at admission and in existing resources, based on defined match rules and conditions.
weight: 20
---

The Kyverno `MutatingPolicy` type extends the Kubernetes `MutatingAdmissionPolicy` type for complex mutation operations and other features required for Policy-as-Code. A `MutatingPolicy` is a superset of a `MutatingAdmissionPolicy` and contains additional fields for Kyverno specific features.

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

In the policy above, `webhookConfiguration.timeoutSeconds` is set to `15`, which defines how long the admission request waits for policy evaluation. The default is `10s`, and the allowed range is `1–30s`. After this timeout, the request may fail or ignore the result based on the failure policy. Kyverno reflects this setting in the generated `MutatingWebhookConfiguration`.

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

## Kyverno CEL Libraries

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex mutation logic and advanced features. The same libraries available in `ValidatingPolicy` are also available in `MutatingPolicy`.

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
        expression: |
          Object{
            spec: Object.spec{
              serviceAccountName: "default-sa"
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

### Nested Object Mutation

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: add-container-security
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
          Object{
            spec: Object.spec{
              securityContext: Object.spec.securityContext{
                runAsNonRoot: true,
                runAsUser: 1000
              }
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

## Looping (Foreach)

Kyverno supports looping through resources using the `foreach` construct, allowing you to apply mutations to multiple resources or elements within a resource.

### Foreach on Pod Controllers


### Foreach with Conditions

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

## Mutating Existing Resources

MutatingPolicy supports background processing to mutate existing resources in the cluster, not just during admission.

### Background Mutation

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: background-mutation
spec:
  evaluation:
    background:
      enabled: true
    admission:
      enabled: false
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
          Object{
            metadata: Object.metadata{
              labels: {"background-managed": "true"}
            }
          }
```

### Periodic Background Processing


## Mutate Ordering

The order of mutations is important when multiple mutations are applied. Kyverno processes mutations in the order they appear in the policy.

### Sequential Mutations

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: sequential-mutations
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE"]
  mutations:
    # First mutation: Add basic labels
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            metadata: Object.metadata{
              labels: {"app": "my-app"}
            }
          }
    # Second mutation: Add environment-specific labels
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            metadata: Object.metadata{
              labels: {"environment": "production"}
            }
          }
    # Third mutation: Add security context
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            spec: Object.spec{
              securityContext: Object.spec.securityContext{
                runAsNonRoot: true
              }
            }
          }
```

### Reinvocation Policy

The `reinvocationPolicy` controls whether mutations are reapplied when earlier mutations modify the object.

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
    # First mutation: Add a label
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            metadata: Object.metadata{
              labels: {"stage": "initial"}
            }
          }
    # Second mutation: Use the label added by the first mutation
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          object.metadata.labels.stage == "initial" ?
          Object{
            metadata: Object.metadata{
              labels: {"processed": "true"}
            }
          } : Object{}
```

## Combining Mutation and Generation

MutatingPolicy can be combined with generation capabilities to create resources based on mutations.

### Mutation with Generation

## GitOps Considerations

When using MutatingPolicy in GitOps workflows, consider the following:

### Immutable Resources

Some resources become immutable after creation. MutatingPolicy can help ensure proper configuration from the start:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: gitops-immutable
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
        expression: |
          Object{
            spec: Object.spec{
              securityContext: Object.spec.securityContext{
                runAsNonRoot: true,
                runAsUser: 1000,
                fsGroup: 2000
              }
            }
          }
```

### Policy Versioning

Version your policies and use proper labeling for GitOps tracking:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: gitops-versioned
  labels:
    app.kubernetes.io/version: "v1.0.0"
    app.kubernetes.io/part-of: "gitops-policies"
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
        expression: |
          Object{
            metadata: Object.metadata{
              labels: {
                "policy-version": "v1.0.0",
                "gitops-managed": "true"
              }
            }
          }
```

### Rollback Strategy

Implement rollback strategies for mutations:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: MutatingPolicy
metadata:
  name: rollback-safe
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
          Object{
            metadata: Object.metadata{
              annotations: {
                "kyverno.io~1last-mutation": string(timestamp.now()),
                "kyverno.io~1policy-version": "v1.0.0"
              }
            }
          }
```

## Policy Execution Flow

1. **Admission Request**: A Kubernetes resource creation or update request is received
2. **Match Evaluation**: Kyverno checks `matchConstraints` to determine if the policy applies
3. **Condition Evaluation**: CEL `matchConditions` are evaluated if present
4. **Variable Resolution**: Variables are computed using CEL expressions
5. **Mutation Execution**: Each mutation is executed in order:
   - ApplyConfiguration mutations merge changes
   - JSONPatch mutations apply precise patches
6. **Reinvocation**: If `reinvocationPolicy` is `IfNeeded`, mutations may re-run
7. **Final Object**: The mutated object is passed to the Kubernetes API server