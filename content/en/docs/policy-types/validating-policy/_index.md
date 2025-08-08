---
title: ValidatingPolicy
description: >
  ValidatingPolicy resources provide a way to create Kubernetes ValidatingAdmissionPolicies with enhanced Kyverno capabilities and optional auto-conversion for improved performance.
weight: 50
---

ValidatingPolicy is a namespaced policy type that enables creating [Kubernetes ValidatingAdmissionPolicies](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) with additional Kyverno capabilities. ValidatingPolicies support automatic conversion to native Kubernetes ValidatingAdmissionPolicies, providing significant performance improvements while maintaining Kyverno's advanced policy features.

## Overview

ValidatingPolicy combines the performance benefits of native Kubernetes ValidatingAdmissionPolicies with Kyverno's enhanced capabilities:

- **Native Performance**: Auto-conversion to ValidatingAdmissionPolicy provides up to 25% latency improvements and 80% CPU reductions
- **Enhanced CEL Libraries**: Extended CEL functions beyond standard Kubernetes capabilities
- **Background Scanning**: Policy evaluation outside of admission control
- **Advanced Binding**: Automatic binding generation and management
- **Lifecycle Management**: Integrated policy and resource lifecycle handling

## Auto-Conversion to ValidatingAdmissionPolicy

### Overview and Benefits

ValidatingPolicy supports automatic generation of Kubernetes ValidatingAdmissionPolicies, providing native API server performance while maintaining Kyverno's advanced policy features. This hybrid approach delivers significant performance improvements:

- **25% average latency improvement** across standard deployments
- **Up to 80% CPU reduction** in single-replica deployments  
- **44% faster response times** under heavy load scenarios
- **59% less memory usage** in multi-replica configurations

### How Auto-Conversion Works

When enabled, Kyverno automatically:

1. **Generates ValidatingAdmissionPolicy** with the same name as the source ValidatingPolicy
2. **Creates ValidatingAdmissionPolicyBinding** (source name + "-binding" suffix)  
3. **Manages lifecycle** of generated resources (creation, updates, deletion)
4. **Routes validation** through native Kubernetes API server instead of webhooks
5. **Maintains synchronization** between VPOL changes and generated VAP resources

The validation flow becomes:
```
Request → ValidatingAdmissionPolicy (in-process) → Allow/Deny
```

Instead of the traditional webhook approach:
```
Request → Webhook Call → Kyverno → Response → Allow/Deny
```

### Prerequisites

**Kubernetes Requirements:**
- Kubernetes 1.26+ with ValidatingAdmissionPolicy support
- Feature gates enabled: `ValidatingAdmissionPolicy=true` 
- API versions enabled based on cluster version:
  - `admissionregistration.k8s.io/v1` for K8s 1.30+
  - `admissionregistration.k8s.io/v1beta1` for K8s 1.28-1.29
  - `admissionregistration.k8s.io/v1alpha1` for K8s 1.26-1.27

**Kyverno Configuration:**

Enable auto-conversion in the admission controller:
```yaml
# Helm values or direct flag configuration
admissionController:
  container:
    extraArgs:
      - --generateValidatingAdmissionPolicy=true
```

Grant required RBAC permissions:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno:admission-controller:additional
rules:
- apiGroups: ["admissionregistration.k8s.io"]
  resources: ["validatingadmissionpolicies", "validatingadmissionpolicybindings"]
  verbs: ["create", "update", "delete", "list", "watch"]
```

### Configuration Examples

#### Basic Auto-Conversion

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: disallow-host-path
  namespace: default
spec:
  autogen:
    validatingAdmissionPolicy:
      enabled: true  # Enables VAP auto-conversion
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
    - apiGroups: ["apps"]
      apiVersions: ["v1"] 
      operations: ["CREATE", "UPDATE"]
      resources: ["deployments"]
  validations:
  - expression: |
      !has(object.spec.template.spec.volumes) || 
      object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))
    message: "HostPath volumes are not allowed"
```

#### Advanced Configuration with Variables

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: restrict-image-registries
  namespace: security-policies
spec:
  autogen:
    validatingAdmissionPolicy:
      enabled: true
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"] 
      resources: ["pods"]
  variables:
  - name: allowedRegistry
    expression: '"registry.company.com"'  # Simple string variable
  validations:
  - expression: |
      object.spec.containers.all(container, 
        container.image.startsWith(variables.allowedRegistry))
    messageExpression: |
      '"Image must be from allowed registry: " + variables.allowedRegistry + 
      ". Found: " + object.spec.containers.map(c, c.image).join(", ")'
```

### Generated Resource Structure

Auto-conversion produces two Kubernetes resources:

**Generated ValidatingAdmissionPolicy:**
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: disallow-host-path  # Same name as source ValidatingPolicy
  ownerReferences:          # Automatically managed by Kyverno
  - apiVersion: policies.kyverno.io/v1alpha1
    kind: ValidatingPolicy
    name: disallow-host-path
    uid: <source-policy-uid>
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups: ["apps"]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["deployments"]
  validations:
  - expression: |
      !has(object.spec.template.spec.volumes) || 
      object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))
    message: "HostPath volumes are not allowed"
```

**Generated ValidatingAdmissionPolicyBinding:**
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding  
metadata:
  name: disallow-host-path-binding  # Source name + "-binding"
  ownerReferences:
  - apiVersion: policies.kyverno.io/v1alpha1
    kind: ValidatingPolicy
    name: disallow-host-path
    uid: <source-policy-uid>
spec:
  policyName: disallow-host-path
  validationActions: [Deny]
  matchResources:
    resourceRules:
    - apiGroups: ["apps"]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["deployments"]
```

### Monitoring Auto-Conversion Status

Check auto-conversion status and generated resources:

```bash
# Verify ValidatingPolicy status
kubectl get validatingpolicy disallow-host-path -o jsonpath='{.status.autogen.validatingAdmissionPolicy}'

# List generated ValidatingAdmissionPolicy resources
kubectl get validatingadmissionpolicy

# List generated ValidatingAdmissionPolicyBinding resources  
kubectl get validatingadmissionpolicybinding

# Check detailed status information
kubectl describe validatingpolicy disallow-host-path

# Monitor policy-related events
kubectl get events --field-selector involvedObject.kind=ValidatingPolicy
```

### Performance Benefits

#### Benchmark Results

Kyverno 1.15 performance testing demonstrates significant improvements when using ValidatingPolicy with auto-conversion:

**Heavy Load Scenarios (500 virtual users, 10,000 iterations):**
- **44% faster latency** in single-replica deployments
- **59% less memory usage** in multi-replica configurations
- **48% lower CPU consumption** under medium load

**Standard Production Workloads:**
- **25% average latency improvement** across all operations
- **Up to 80% CPU reduction** in optimized deployments
- **Consistent performance gains** across cluster sizes

#### Architecture Benefits

**Native Execution Path:**
```
ValidatingPolicy → ValidatingAdmissionPolicy → Kubernetes API server (in-process validation)
```

**Performance Impact:**
- Eliminated network roundtrip latency
- Reduced memory allocation overhead  
- Improved CPU efficiency through native processing
- Enhanced reliability through in-process validation

### Limitations and Considerations

#### Feature Compatibility

Auto-conversion works with basic CEL expressions and standard Kubernetes resources. The following features require ValidatingPolicy enforcement and cannot be converted:

**Incompatible Features:**
- Kyverno-specific CEL libraries (`Resource`, `HTTP`, `GlobalContext`, `User`, `Image`)
- Complex external data integrations
- Policies requiring background processing beyond admission control
- Advanced variable expressions using external data sources

#### Generation Conditions

Auto-conversion is automatically skipped when:
- Policy uses incompatible Kyverno-specific features
- Pod controller autogen conflicts with VAP generation (use one or the other)
- CEL expressions cannot be translated to native Kubernetes CEL
- Required Kubernetes API versions are not available in the cluster

### Troubleshooting Common Issues

#### Issue: Auto-Conversion Enabled but No VAP Generated

**Symptoms:**
```bash
kubectl get validatingadmissionpolicy
# No matching resources found
```

**Diagnosis:**
```bash
# Check ValidatingPolicy status for conversion details
kubectl get validatingpolicy <policy-name> -o jsonpath='{.status.autogen.validatingAdmissionPolicy.message}'
```

**Common Causes:**
- Conflicting pod controller autogen configuration
- Policy uses incompatible CEL features
- Missing required RBAC permissions
- Kubernetes API version incompatibility

**Solution:**
1. Verify autogen configuration (use either VAP OR pod controller autogen)
2. Check policy CEL expressions for Kyverno-specific features
3. Ensure admission controller has VAP RBAC permissions
4. Verify Kubernetes cluster supports required API versions

#### Issue: Permission Denied Creating ValidatingAdmissionPolicy

**Symptoms:**
```
Error: admission controller cannot create ValidatingAdmissionPolicy: forbidden
```

**Solution:**
Add required RBAC permissions to Kyverno admission controller:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno:admission-controller:vap
rules:
- apiGroups: ["admissionregistration.k8s.io"]
  resources: ["validatingadmissionpolicies", "validatingadmissionpolicybindings"]
  verbs: ["create", "update", "delete", "list", "watch"]
```

#### Issue: ValidatingAdmissionPolicy Not Enforcing Policies

**Diagnosis:**
```bash
# Verify both VAP and binding exist
kubectl get validatingadmissionpolicy,validatingadmissionpolicybinding

# Check binding configuration
kubectl get validatingadmissionpolicybinding <policy-name>-binding -o yaml
```

**Common Causes:**
- Missing ValidatingAdmissionPolicyBinding
- Incorrect binding configuration
- Policy not matching intended resources

**Solution:**
1. Verify both VAP and VAPB resources were created
2. Check binding `matchResources` configuration
3. Ensure policy `matchConstraints` are correctly defined

#### Issue: Feature Gate Not Enabled

**Symptoms:**
```
ValidatingAdmissionPolicy resources not available in cluster
```

**Solution:**
Enable ValidatingAdmissionPolicy feature gate in Kubernetes:
```yaml
# For kube-apiserver
--feature-gates=ValidatingAdmissionPolicy=true
```

## Schema Definition

ValidatingPolicy uses the same field structure as Kubernetes ValidatingAdmissionPolicy with additional Kyverno enhancements:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: policy-name
  namespace: policy-namespace
spec:
  # Auto-generation configuration
  autogen:
    validatingAdmissionPolicy:
      enabled: boolean  # Enable VAP auto-conversion
    podControllers:     # Alternative to VAP conversion
      controllers: [string]
      
  # Policy evaluation settings
  evaluation:
    background:
      enabled: boolean
      skipResourceFilters: [string]
      
  # Standard ValidatingAdmissionPolicy fields
  validationActions: [string]
  matchConstraints:
    resourceRules: [object]
    excludeResourceRules: [object]
    matchPolicy: string
    namespaceSelector: object
    objectSelector: object
    
  variables: [object]
  validations: [object]
  failurePolicy: string
  auditAnnotations: [object]
  matchConditions: [object]
```

## Migration from ClusterPolicy

### Migration Benefits

Migrating from ClusterPolicy to ValidatingPolicy with auto-conversion provides:
- **Performance improvements**: 25% average latency reduction
- **Native Kubernetes integration**: Direct API server processing
- **Reduced resource consumption**: Lower CPU and memory usage
- **Enhanced policy capabilities**: Extended CEL libraries and background scanning

### Step-by-Step Migration

#### Phase 1: Assessment
1. **Inventory existing policies**:
   ```bash
   kubectl get clusterpolicy -o name
   ```

2. **Identify conversion candidates**:
   - Validation-only policies (no mutate/generate rules)
   - Policies using basic CEL expressions
   - Policies not requiring background processing

3. **Plan migration timeline** with testing phases

#### Phase 2: Preparation  
1. **Upgrade to Kyverno 1.15+**
2. **Configure VAP prerequisites** in Kubernetes cluster
3. **Set up monitoring** for conversion process

#### Phase 3: Conversion
1. **Create ValidatingPolicy equivalents** for selected ClusterPolicies
2. **Enable auto-conversion selectively** for testing
3. **Verify generated VAP resources** are created correctly
4. **Monitor policy enforcement** behavior during transition

#### Phase 4: Validation
1. **Test policy enforcement** with auto-conversion enabled
2. **Compare performance metrics** before and after conversion
3. **Validate equivalent functionality** across all use cases
4. **Plan rollback procedures** if needed

### Example Migration

**Original ClusterPolicy:**
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: check-privileged
    match:
      resources:
        kinds: [Pod]
    validate:
      cel:
        expressions:
        - expression: "!has(object.spec.securityContext.privileged) || !object.spec.securityContext.privileged"
          message: "Privileged containers are not allowed"
```

**Converted ValidatingPolicy:**
```yaml  
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: disallow-privileged
  namespace: kyverno  # Now namespaced
spec:
  autogen:
    validatingAdmissionPolicy:
      enabled: true  # Enable auto-conversion
  validationActions: [Deny]  # Replaces validationFailureAction
  evaluation:
    background:
      enabled: true  # Maintains background scanning
  matchConstraints:
    resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["pods"]
  validations:  # Direct conversion from CEL expressions
  - expression: "!has(object.spec.securityContext.privileged) || !object.spec.securityContext.privileged"
    message: "Privileged containers are not allowed"
```

## Best Practices

### When to Use Auto-Conversion

**Recommended Use Cases:**
- High-throughput admission validation
- Performance-critical policy enforcement
- Policies using standard Kubernetes resources
- Simple to moderate CEL expression complexity

**Alternative Approaches:**
- Use ClusterPolicy for complex mutation/generation rules
- Use ValidatingPolicy without auto-conversion for Kyverno-specific features
- Use standard ValidatingAdmissionPolicy for simple, native-only policies

### Policy Design Guidelines

1. **Keep expressions simple** for better conversion compatibility
2. **Use standard Kubernetes CEL libraries** when possible
3. **Test auto-conversion** in development environments first
4. **Monitor performance impact** after enabling conversion
5. **Plan rollback strategies** for production deployments

## Examples

### Resource Validation
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: require-resource-limits
  namespace: default
spec:
  autogen:
    validatingAdmissionPolicy:
      enabled: true
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["pods"]
  validations:
  - expression: |
      object.spec.containers.all(container,
        has(container.resources.limits.memory) && 
        has(container.resources.limits.cpu))
    message: "All containers must have CPU and memory limits"
```

### Label Enforcement
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: require-team-label
  namespace: production
spec:
  autogen:
    validatingAdmissionPolicy:
      enabled: true
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
    - apiGroups: ["apps"]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["deployments", "statefulsets", "daemonsets"]
  validations:
  - expression: |
      has(object.metadata.labels.team) && 
      object.metadata.labels.team != ""
    message: "Resources must have a non-empty 'team' label"
```

### Multi-Resource Validation
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: enforce-security-standards
  namespace: security-policies
spec:
  autogen:
    validatingAdmissionPolicy:
      enabled: true
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["pods"]
    - apiGroups: ["apps"]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["deployments", "statefulsets"]
  validations:
  - expression: |
      (object.kind == "Pod" && 
       (!has(object.spec.securityContext.runAsRoot) || 
        !object.spec.securityContext.runAsRoot)) ||
      (object.kind != "Pod" && 
       (!has(object.spec.template.spec.securityContext.runAsRoot) || 
        !object.spec.template.spec.securityContext.runAsRoot))
    message: "Containers must not run as root"
```

## Further Reading

- [Kubernetes ValidatingAdmissionPolicy Documentation](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/)
- [Kyverno 1.15 Release Notes](https://kyverno.io/blog/2025/07/31/announcing-kyverno-release-1.15/)
- [CEL Language Guide](https://github.com/google/cel-spec/blob/master/doc/langdef.md)
- [Kyverno Performance Benchmarks](https://kyverno.io/docs/monitoring/)