---
title: Getting Started with CEL Policies
description: >-
  A beginner-friendly introduction to writing CEL-based policies in Kyverno
sidebar:
  order: 11
---

Common Expression Language (CEL) is the standard for writing performant, native policies in Kyverno and Kubernetes.

## Why CEL?

CEL-based policies provide:

| Benefit | Description |
|---------|-------------|
| **Performance** | Improved latency and reduced CPU usage |
| **Kubernetes Native** | Aligns with ValidatingAdmissionPolicy |
| **Expressiveness** | Flexible validation logic |
| **Auto-Generation** | Generates native Kubernetes admission policies |

## Creating a Policy

This example demonstrates a validation policy that checks for required labels.

### Structure

A CEL-based `ValidatingPolicy` includes the following components:

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-app-label
spec:
  validationActions:
    - Deny                    # Action on failure: Deny, Audit, or Warn
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']   # Target resources
  validations:
    - expression: "has(object.metadata.labels.app)"
      message: "Pods must have an 'app' label"
```

### Apply and Test

1. Save `require-app-label.yaml`.
2. Apply the policy: `kubectl apply -f require-app-label.yaml`.
3. Test with a non-compliant pod:

```yaml
# Denied
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest
```

```yaml
# Allowed
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  labels:
    app: my-app
spec:
  containers:
    - name: nginx
      image: nginx:latest
```

## CEL Expressions

References for common CEL operations:

### Accessing Fields

```cel
# Resource context
object.metadata.name                    # Pod name
object.metadata.namespace               # Namespace
object.metadata.labels                  # All labels
object.spec.containers                  # Container list
```

### Checking Existence

```cel
# Check field existence
has(object.metadata.labels)
has(object.metadata.labels.app)

# Safe access (returns empty object if null)
object.metadata.?labels.orValue({})
```

### Operators

```cel
# Comparison
object.spec.replicas > 1

# Logical
condition1 && condition2
condition1 || condition2
!condition

# String operations
object.metadata.name.startsWith("app-")
```

### Lists

```cel
# Check all items
object.spec.containers.all(c, has(c.resources))

# Check existence in list
object.spec.containers.exists(c, c.image.contains("nginx"))
```

## Policy Patterns

### Require Labels

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
      message: "Pods must have 'app' and 'env' labels"
```

### Restrict Container Images

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-image-registries
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
        object.spec.containers.all(c,
          c.image.startsWith("ghcr.io/") ||
          c.image.startsWith("docker.io/library/")
        )
      message: "Images must be from approved registries (ghcr.io or docker.io/library)"
```

### Require Resource Limits

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-resource-limits
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
        object.spec.containers.all(c,
          has(c.resources) &&
          has(c.resources.limits) &&
          has(c.resources.limits.memory) &&
          has(c.resources.limits.cpu)
        )
      message: "All containers must have CPU and memory limits"
```

### Block Latest Tag

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-latest-tag
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
        object.spec.containers.all(c,
          !c.image.endsWith(":latest") &&
          c.image.contains(":")
        )
      message: "Container images must use a specific tag, not 'latest'"
```

## Using Variables

Variables simplify complex expressions:

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: validate-deployment
spec:
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
      - apiGroups: ['apps']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['deployments']
  variables:
    - name: containers
      expression: "object.spec.template.spec.containers"
    - name: labels
      expression: "object.metadata.?labels.orValue({})"
  validations:
    - expression: "'app' in variables.labels"
      message: "Deployment must have an 'app' label"
    - expression: |
        variables.containers.all(c, has(c.resources))
      message: "All containers must have resource specifications"
```

## Built-in Variables

| Variable | Description |
|----------|-------------|
| `object` | The resource being validated |
| `oldObject` | Previous version (for UPDATE operations) |
| `request` | Admission request data |
| `request.operation` | Operation type (CREATE, UPDATE, DELETE, CONNECT) |
| `request.userInfo` | Requestor information |

## Next Steps

- [ValidatingPolicy](/docs/policy-types/validating-policy)
- [MutatingPolicy](/docs/policy-types/mutating-policy)
- [GeneratingPolicy](/docs/policy-types/generating-policy)
- [CEL Libraries](/docs/policy-types/cel-libraries)
- [Variables Reference](/docs/cel/variables-reference)- [Migration Guide](/docs/migration/traditional-to-cel) - Migrate existing policies to CEL

## Tips for Success

1. **Start Simple**: Begin with basic validation rules and add complexity gradually
2. **Use Variables**: Break complex expressions into named variables for clarity
3. **Test Thoroughly**: Use the Kyverno CLI to test policies before deploying
4. **Enable Audit Mode**: Start with `Audit` validation action to observe without blocking
5. **Check Logs**: Review Kyverno logs for policy evaluation details
