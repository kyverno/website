---
date: 2025-07-31
title: Announcing Kyverno Release 1.15!
tags:
  - Releases
excerpt: Kyverno 1.15 makes policy management more modular, streamlined, and powerful.
draft: false
---

# Announcing Kyverno Release 1.15!

Kyverno 1.15 makes Kubernetes policy management more powerful, extensible, and easier to use.

We are thrilled to announce the release of Kyverno 1.15.0, continuing our mission to make policy management in Kubernetes environments more modular, performant, and user-friendly. This release introduces new capabilities across multiple policy types, enhances testing and CLI functionality, and brings many improvements contributed by a vibrant community.

#### TL;DR

- **New MutatingPolicy** for dynamic resource transformation with native Kubernetes integration
- **New GeneratingPolicy** for intelligent resource creation and synchronization using CEL expressions
- **New DeletingPolicy resource** for controlled cleanup of Kubernetes resources
- **Advanced CEL functions** and enhanced policy exception support for fine-grained control
- **Community milestone**: over 850 changes merged from 70+ contributors, including many first-timers!

### New Policy Types

Building on the foundation of ValidatingPolicy and ImageValidatingPolicy from previous releases, Kyverno 1.15 introduces three new CEL-based policy types that complete our comprehensive policy ecosystem. While Kyverno maintains its traditional policy engine capabilities, these new policy types provide native Kubernetes integration by automatically converting to Kubernetes admission controllers - MutatingPolicy converts to MutatingAdmissionPolicy (MAP) and ValidatingPolicy converts to ValidatingAdmissionPolicy (VAP). This hybrid approach gives users the flexibility to choose between Kyverno's rich policy engine features and native Kubernetes performance.

#### MutatingPolicy: Flexible Resource Transformation

The new MutatingPolicy type provides native Kubernetes integration through MutatingAdmissionPolicy, offering:

- Full support for all functions that a mutate rule of a tradition policy supports
- Easier foreach loop iteration with CEL's `map()` and `filter()` functions
- Full support of advanced custom CEL libraries for complex policy logic
- CLI support for offline resources mutation in CI/CD pipelines

##### Before & After: ClusterPolicy Mutate vs MutatingPolicy

Here is an example of adding default labels to deployments.

Previous `ClusterPolicy` approach:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-default-labels
spec:
  rules:
    - name: add-labels
      match:
        resources:
          kinds:
            - Deployment
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              environment: 'production'
              managed-by: 'kyverno'
```

New `MutatingPolicy` approach:

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-default-labels
spec:
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                environment: "production",
                managed-by: "kyverno"
              }
            }
          }
  matchConstraints:
    resourceRules:
      - apiGroups: ['apps']
        apiVersions: ['v1']
        resources: ['deployments']
        operations: ['CREATE', 'UPDATE']
```

##### MutatingAdmissionPolicy Generation

This release enhances policy flexibility with the ability to automatically generate Kubernetes `MutatingAdmissionPolicies` from `MutatingPolicies`, enabling mutations to be performed directly by the Kubernetes API server rather than the Kyverno admission controller. This capability improves performance and resilience by leveraging native Kubernetes mutation while maintaining the rich feature set and ease of use provided by Kyverno.

##### Comparison with MutatingAdmissionPolicy

The table below compares major features across the Kubernetes `MutatingAdmissionPolicy` and Kyverno `MutatingPolicy` types.

| Feature            | MutatingAdmissionPolicy | MutatingPolicy                             |
| ------------------ | ----------------------- | ------------------------------------------ |
| Enforcement        | Admission               | Admission, Background, Pipelines, ...      |
| Payloads           | Kubernetes              | Kubernetes                                 |
| Distribution       | Kubernetes              | Helm, CLI, Web Service, API, SDK           |
| CEL Library        | Basic                   | Extended                                   |
| Bindings           | Manual                  | Automatic                                  |
| Auto-generation    | \-                      | Pod Controllers, MutatingAdmissionPolicy   |
| External Data      | \-                      | Kubernetes resources or API calls          |
| Caching            | \-                      | Global Context, image verification results |
| Background scans   | \-                      | Periodic, On policy creation or change     |
| Exceptions         | \-                      | Fine-grained exceptions                    |
| Reporting          | \-                      | Policy WG Reports API                      |
| Testing            | \-                      | Kyverno CLI (unit), Chainsaw (e2e)         |
| Existing Resources | \-                      | Background mutation support                |

#### GeneratingPolicy: Intelligent Resource Creation

The new GeneratingPolicy type provides enhanced integration through CEL expressions, offering:

- **CEL-First Approach**: Define generation logic using Common Expression Language for improved flexibility and expressiveness
- **Enhanced Expressiveness**: Leverage CEL's powerful functions for complex generation scenarios
- **Kyverno CEL Libraries**: Access to Kyverno's extensive custom CEL libraries for advanced resource manipulation and generation
- **Built-in Looping Support**: Native CEL looping capabilities for generating resources across multiple namespaces or items

For example, the following policy automatically clones an image pull secret from the default namespace into any newly created Namespace:

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: clone-image-pull-secret
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['namespaces']
  variables:
    - name: targetNs
      expression: 'object.metadata.name'
    - name: sourceSecret
      expression: resource.Get("v1", "secrets", "default", "regcred")
  generate:
    - expression: generator.Apply(variables.targetNs, [variables.sourceSecret])
```

This policy demonstrates how GeneratingPolicy provides the same core functionality as Kyverno's generate rules, but with a CEL-first approach for improved flexibility and consistency with other Kyverno policy types.

#### DeletingPolicy: Controlled Cleanup Made Easy

As Kyverno evolves, managing the full lifecycle of Kubernetes resources through policies becomes essential. The new DeletingPolicy CRD empowers administrators to declaratively control how resources are cleaned up or cascaded when no longer needed. This complements existing Mutating and Validating policies by closing the resource lifecycle loop with safe, policy-driven deletion.

The DeletingPolicy provides the same functionality as the CleanupPolicy but it is designed to use CEL expressions for Kubernetes compatibility.

Unlike admission policies that react to API requests, DeletingPolicy:

- Runs periodically at scheduled times
- Evaluates existing resources in the cluster
- Deletes resources when matching rules and conditions are satisfied

Here's an example that automatically deletes old test pods:

```yaml
apiVersion: policies.kyverno.io/v1
kind: DeletingPolicy
metadata:
  name: cleanup-old-test-pods
spec:
  schedule: '0 1 * * *' # Run daily at 1 AM
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['*']
        resources: ['pods']
        scope: 'Namespaced'
    namespaceSelector:
      matchLabels:
        environment: test
  conditions:
    - name: isOld
      expression: "now() - object.metadata.creationTimestamp > duration('72h')"
  variables:
    - name: isEphemeral
      expression: "has(object.metadata.labels.ephermal) && object.metadata.labels.ephemeral == 'true'"
```

This policy automatically deletes pods that are:

- Located in namespaces labeled `environment: test`
- Are older than 72 hours
- Runs daily at 1 AM using a cron schedule

### Pod Security Standard(PSS) Policy Performance: ClusterPolicy vs ValidatingPolicy

Our performance testing reveals significant improvements when using ValidatingPolicy (vpol) over traditional ClusterPolicy (cpol) for Pod Security Standards (PSS) enforcement.

| replicas | # policies | Rule Type        | Mode    | Subject | Virtual Users/Iterations | Latency (avg/max)  | Memory (max) | CPU (max) | Memory Limit    |
| -------- | ---------- | ---------------- | ------- | ------- | ------------------------ | ------------------ | ------------ | --------- | --------------- |
| 1        | 17         | Validate         | Enforce | Pods    | 100/1,000                | 37.71ms / 110.53ms | 152Mi        | 548m      | 384Mi (default) |
| 1        | 17         | Validate         | Enforce | Pods    | 200/5,000                | 80.74ms / 409.35ms | 182Mi        | 2885m     | 384Mi (default) |
| 1        | 17         | Validate         | Enforce | Pods    | 500/10,000               | 92.73ms / 3.15s    | 143Mi        | 3033m     | 512Mi           |
| 3        | 17         | Validate         | Enforce | Pods    | 100/1,000                | 32.89ms / 121.19ms | 104Mi        | 262m      | 384Mi (default) |
| 3        | 17         | Validate         | Enforce | Pods    | 200/5,000                | 60.06ms / 1.01s    | 117Mi        | 1067m     | 384Mi (default) |
| 3        | 17         | Validate         | Enforce | Pods    | 500/10,000               | 151.97ms / 3.17s   | 107Mi        | 1182m     | 512Mi           |
| 1        | 16         | ValidatingPolicy | Deny    | Pods    | 100/1,000                | 28.3ms / 108.36ms  | 142Mi        | 108m      | 384Mi (default) |
| 1        | 16         | ValidatingPolicy | Deny    | Pods    | 200/5,000                | 54.87ms / 346.74ms | 211Mi        | 2339m     | 384Mi (default) |
| 1        | 16         | ValidatingPolicy | Deny    | Pods    | 500/10,000               | 133.67ms / 1.63s   | 163Mi        | 4123m     | 512Mi           |
| 3        | 16         | ValidatingPolicy | Deny    | Pods    | 100/1,000                | 24.87ms / 59.37ms  | 129Mi        | 135m      | 384Mi (default) |
| 3        | 16         | ValidatingPolicy | Deny    | Pods    | 200/5,000                | 45.97ms / 1.12s    | 159Mi        | 554m      | 384Mi (default) |
| 3        | 16         | ValidatingPolicy | Deny    | Pods    | 500/10,000               | 114.01ms / 3.28s   | 170Mi        | 810m      | 512Mi           |

#### Key Performance Improvements

**Under Heavy Load (500/10,000 iterations):**

- **44% faster latency** in single-replica deployments
- **59% less memory usage** in multi-replica deployments
- **48% lower CPU consumption** in medium load scenarios

**Across All Load Conditions:**

- **25% average latency improvement**
- **Up to 80% CPU reduction** in single-replica deployments
- **Consistent performance gains** under all tested scenarios

#### Why It Matters

ValidatingPolicy's native Kubernetes integration delivers superior performance while maintaining the same security posture. The improvements are most pronounced under heavy load conditions, making it ideal for production environments with frequent policy enforcement.

**For standard deployments**: Even in typical workloads, ValidatingPolicy shows 25% average latency improvement and up to 80% CPU reduction, providing immediate benefits for most Kubernetes environments.

**For large-scale clusters**: The performance gains scale dramatically under heavy load, with 44% faster latency and 59% less memory usage, making it essential for high-traffic production environments.

The performance gains translate directly to reduced infrastructure costs and improved cluster stability, providing a clear upgrade path from traditional ClusterPolicy implementations.

### New OpenReports API Group Support

Kyverno 1.15 introduces support for the new OpenReports API group (`openreports.io`) for PolicyReport resources. This standardization aligns with the broader Kubernetes policy ecosystem and provides a more robust foundation for policy reporting across the community.

**What's New:**

- **Kyverno**: Now generates PolicyReports using the new API group
- **Reports Server**: Updated to consume and serve reports from the new API group
- **Policy Reporter**: Enhanced to visualize and manage reports from the new API group

**Migration Path:**
The legacy API group (`wgpolicyk8s.io`) will be deprecated in future releases. Users are encouraged to update their tooling and integrations to use the new API group for continued support and enhanced functionality.

**Benefits:**

- Improved integration with the broader Kubernetes policy ecosystem
- Long-term support and community alignment

### Community & Contributions

This release is a testament to our growing community. We continue to see more changes made by our open source community contributors—many of whom made their first Kyverno contribution in this cycle! We want to thank everyone who shared feedback, bug reports, and code contributions helping Kyverno thrive.

### Getting Started

Upgrade with Helm:

```bash
helm repo update
helm upgrade kyverno kyverno/kyverno -n kyverno --version v1.15.0
```

Kyverno 1.15 remains fully backward compatible with existing ClusterPolicy resources. You can adopt new policy types at your own pace while continuing to benefit from your existing policies.

### What's Next?

Our roadmap continues with plans to:

- Expand cross-cutting features like event logging and metrics
- Support namespaced versions of all CEL-based policy types
- Implement fine-grained policy exceptions for enhanced control
- Publish Kyverno engine API and SDK for broader ecosystem integration

### Conclusion

Kyverno 1.15.0 represents a major milestone in policy management, introducing three powerful new CEL-based policy types that provide enhanced integration while maintaining Kyverno's rich feature set. With enhanced CLI capabilities, and a thriving contributor community, Kyverno is now more powerful, flexible, and user-friendly than ever before.

Explore the full release notes on GitHub, try the new features, and join our community to help shape the future of policy enforcement! For more details, visit [kyverno.io](https://kyverno.io).

Thank you to everyone who contributed and supported this release. Together, we're building a safer, more manageable ecosystem.

— The Kyverno Team
