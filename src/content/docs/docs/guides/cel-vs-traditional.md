---
title: CEL vs Traditional Policies
description: >-
  Comparison between CEL-based policies and traditional ClusterPolicy/Policy
sidebar:
  order: 15
---

Kyverno supports two policy definitions: **CEL-based policies** (ValidatingPolicy, MutatingPolicy, etc.) and **Traditional ClusterPolicy/Policy** resources. This guide outlines the key differences.

## Feature Comparison

| Feature | CEL-based Policies | Traditional Policies |
|---------|-------------------|---------------------|
| **API Version** | `policies.kyverno.io/v1` | `kyverno.io/v1` |
| **Logic** | CEL (Common Expression Language) | YAML patterns, JMESPath |
| **Performance** | High (compiled) | Standard |
| **K8s Native** | Aligns with ValidatingAdmissionPolicy | Custom Resource |
| **Status** | Stable (v1) | Stable (v1) |

## Policy Types

| Purpose | CEL Policy | Traditional Equivalent |
|---------|------------|------------------------|
| Validation | `ValidatingPolicy` | `ClusterPolicy` (validate) |
| Mutation | `MutatingPolicy` | `ClusterPolicy` (mutate) |
| Generation | `GeneratingPolicy` | `ClusterPolicy` (generate) |
| Cleanup | `DeletingPolicy` | `CleanupPolicy` |
| Images | `ImageValidatingPolicy` | `ClusterPolicy` (verifyImages) |

## Examples

### Validation: Require Labels

**Traditional ClusterPolicy:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
  rules:
    - name: check-labels
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Labels 'app' and 'env' are required"
        pattern:
          metadata:
            labels:
              app: "?*"
              env: "?*"
```

**CEL-based ValidatingPolicy:**

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-labels
spec:
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: |
        has(object.metadata.labels.app) &&
        has(object.metadata.labels.env)
      message: "Labels 'app' and 'env' are required"
```

### Validation: Block Latest Tag

**Traditional ClusterPolicy:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest
spec:
  validationFailureAction: Enforce
  rules:
    - name: no-latest
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Using 'latest' tag is not allowed"
        pattern:
          spec:
            containers:
              - image: "!*:latest"
```

**CEL-based ValidatingPolicy:**

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-latest
spec:
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: |
        object.spec.containers.all(c, !c.image.endsWith(":latest"))
      message: "Using 'latest' tag is not allowed"
```

### Mutation: Add Labels

**Traditional ClusterPolicy:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-labels
spec:
  rules:
    - name: add-team-label
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              team: platform
```

**CEL-based MutatingPolicy:**

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-labels
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['pods']
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: |
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                team: "platform"
              }
            }
          }
```

### Generation: Clone Secrets

**Traditional ClusterPolicy:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: clone-secret
spec:
  rules:
    - name: clone-regcred
      match:
        any:
          - resources:
              kinds:
                - Namespace
      generate:
        synchronize: true
        apiVersion: v1
        kind: Secret
        name: regcred
        namespace: "{{request.object.metadata.name}}"
        clone:
          namespace: default
          name: regcred
```

**CEL-based GeneratingPolicy:**

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: clone-secret
spec:
  evaluation:
    synchronize:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['namespaces']
  variables:
    - name: targetNs
      expression: "object.metadata.name"
    - name: source
      expression: resource.Get("v1", "secrets", "default", "regcred")
  generate:
    - expression: generator.Apply(variables.targetNs, [variables.source])
```

## Key Differences

### Language

**Traditional:** YAML patterns with wildcards (`?*`, `!*:latest`) and JMESPath (`{{ request.object.metadata.name }}`).

**CEL-based:** CEL (Common Expression Language), strongly typed and compiled.

### Matching

**Traditional:**
```yaml
match:
  any:
    - resources:
        kinds:
          - Pod
```

**CEL-based:**
```yaml
matchConstraints:
  resourceRules:
    - apiGroups: ['']
      apiVersions: ['v1']
      operations: ['CREATE', 'UPDATE']
      resources: ['pods']
```

### Actions

**Traditional:** `validationFailureAction: Enforce` or `Audit`.

**CEL-based:** `validationActions: [Deny, Audit, Warn]`.

## Usage Recommendations

**Use CEL-based policies for:**

- New deployments
- High-performance requirements
- Complex validation logic
- Native K8s policy generation
- Non-Kubernetes payloads (Terraform, JSON)

**Use Traditional policies for:**

- Existing stable deployments
- Simple pattern matching
- Teams preferring YAML-only syntax
✅ **Choose traditional policies when:**

- You have existing policies that work well
- Simple pattern matching is sufficient
- Your team is more comfortable with YAML patterns
- You need features only available in traditional policies

## Migration Path

If you're considering migrating from traditional to CEL-based policies:

1. **Start with new policies** - Write new policies using CEL
2. **Run in parallel** - Both policy types can coexist
3. **Migrate gradually** - Convert policies one at a time
4. **Use the migration guide** - See [Migrating from Traditional to CEL](/docs/migration/traditional-to-cel)

## Feature Availability

| Feature | CEL-based | Traditional |
|---------|-----------|-------------|
| Validate resources | ✅ ValidatingPolicy | ✅ ClusterPolicy validate |
| Mutate resources | ✅ MutatingPolicy | ✅ ClusterPolicy mutate |
| Generate resources | ✅ GeneratingPolicy | ✅ ClusterPolicy generate |
| Delete resources | ✅ DeletingPolicy | ✅ CleanupPolicy |
| Verify images | ✅ ImageValidatingPolicy | ✅ ClusterPolicy verifyImages |
| Policy exceptions | ✅ PolicyException | ✅ PolicyException |
| Background scans | ✅ | ✅ |
| Auto-gen for pod controllers | ✅ | ✅ |
| Generate ValidatingAdmissionPolicy | ✅ | ❌ |
| Generate MutatingAdmissionPolicy | ✅ | ❌ |
| JSON/YAML payload validation | ✅ | Limited |
| External data (API calls) | ✅ | ✅ |

## Conclusion

CEL-based policies represent the future direction of Kyverno and offer significant advantages in performance, Kubernetes alignment, and expressiveness. However, traditional policies remain fully supported and are appropriate for many use cases, especially when simplicity and familiarity are priorities.

For new deployments and performance-critical environments, we recommend CEL-based policies. For existing deployments with working traditional policies, migration can be gradual based on your needs.
