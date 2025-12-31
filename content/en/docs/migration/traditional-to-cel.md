---
title: Migrating from Traditional Policies to CEL
linkTitle: Traditional to CEL
weight: 10
description: Complete guide for migrating from pattern/deny-based policies to CEL-based ValidatingPolicy
---

# Migrating from Traditional Policies to CEL-based ValidatingPolicy

This guide helps you migrate from traditional Kyverno ClusterPolicy/Policy resources using `validate.pattern` or `validate.deny` to the new CEL-based ValidatingPolicy introduced in Kyverno v1.14.

## Why Migrate to CEL-based Policies?

CEL-based ValidatingPolicy offers significant advantages over traditional policies:

- **Performance**: 25% average latency improvement and up to 80% CPU reduction
- **Kubernetes Native**: Can generate native ValidatingAdmissionPolicies automatically
- **Expressiveness**: More powerful and flexible validation logic
- **Future-Ready**: CEL is the strategic direction for Kubernetes policy validation

## Understanding the Differences

### Traditional ClusterPolicy Structure
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
      message: "Required labels missing"
      pattern:
        metadata:
          labels:
            app: "?*"
            version: "?*"
```

### New ValidatingPolicy Structure
```yaml
apiVersion: kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: require-labels
spec:
  validationActions: [Enforce]
  rules:
  - name: check-labels
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      cel:
        expressions:
        - expression: "has(object.metadata.labels.app) && has(object.metadata.labels.version)"
          message: "Required labels 'app' and 'version' are missing"
```

## Step-by-Step Migration Process

### Step 1: Identify Migration Candidates

Start with policies that use:
- Simple `validate.pattern` rules
- Basic `validate.deny` conditions  
- Resource field validation
- Label/annotation requirements

**Not suitable for immediate migration:**
- Policies using `mutate`, `generate`, or `verifyImages` rules
- Complex JMESPath expressions requiring external data
- Policies requiring Kyverno-specific features like policy exceptions

### Step 2: Convert Validation Logic

#### Pattern-based to CEL Conversion

**Traditional Pattern:**
```yaml
validate:
  pattern:
    spec:
      containers:
      - name: "*"
        image: "!*:latest"
```

**CEL Equivalent:**
```yaml
validate:
  cel:
    expressions:
    - expression: "object.spec.containers.all(container, !container.image.endsWith(':latest'))"
      message: "Container images must not use 'latest' tag"
```

#### Deny-based to CEL Conversion

**Traditional Deny:**
```yaml
validate:
  deny:
    conditions:
      all:
      - key: "{{ request.object.spec.replicas }}"
        operator: GreaterThan
        value: 10
  message: "Replica count cannot exceed 10"
```

**CEL Equivalent:**
```yaml
validate:
  cel:
    expressions:
    - expression: "object.spec.replicas <= 10"
      message: "Replica count cannot exceed 10"
```

### Step 3: Handle Variable Translation

#### Built-in Variable Mapping

| Traditional Kyverno | CEL Equivalent | Description |
|---------------------|----------------|-------------|
| `{{ request.object }}` | `object` | The resource being validated |
| `{{ request.oldObject }}` | `oldObject` | Previous version (for updates) |
| `{{ request.operation }}` | `request.operation` | Operation type (CREATE, UPDATE, DELETE) |
| `{{ serviceAccountName }}` | `request.userInfo.username` | Service account name |
| `{{ request.namespace }}` | `object.metadata.namespace` | Resource namespace |

#### Example Variable Migration

**Traditional:**
```yaml
validate:
  deny:
    conditions:
      any:
      - key: "{{ request.operation }}"
        operator: Equals
        value: "CREATE"
      - key: "{{ request.object.metadata.namespace }}"
        operator: Equals
        value: "kube-system"
```

**CEL:**
```yaml
validate:
  cel:
    expressions:
    - expression: "!(request.operation == 'CREATE' && object.metadata.namespace == 'kube-system')"
      message: "Cannot create resources in kube-system namespace"
```

## Common Migration Patterns

### 1. Required Fields Validation

**Traditional:**
```yaml
validate:
  pattern:
    metadata:
      labels:
        app: "?*"
        environment: "production|staging|development"
```

**CEL:**
```yaml
validate:
  cel:
    expressions:
    - expression: "has(object.metadata.labels.app)"
      message: "Label 'app' is required"
    - expression: "object.metadata.labels.environment in ['production', 'staging', 'development']"
      message: "Label 'environment' must be one of: production, staging, development"
```

### 2. Resource Limits Validation

**Traditional:**
```yaml
validate:
  pattern:
    spec:
      containers:
      - name: "*"
        resources:
          limits:
            memory: "?*"
            cpu: "?*"
```

**CEL:**
```yaml
validate:
  cel:
    expressions:
    - expression: |
        object.spec.containers.all(container,
          has(container.resources.limits.memory) && has(container.resources.limits.cpu)
        )
      message: "All containers must specify CPU and memory limits"
```

### 3. Conditional Validation

**Traditional:**
```yaml
validate:
  deny:
    conditions:
      all:
      - key: "{{ request.object.spec.containers[].securityContext.privileged || `false` }}"
        operator: Equals
        value: true
      - key: "{{ request.object.metadata.namespace }}"
        operator: NotEquals
        value: "kube-system"
```

**CEL:**
```yaml
validate:
  cel:
    expressions:
    - expression: |
        !(object.spec.containers.exists(container, 
          has(container.securityContext.privileged) && 
          container.securityContext.privileged == true
        ) && object.metadata.namespace != 'kube-system')
      message: "Privileged containers not allowed outside kube-system namespace"
```

## Advanced Migration Scenarios

### Working with Lists and Arrays

**Traditional (using foreach):**
```yaml
validate:
  foreach:
  - list: "request.object.spec.containers"
    deny:
      conditions:
        any:
        - key: "{{ element.image }}"
          operator: AnyIn
          value: ["nginx:latest", "redis:latest"]
```

**CEL:**
```yaml
validate:
  cel:
    expressions:
    - expression: "!object.spec.containers.exists(container, container.image in ['nginx:latest', 'redis:latest'])"
      message: "Containers cannot use latest tags for nginx or redis"
```

### Complex Object Validation

**Traditional:**
```yaml
validate:
  pattern:
    spec:
      template:
        spec:
          containers:
          - name: "*"
            env:
            - name: "DATABASE_URL"
              valueFrom:
                secretKeyRef:
                  name: "?*"
```

**CEL:**
```yaml
validate:
  cel:
    expressions:
    - expression: |
        object.spec.template.spec.containers.all(container,
          !container.env.exists(envVar, 
            envVar.name == 'DATABASE_URL' && 
            (!has(envVar.valueFrom) || !has(envVar.valueFrom.secretKeyRef))
          )
        )
      message: "DATABASE_URL must be sourced from a secret"
```

## Testing Your Migration

### 1. Validate CEL Expressions

Use the Kyverno CLI to test your CEL expressions:

```bash
# Test with a sample resource
kyverno apply validating-policy.yaml --resource test-pod.yaml
```

### 2. Side-by-Side Testing

Deploy both policies in different namespaces temporarily:

```yaml
# Test traditional policy in namespace 'old-policy-test'
# Test CEL policy in namespace 'cel-policy-test'
# Compare results with identical resources
```

### 3. Use Policy Reports

Monitor policy reports to ensure equivalent behavior:

```bash
kubectl get polr -n test-namespace -o yaml
```

## Performance Considerations

### CEL Expression Optimization

**Avoid:**
```yaml
# Inefficient: Multiple separate validations
expressions:
- expression: "has(object.metadata.labels.app)"
- expression: "has(object.metadata.labels.version)"  
- expression: "has(object.metadata.labels.environment)"
```

**Prefer:**
```yaml
# Efficient: Combined validation
expressions:
- expression: |
    ['app', 'version', 'environment'].all(label, 
      has(object.metadata.labels[label])
    )
  message: "Required labels: app, version, environment"
```

### ValidatingAdmissionPolicy Generation

Enable automatic generation for optimal performance:

```yaml
apiVersion: kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: efficient-policy
  annotations:
    policies.kyverno.io/generate-validating-admission-policy: "true"
spec:
  # ... policy rules
```

## Migration Checklist

- [ ] **Identify suitable policies** for CEL migration
- [ ] **Convert validation logic** from pattern/deny to CEL expressions
- [ ] **Update variable references** to CEL syntax
- [ ] **Test CEL expressions** with sample resources
- [ ] **Validate behavior** matches original policy
- [ ] **Enable ValidatingAdmissionPolicy generation** if appropriate
- [ ] **Monitor performance** improvements
- [ ] **Update documentation** and runbooks
- [ ] **Train team** on CEL syntax and debugging

## Troubleshooting Common Issues

### CEL Expression Errors

**Error:** `unknown field 'nonexistent'`
**Solution:** Use `has()` function to check field existence:
```yaml
expression: "has(object.spec.nonexistent) && object.spec.nonexistent == 'value'"
```

**Error:** `index out of bounds`
**Solution:** Check array length before accessing:
```yaml
expression: "size(object.spec.containers) > 0 && object.spec.containers[0].image != 'bad'"
```

### Variable Migration Issues

**Issue:** Traditional variables not working in CEL
**Solution:** Use CEL built-in variables or resource library:
```yaml
# Instead of {{ request.object.metadata.name }}
expression: "object.metadata.name"

# For external data, use resource library
expression: "resource.get('v1', 'ConfigMap', 'default', 'my-config') != null"
```

## Next Steps

After successfully migrating to ValidatingPolicy:

1. **Explore ImageValidatingPolicy** for supply chain security
2. **Consider MutatingPolicy** for resource modifications (v1.15+)
3. **Implement policy exceptions** using CEL expressions
4. **Set up monitoring** for policy performance and compliance

## Additional Resources

- [CEL Language Specification](https://github.com/google/cel-spec)
- [Kyverno CEL Functions Reference](/docs/writing-policies/cel/)
- [ValidatingPolicy API Reference](/docs/policy-types/validating-policy/)
- [Kyverno CLI Testing Guide](/docs/kyverno-cli/usage/test/)

---

> **Note**: This migration guide focuses on ValidatingPolicy. For mutate, generate, or verifyImages rules, continue using ClusterPolicy until MutatingPolicy, GeneratingPolicy, and ImageValidatingPolicy meet your specific requirements.