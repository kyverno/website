---
title: Overview
description: >-
  Kyverno Policy Types - CEL-based and Traditional
sidebar:
  order: 1
---

Kyverno offers multiple policy types to secure, automate, and operate your Kubernetes infrastructure.

## CEL-based Policies (Recommended)

**CEL-based policies** (v1beta1) use the Common Expression Language (CEL) and are aligned with Kubernetes' native ValidatingAdmissionPolicy.

### Advantages

- **Performance**: Faster latency and reduced CPU usage.
- **K8s Native**: Generates native ValidatingAdmissionPolicy and MutatingAdmissionPolicy.
- **Expressiveness**: Flexible logic using CEL.

### Policy Types

| Type | Purpose |
|------|---------|
| [ValidatingPolicy](/docs/policy-types/validating-policy) | Validate resources or JSON payloads |
| [MutatingPolicy](/docs/policy-types/mutating-policy) | Mutate new or existing resources |
| [GeneratingPolicy](/docs/policy-types/generating-policy) | Create or clone resources |
| [DeletingPolicy](/docs/policy-types/deleting-policy) | Delete resources on a schedule |
| [ImageValidatingPolicy](/docs/policy-types/image-validating-policy) | Verify container image signatures |

All types support both cluster-scoped (e.g., `ValidatingPolicy`) and namespace-scoped (e.g., `NamespacedValidatingPolicy`) variants.

### Roadmap

- **v1.14**: Initial alpha (Validating/ImageValidating)
- **v1.15**: Alpha extension (Mutating/Generating/Deleting)
- **v1.16**: Beta promotion (v1beta1)
- **v1.17**: v1 API (Planned)

## Traditional Policies (Legacy)

**ClusterPolicy/Policy** resources use YAML patterns and JMESPath. They remain fully supported but are recommended primarily for existing deployments or simple pattern matching.

:::note[Migration]
Existing policies do not need immediate migration. For new policies, we recommend the CEL-based format. See the [Migration Guide](/docs/migration/traditional-to-cel).
:::

| Task | Traditional Policy Field |
|------|--------------------------|
| Validate | `validate` rule |
| Mutate | `mutate` rule |
| Generate | `generate` rule |
| Verify Image | `verifyImages` rule |
| Cleanup | `cleanup` policy |

Reference: [ClusterPolicy Overview](/docs/policy-types/cluster-policy/overview).

## Selection Guide

### Use CEL-based Policies for:
- New deployments
- Performance-sensitive environments
- Complex validation logic
- Native Kubernetes policy generation
- Non-Kubernetes payloads (Terraform, JSON)

### Use Traditional Policies for:
- Existing stable policies
- Simple pattern matching
- Teams preferring YAML-only syntax

## Quick Start

1. **[Getting Started with CEL Policies](/docs/cel/getting-started)** - Basics of using CEL in Kyverno
2. **[CEL vs Traditional Policies](/docs/cel/cel-vs-traditional)** - Comparison guide
3. **[Sample Policies](/policies)** - Browse policy examples
