---
title: 'Troubleshooting CEL Expressions'
linkTitle: 'CEL Expression Troubleshooting'
weight: 100
description: >
  Troubleshooting and debugging guide for CEL expressions in Kyverno policies, including known issues and confirmed variable references.
---

# CEL Expressions Troubleshooting Guide

## Introduction

This guide helps debug and troubleshoot Common Expression Language (CEL) expressions in Kyverno policies, based on actual implementation details and real user issues from the Kyverno codebase.

## Verified CEL Variables

Based on the actual implementation, these are the **confirmed** CEL variables available:

### Core Variables (Always Available)

- `object` - The incoming Kubernetes resource
- `oldObject` - The existing object (null for CREATE operations)
- `request` - The admission request information

### Additional Variables (Implementation Status Verified)

- `namespaceObject` - Available in policies (confirmed in codebase)
- `authorizer` - **Limited availability** (GitHub issue #8021 shows partial implementation)
- `params` - Available when using parameterized policies

**Source**: Issues #8021, #11060, and ValidatingPolicy documentation

## Real Error Patterns (From GitHub Issues)

### 1. Variable Context Issues

**Error from Issue #11060:**

```
Creating configmaps in namespace '{{namespace}}' is not allowed
```

**Root Cause**: Variable syntax `{{ }}` doesn't work in CEL expressions.

**Verified Solution:**

```yaml
# Wrong - from actual failing example
validate:
  cel:
    expressions:
    - expression: "namespaceObject.metadata.name == '{{namespace}}'"

# Correct - working pattern
validate:
  cel:
    expressions:
    - expression: "namespaceObject.metadata.name == request.namespace"
```

### 2. CustomResource Matching Errors

**Error from Issue #10313:**

```
no unique match for kind MyCustomResource
```

**Root Cause**: CEL policies require explicit API group/version for CRDs.

**Verified Solution:**

```yaml
# Wrong - causes the error above
match:
  any:
  - resources:
      kinds:
      - MyCustomResource

# Correct - from issue resolution
match:
  any:
  - resources:
      kinds:
      - example.com/v1/MyCustomResource
```

### 3. CEL Expression Warnings

**From Issue #9605**: Currently, Kyverno doesn't block policy creation with CEL warnings due to ValidatingAdmissionPolicy variable bugs.

**Current Behavior**: Policies with CEL warnings are created but may not work as expected.

**Workaround**: Validate expressions manually before applying policies.

## Debugging Strategies (Verified Working)

### 1. Enable Debug Logging

**From Kyverno configuration documentation:**

```yaml
# Increase logging verbosity to see CEL evaluation
containers:
  - name: kyverno
    args:
      - -v=4 # Shows variable substitution details
```

### 2. Use dumpPayload for Request Inspection

**From troubleshooting documentation:**

```yaml
# Add to admission controller
containers:
  - name: kyverno
    args:
      - --dumpPayload=true # Shows full AdmissionReview content
```

**Note**: This has performance impact - remove after debugging.

### 3. Progressive Expression Testing

Start with simple expressions and build complexity:

```yaml
# Step 1: Basic existence check
expression: "has(object.spec)"

# Step 2: Add specific field
expression: "has(object.spec.containers)"

# Step 3: Add validation logic
expression: "has(object.spec.containers) && object.spec.containers.size() > 0"
```

## Known Limitations (From Codebase)

### 1. Variable Composition Status

**From Issue #8050**: Variable composition in CEL expressions is planned but implementation details are evolving.

**Current Status**: Basic variables work, but complex composition may have limitations.

### 2. Context Variable Access

**From Issue #11060**: Context variables from `apiCall` cannot be directly used in CEL expressions.

**Current Workaround**: Use preconditions with traditional variable syntax, then simple CEL validation.

### 3. Built-in Variable Coverage

**From Issue #11827**: Several Kyverno built-in variables don't have CEL equivalents yet:

- `serviceAccountName` - Must be extracted from `request.userInfo.username`
- `serviceAccountNamespace` - Must be parsed manually
- `images` - CEL implementation in progress

## Performance Considerations (From Codebase)

### 1. CEL Expression Caching

**From Issue #10754**: CEL expressions are compiled separately for each policy, even if identical.

**Current Impact**: Duplicate expressions across policies cause redundant compilation.

**Planned Improvement**: Expression caching and reuse (in development).

### 2. Webhook Timeouts

**From installation documentation:**

```yaml
spec:
  webhookConfiguration:
    timeoutSeconds: 30 # Default is 10s, max is 30s
```

**Recommendation**: Increase timeout for complex CEL expressions.

## Testing Strategies (Verified Working)

### 1. CLI Testing

**From Kyverno CLI documentation:**

```bash
# Test CEL policies before applying
kyverno apply policy.yaml --resource test-resource.yaml

# Validate policy syntax
kyverno validate policy.yaml
```

### 2. Dry-Run Validation

```bash
# Test against live cluster without applying
kubectl apply -f test-resource.yaml --dry-run=server
```

### 3. Policy Reports Analysis

```bash
# Check policy evaluation results
kubectl get polr -A
kubectl describe polr <policy-report-name>
```

## Common Workarounds (From Community)

### 1. Complex Variable Access

**Issue**: CEL can't access all context variables directly.

**Workaround** (from issue discussions):

```yaml
# Use preconditions for complex variable logic
preconditions:
  all:
    - key: '{{ request.userInfo.username }}'
      operator: NotEquals
      value: 'system:admin'
validate:
  cel:
    expressions:
      - expression: 'object.spec.replicas > 0' # Simple CEL validation
```

### 2. Resource Library Alternative

**Issue**: Resource library access in CEL expressions has limitations.

**Workaround**: Use traditional context with apiCall:

```yaml
context:
  - name: configmap
    configMap:
      name: allowed-values
      namespace: kyverno
validate:
  cel:
    expressions:
      - expression: "object.metadata.name != 'forbidden'" # Basic CEL check
```

## Safe CEL Patterns (Verified Working)

### 1. Basic Field Validation

```yaml
# Confirmed working pattern
validate:
  cel:
    expressions:
      - expression: 'has(object.metadata.labels.app)'
      - expression: 'object.spec.replicas >= 1'
      - expression: '!object.spec.containers.exists(c, has(c.securityContext.privileged) && c.securityContext.privileged)'
```

### 2. Namespace Object Access

```yaml
# Confirmed working (from CLI tests)
validate:
  cel:
    expressions:
      - expression: "namespaceObject.metadata.name != 'default'"
      - expression: 'has(namespaceObject.metadata.labels.environment)'
```

### 3. Request Information

```yaml
# Verified available fields
validate:
  cel:
    expressions:
      - expression: "request.operation == 'CREATE'"
      - expression: "request.userInfo.username != 'system:admin'"
```

## Current Implementation Status

### Fully Supported

- ✅ Basic object validation
- ✅ Simple field existence checks
- ✅ Namespace object access
- ✅ Request metadata access
- ✅ List operations (`all`, `exists`, `size`)

### Partially Supported

- ⚠️ Variable composition (basic cases work)
- ⚠️ Context variable access (limited)
- ⚠️ Resource library functions (some restrictions)

### In Development

- 🔄 CEL expression caching (Issue #10754)
- 🔄 Built-in variable parity (Issue #11827)
- 🔄 Enhanced context access (Issue #11060)

## Getting Help

When reporting CEL issues:

1. **Include Kyverno version**: Check with `kubectl get pods -n kyverno`
2. **Provide policy YAML**: Complete policy that reproduces the issue
3. **Share exact error**: From policy reports or admission controller logs
4. **Reference similar issues**: Check existing GitHub issues for patterns

**Useful Commands for Bug Reports:**

```bash
# Get admission controller logs
kubectl logs -n kyverno deployment/kyverno-admission-controller

# Get policy reports
kubectl get polr -A -o yaml

# Check policy status
kubectl describe cpol <policy-name>
```

## Related Resources

- **GitHub Issues**: [CEL-related issues](https://github.com/kyverno/kyverno/labels/validate.cel)
- **ValidatingPolicy Docs**: [Official API reference](https://kyverno.io/docs/policy-types/validating-policy/)
- **Community Slack**: #kyverno channel for real-time help
- **CLI Documentation**: [Testing policies](https://kyverno.io/docs/kyverno-cli/)

---

**Note**: This guide reflects the current implementation status. Features marked as "in development" may change. Always test policies in non-production environments first.
