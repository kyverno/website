---
title: 'CEL Built-in Variables Reference'
linkTitle: 'Variables Reference'
weight: 20
description: >
  Complete reference of all variables available in Kyverno CEL expressions for v1alpha1 policy types
---

# CEL Built-in Variables Reference

When writing CEL expressions in Kyverno v1alpha1 policy types (ValidatingPolicy, ImageValidatingPolicy, etc.), you have access to several built-in variables that provide context about the Kubernetes resource, request, and environment.

:::warning[Important]
This documentation is specifically for **CEL expressions** in **v1alpha1 policy types**. For traditional ClusterPolicy/Policy with JMESPath variables using `{{ ... }}` syntax, see the [Variables documentation](../../policy-types/cluster-policy/variables/).

The variable syntax and availability differs between traditional policies and CEL-based policies.
:::

This page documents all CEL variables with their data types, usage examples, and availability across different policy types.

## Standard Kubernetes Variables

### `object`

**Type:** `Object`  
**Description:** The incoming Kubernetes resource being processed

```yaml
# Access resource metadata
object.metadata.name
object.metadata.namespace
object.metadata.labels['app']

# Access spec fields
object.spec.replicas
object.spec.template.spec.containers[0].image

# Check if field exists
has(object.metadata.labels.app)
```

### `oldObject`

**Type:** `Object` (update operations only)  
**Description:** The existing Kubernetes resource before modification

```yaml
# Compare old and new values
object.spec.replicas != oldObject.spec.replicas

# Check what changed
object.metadata.labels != oldObject.metadata.labels
```

### `request`

**Type:** `Object`  
**Description:** Information about the admission request

```yaml
# Basic request info
request.operation  # "CREATE", "UPDATE", "DELETE"
request.kind.kind  # "Pod", "Deployment", etc.
request.namespace

# User information
request.userInfo.username
request.userInfo.uid
request.userInfo.groups

# Service account context (if applicable)
request.userInfo.username.startsWith("system:serviceaccount:")
```

## Kyverno-Specific Variables

### `serviceAccountName`

**Type:** `String`  
**Description:** Name of the service account associated with the request

```yaml
# Validate service account naming
serviceAccountName.startsWith('allowed-prefix-')

# Check against allowed list
serviceAccountName in ['default', 'kyverno', 'system']
```

### `serviceAccountNamespace`

**Type:** `String`  
**Description:** Namespace of the service account

```yaml
# Ensure service account is in same namespace
serviceAccountNamespace == object.metadata.namespace

# Restrict cross-namespace service accounts
serviceAccountNamespace == 'system-namespace'
```

### `images`

**Type:** `List<Object>`  
**Description:** List of container images from the resource (Pods, Deployments, etc.)

```yaml
# Check all images come from allowed registry
images.all(image, image.registry == 'allowed-registry.com')

# Ensure no latest tags
images.all(image, image.tag != 'latest')

# Validate image naming
images.all(image, image.name.matches('^[a-z0-9-]+$'))
```

### `request.roles`

**Type:** `List<String>`  
**Description:** List of Role names the user has access to

```yaml
# Check if user has specific role
'pod-reader' in request.roles

# Ensure user has required roles
['developer', 'deployer'].all(role, role in request.roles)
```

### `request.clusterRoles`

**Type:** `List<String>`  
**Description:** List of ClusterRole names the user has access to

```yaml
# Check cluster-level permissions
'cluster-admin' in request.clusterRoles

# Validate minimum permissions
request.clusterRoles.exists(role, role.startsWith('system:'))
```

## Context Variables

### `params`

**Type:** `Object`  
**Description:** Policy parameters passed from PolicyBinding or ClusterPolicyBinding

```yaml
# Access policy parameters
params.allowedRegistries.exists(registry,
  images.all(img, img.registry == registry))

# Use parameter defaults
has(params.maxReplicas) ? params.maxReplicas : 10
```

### `namespaceObject`

**Type:** `Object`  
**Description:** The Namespace object (when applicable)

```yaml
# Check namespace labels
namespaceObject.metadata.labels['environment'] == 'production'

# Validate namespace annotations
has(namespaceObject.metadata.annotations['policy.kyverno.io/exclude'])
```

### `authorizer`

**Type:** `Object`  
**Description:** Authorization interface for checking permissions

```yaml
# Check if user can perform action
authorizer.check({
  'group': 'apps',
  'version': 'v1',
  'resource': 'deployments',
  'verb': 'create',
  'namespace': object.metadata.namespace
}).allowed

# Verify additional permissions
authorizer.check({
  'resource': 'secrets',
  'verb': 'get',
  'name': 'my-secret',
  'namespace': object.metadata.namespace
}).allowed
```

## Image Object Structure

When using the `images` variable, each image object contains:

```yaml
# Image object fields
image.registry    # "docker.io"
image.name        # "library/nginx"
image.tag         # "1.21.0"
image.digest      # "sha256:abc123..."
image.reference   # Full image reference
```

## Safe Field Access Patterns

### Checking Field Existence

```yaml
# Always check if optional fields exist
has(object.metadata.labels) &&
has(object.metadata.labels.app)

# Use conditional access
has(object.spec.template) ?
  object.spec.template.metadata.labels['version'] : 'unknown'
```

### Handling Lists

```yaml
# Check if list exists and has items
has(object.spec.containers) &&
size(object.spec.containers) > 0

# Safe list operations
object.spec.containers.exists(c, c.name == 'main')
```

### Null Safety

```yaml
# Handle potentially null values
object.metadata.labels.orValue({})['app'] == 'myapp'

# Default values for missing fields
has(object.metadata.annotations.priority) ?
  int(object.metadata.annotations.priority) : 0
```

## Common Expression Patterns

### Resource Validation

```yaml
# Require specific labels
['app', 'version'].all(label,
  has(object.metadata.labels) &&
  has(object.metadata.labels[label]))

# Validate naming conventions
object.metadata.name.matches('^[a-z0-9]([-a-z0-9]*[a-z0-9])?$')
```

### Image Security

```yaml
# Block privileged containers
object.spec.containers.all(container,
  !has(container.securityContext) ||
  !has(container.securityContext.privileged) ||
  !container.securityContext.privileged)

# Require image scanning
images.all(image,
  has(image.registry) &&
  image.registry in ['secure-registry.com', 'internal-registry.local'])
```

### RBAC Integration

```yaml
# Combine authorization checks
authorizer.check({
  'resource': 'pods',
  'verb': 'create',
  'namespace': object.metadata.namespace
}).allowed && 'pod-creator' in request.roles
```

## Variable Availability by Policy Type

| Variable                  | ValidatingPolicy | ImageValidatingPolicy | MutatingPolicy | GeneratingPolicy | DeletingPolicy |
| ------------------------- | :--------------: | :-------------------: | :------------: | :--------------: | :------------: |
| `object`                  |        ✅        |          ❌           |       ✅       |        ✅        |       ✅       |
| `oldObject`               |   ✅ (updates)   |          ❌           |  ✅ (updates)  |        ❌        |       ✅       |
| `request`                 |        ✅        |          ✅           |       ✅       |        ✅        |       ✅       |
| `serviceAccountName`      |        ✅        |          ✅           |       ✅       |        ✅        |       ✅       |
| `serviceAccountNamespace` |        ✅        |          ✅           |       ✅       |        ✅        |       ✅       |
| `images`                  |        ✅        |          ✅           |       ✅       |        ✅        |       ❌       |
| `request.roles`           |        ✅        |          ✅           |       ✅       |        ✅        |       ✅       |
| `request.clusterRoles`    |        ✅        |          ✅           |       ✅       |        ✅        |       ✅       |
| `params`                  |        ✅        |          ✅           |       ✅       |        ✅        |       ✅       |
| `namespaceObject`         |        ✅        |          ✅           |       ✅       |        ✅        |       ✅       |
| `authorizer`              |        ✅        |          ✅           |       ✅       |        ✅        |       ✅       |

## Next Steps

- [CEL Expression Cookbook](../cookbook/) - Common patterns and examples
- [Policy Types Overview](../../policy-types/) - Learn about different policy types
- [Writing CEL Expressions](../writing-expressions/) - Best practices guide
- [Traditional Variables Documentation](../../policy-types/cluster-policy/variables/) - For JMESPath-based ClusterPolicy/Policy

## CEL vs Traditional Variables

CEL expressions use direct variable access (e.g., `serviceAccountName`) while traditional policies use JMESPath syntax (e.g., `{{ serviceAccountName }}`). The core variables are the same, but the syntax and some availability rules differ:

| Traditional Syntax                   | CEL Syntax             | Notes                           |
| ------------------------------------ | ---------------------- | ------------------------------- |
| `{{ serviceAccountName }}`           | `serviceAccountName`   | Direct access in CEL            |
| `{{ request.object.metadata.name }}` | `object.metadata.name` | No `request.` prefix needed     |
| `{{ images }}`                       | `images`               | Same variable, different syntax |
| `{{ request.roles }}`                | `request.roles`        | Consistent with request context |
