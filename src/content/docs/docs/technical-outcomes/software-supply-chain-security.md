---
title: Software Supply Chain Security
excerpt: Use Kyverno policies to reduce software supply chain risk in Kubernetes.
sidebar:
  order: 10
---

Software supply chain security focuses on reducing the risk that untrusted, unsigned, vulnerable, or incorrectly built workloads reach production Kubernetes clusters. Platform and security teams need controls that work at admission time, fit Kubernetes workflows, and provide enough visibility to support audits, incident response, and compliance reviews.

Kyverno helps teams apply these controls as Kubernetes-native policy. Policies can validate workload configuration, verify image signatures and attestations, roll out in audit mode before enforcement, and report policy results across clusters.

## Desired Outcome

A platform team using Kyverno for software supply chain security should be able to:

- require workloads to use approved image registries
- prevent mutable or ambiguous image references
- verify image signatures before workloads are admitted
- check attestations for provenance, build metadata, or vulnerability scan results
- audit policy violations before moving to enforcement
- report policy results for security and compliance reviews
- apply consistent controls across namespaces, teams, and clusters

## Why This Matters

Kubernetes clusters often run workloads from many teams, pipelines, registries, and deployment tools. Without admission-time policy, a cluster may accept workloads that reference untrusted registries, unsigned images, mutable tags, or images without verifiable build provenance.

Kyverno provides a control point close to where risk enters the cluster: the Kubernetes API server admission flow. This lets teams block risky workloads before they run while still supporting gradual rollout through audit mode and PolicyReports.

## Outcome Mapping

| User Goal | Kyverno Capability | Example Control |
| --- | --- | --- |
| Require trusted image sources | Validation policies | Allow only approved registries |
| Prevent ambiguous deployments | Validation policies | Disallow `latest` or mutable tags |
| Verify image identity | Image verification | Require signed images |
| Verify build provenance | Attestation verification | Require SLSA provenance attestations |
| Reduce rollout risk | Audit and enforce modes | Start in audit mode, then move to enforcement |
| Track violations over time | Policy reports | Review supply chain policy failures |
| Apply controls consistently | Policy exceptions and namespace selectors | Scope rollout by team, namespace, or environment |

## Kyverno Capabilities

### Image Verification

Kyverno can verify container image signatures and attestations during admission. This helps ensure workloads come from trusted build and release processes before they run in the cluster.

Relevant documentation:

- [Verify Images](https://kyverno.io/docs/policy-types/cluster-policy/verify-images/)
- [ImageValidatingPolicy](https://kyverno.io/docs/policy-types/image-validating-policy/)
- [Sigstore verification](https://kyverno.io/docs/policy-types/cluster-policy/verify-images/sigstore/)

### Validation Policies

Validation policies can check workload configuration, image references, labels, annotations, security settings, and other Kubernetes fields. These policies help prevent risky workload definitions from being admitted.

Relevant documentation:

- [Validate Rules](https://kyverno.io/docs/policy-types/cluster-policy/validate/)
- [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy/)

### Audit and Enforce Modes

Teams can start in audit mode to understand policy impact before blocking workloads. After the impact is understood, the same controls can move toward enforcement.

Relevant documentation:

- [Applying Policies](https://kyverno.io/docs/guides/applying-policies/)
- [Policy Reports](https://kyverno.io/docs/guides/reports/)

## Rollout Path

A practical rollout can follow these phases:

### Phase 1: Visibility

Start by measuring current workload risk without blocking deployments.

- inventory registries used across namespaces
- identify workloads using mutable tags
- run validation policies in audit mode
- review PolicyReports with application teams

### Phase 2: Baseline Controls

Introduce controls that are broadly useful and low-risk.

- require approved registries
- disallow `latest` tags in production namespaces
- require explicit image tags or digests
- define exception patterns for migration windows

### Phase 3: Trust Verification

Add controls that verify where software came from and how it was built.

- verify signatures for production workloads
- require attestations from trusted CI systems
- validate provenance metadata such as repository, branch, workflow, and builder identity
- review failures before switching to enforcement

### Phase 4: Enforcement and Operations

Move mature controls from audit to enforcement.

- enforce trusted registry and image tag policies
- enforce image verification for production namespaces
- alert on PolicyReport failures
- review exceptions regularly
- document policy behavior for application teams

## Example Use Cases

Common software supply chain security use cases include:

- allow images only from approved registries
- require signed images for production namespaces
- verify image provenance from trusted build systems
- block mutable image tags such as `latest`
- require vulnerability scan attestations before deployment
- audit workloads that do not meet image trust requirements
- phase in enforcement by namespace, team, or environment

## Example Policy Patterns

The exact policy depends on the organization's registry, signing, and release processes, but most supply chain programs start with a small set of repeatable patterns.

### Require Approved Registries

Use validation policies to ensure workloads pull images only from registries the platform team trusts.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-approved-registries
spec:
  validationFailureAction: Audit
  rules:
    - name: require-approved-registries
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Images must come from an approved registry."
        pattern:
          spec:
            containers:
              - image: "registry.example.com/*"
```

### Block Mutable Tags

Use validation policies to prevent ambiguous image references in sensitive environments.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationFailureAction: Audit
  rules:
    - name: disallow-latest-tag
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: "Images must not use the latest tag."
        pattern:
          spec:
            containers:
              - image: "!*:latest"
```

## Signals to Watch

Policy rollout is easier when teams can measure progress. Useful signals include:

- workloads using unapproved registries
- workloads using mutable tags
- image verification pass and fail counts
- namespaces with repeated supply chain policy violations
- exceptions created for production workloads
- time required to move a policy from audit mode to enforcement

These signals can be reviewed through PolicyReports and any downstream reporting or observability tools used by the platform team.

## Scope and Limitations

Kyverno can enforce supply chain controls at Kubernetes admission time, but it is one part of a larger software supply chain security program.

Kyverno can help with:

- admission-time image and workload policy checks
- signature and attestation verification
- audit-first rollout
- reporting policy violations in the cluster

Kyverno does not replace:

- secure CI/CD pipeline design
- source code review
- artifact repository governance
- vulnerability management outside Kubernetes
- key management and signing process ownership

## Policy Library Examples

The Kyverno policy library includes examples that support software supply chain security workflows:

- [Disallow Latest Tag](https://kyverno.io/policies/best-practices/disallow-latest-tag/disallow-latest-tag/)
- [Require Image Registry](https://kyverno.io/policies/other/allowed-image-registries/allowed-image-registries/)
- [Verify Image Signatures](https://kyverno.io/policies/other/verify-image/verify-image/)
- [Verify SLSA Provenance](https://kyverno.io/policies/other/verify-image-slsa/verify-image-slsa/)

## Adoption Checklist

Before enforcing supply chain policies, teams should be able to answer:

- Which registries are approved for each environment?
- Which namespaces should enforce signature verification first?
- Which signing identities or keys are trusted?
- Which attestations are required for production workloads?
- How will exceptions be requested, approved, and expired?
- Where will policy violations be reviewed?
- Which controls start in audit mode and which can be enforced immediately?

## Related Kyverno Features

This outcome connects to:

- admission control
- image verification
- attestations
- validation policies
- policy reports
- policy exceptions
- audit-first policy rollout
