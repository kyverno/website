---
title: Software Supply Chain Security
excerpt: Use Kyverno policies to reduce software supply chain risk in Kubernetes.
sidebar:
  order: 10
---

Software supply chain security focuses on reducing the risk that untrusted, unsigned, vulnerable, or incorrectly built workloads reach production Kubernetes clusters. Platform and security teams need controls that work at admission time, fit Kubernetes workflows, and provide enough visibility to support audit and incident response.

Kyverno helps teams apply these controls as Kubernetes-native policy. Policies can validate workload configuration, verify image signatures and attestations, run in audit mode before enforcement, and report policy results across clusters.

## Desired Outcome

A platform team adopting Kyverno for software supply chain security should be able to:

- require trusted image registries
- verify image signatures before workloads are admitted
- check attestations for provenance or build metadata
- audit policy violations before moving to enforcement
- report policy results for security and compliance review
- apply consistent controls across namespaces, teams, and clusters

## Kyverno Capabilities

Kyverno supports this outcome through several policy capabilities.

### Image Verification

Kyverno can verify container image signatures and attestations during admission. This helps ensure workloads come from trusted build and release processes before they run in the cluster.

Relevant documentation:

- [Verify Images](https://kyverno.io/docs/policy-types/cluster-policy/verify-images/)
- [ImageValidatingPolicy](https://kyverno.io/docs/policy-types/image-validating-policy/)

### Validation Policies

Validation policies can check workload configuration, image references, labels, annotations, security settings, and other Kubernetes fields. These policies help prevent risky workload definitions from being admitted.

Relevant documentation:

- [Validate Rules](https://kyverno.io/docs/policy-types/cluster-policy/validate/)
- [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy/)

### Audit and Enforce Modes

Teams can start with audit behavior to understand policy impact before blocking workloads. After policy behavior is understood, the same controls can move toward enforcement.

Relevant documentation:

- [Applying Policies](https://kyverno.io/docs/guides/applying-policies/)
- [Policy Reports](https://kyverno.io/docs/guides/reports/)

## Example Use Cases

Common software supply chain security use cases include:

- only allow images from approved registries
- require signed images for production namespaces
- verify image provenance from trusted build systems
- block mutable image tags such as `latest`
- require vulnerability scan attestations before deployment
- audit workloads that do not meet image trust requirements

## Policy Library Examples

The Kyverno policy library includes examples that can support software supply chain security workflows:

- [Disallow Latest Tag](https://kyverno.io/policies/best-practices/disallow-latest-tag/disallow-latest-tag/)
- [Require Image Registry](https://kyverno.io/policies/other/allowed-image-registries/allowed-image-registries/)
- [Verify Image Signatures](https://kyverno.io/policies/other/verify-image/verify-image/)

## Implementation Path

A practical rollout can follow these steps:

1. Identify trusted registries, signing keys, and required attestations.
2. Start with validation policies for registry and tag hygiene.
3. Add image verification policies in audit mode.
4. Review policy reports with application teams.
5. Move mature controls to enforcement.
6. Expand controls across namespaces and clusters.

## Related Kyverno Features

This outcome connects to:

- admission control
- image verification
- attestations
- validation policies
- policy reports
- audit-first policy rollout
