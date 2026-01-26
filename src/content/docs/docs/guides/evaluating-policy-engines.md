---
title: Evaluating Policy Engines
description: A comprehensive guide to evaluating policy engines and understanding how Kyverno meets key criteria
sidebar:
  order: 50
---

This guide is intended to help users when evaluating policy as code solutions. It focuses on how Kyverno addresses each evaluation criteria based on its design principles and feature set.
:::

When evaluating policy engines for Kubernetes, it's important to understand the key criteria that matter for your organization. This guide breaks down each evaluation criterion and explains how Kyverno addresses these requirements.

## Project Philosopy

Kyverno was created to make policy management easy for Kubernetes administrators and users. While security will alwats major use case, Kyverno uniquely addresses `Policy-Based Automation` across security, operations, and optimization use cases by providing policy types that map to each phase of resource configuration lifecycle. Using Kyverno, platform engineers can easily address a large number of automation use cases, including but not limited to security. This eliminates the need for complex custom controllers, which are difficult to mantain, secure, and scale.

## Policy Language

**Kyverno Approach:** Kyverno uses **YAML and CEL (Common Expression Language)** as its policy language. Kyverno policies are Kubernetes resources written in YAML with evaluation logic embedded as CEL expressions. Sicne CEL is used extensively in Kubernetes, this approach makes Kyverno immediately accessible to all Kubernetes users.

Kyverno eliminates the need to learn a specialized policy language like Rego, while providing powerful capabilities that are easier to use. This approach provides:

- **Minimal learning curve** for teams already familiar with Kubernetes YAML
- **Native Kubernetes structure** - policies look like Kubernetes resources
- **CEL expressions** for advanced validation and transformation logic
- **Type safety** through Kubernetes OpenAPI schemas and CEL compilation
- **Great Performance** CEL-based policies deliver significant better performance and use less CPU and memory resources
- **Highly Secure** CEL expressions are pre-compiled and run with no side effects for sandboxed execution. CEL is non-turing complete to prevent infinite loops and allows resource bounds for host safety.

The YAML-based approach allows policies to be version-controlled, reviewed, and managed using the same tools and processes as other Kubernetes resources.

## Ease of Adoption

**Kyverno Approach:** Kyverno is designed to be **intuitive and extends Kubernetes types naturally**.

Kyverno's design philosophy centers on being Kubernetes-native. This means:

- **Familiar patterns**: Policies use standard Kubernetes selectors (labels, namespaces, kinds)
- **No additional abstractions**: You work directly with Kubernetes resources
- **Gradual adoption**: Start with simple validation policies and gradually add complexity
- **Rich documentation**: Comprehensive guides and examples for common use cases
- **Policy library**: Extensive collection of pre-built policies ready to use

Teams can begin using Kyverno with minimal training, as the concepts map directly to Kubernetes resource management patterns they already understand.

## K8s Resource Validation

**Kyverno Approach:** Kyverno provides **comprehensive Kubernetes resource validation** capabilities.

Kyverno excels at validating Kubernetes resources during admission control. It can:

- **Validate any Kubernetes resource** using match rules and conditions
- **Use CEL expressions** for complex validation logic
- **Reference external data** from ConfigMaps, Secrets, and external API calls
- **Validate resource relationships** and dependencies
- **Enforce best practices** and security policies

Validation policies can check resource specifications, metadata, relationships between resources, and even validate against external data sources. This makes Kyverno suitable for enforcing organizational policies, security standards, and compliance requirements.

## K8s Resource Mutation

**Kyverno Approach:** Kyverno provides **powerful and flexible mutation capabilities** for both new and existing Kubernetes resources.

Mutation is one of Kyverno's core strengths. It can:

- **Add, remove, or modify** resource fields during admission
- **Inject sidecars** and init containers
- **Set default values** for missing fields
- **Transform resource specifications** based on patterns
- **Add labels and annotations** automatically
- **Modify container images** and resource requests

Kyverno mutations are declarative and idempotent, meaning they can be safely applied multiple times without causing issues. This makes it ideal for standardizing resource configurations across clusters and ensuring consistency.

## K8s Resource Generation

**Kyverno Approach:** Kyverno can **generate new Kubernetes resources** based on flexible triggers such as when resources are created or modified, or based on periodically matching existing resources.

Resource generation is a unique capability that allows Kyverno to automate tasks like:

- **Creating NetworkPolicies** automatically based on namespace labels
- **Create ConfigMaps and Secrets** from templates
- **Generate PodDisruptionBudgets** for deployments
- **Clone resources** across namespaces with modifications

This capability enables powerful automation scenarios where resources need to be created automatically based on the presence or configuration of other resources, reducing manual operational overhead.

## K8s Resource Cleanup

**Kyverno Approach:** Kyverno provides **dedicated cleanup policies** for managing resource lifecycle.

Cleanup policies allow Kyverno to:

- **Automatically delete resources** based on schedules or conditions
- **Clean up orhpan resources** when parent resources are deleted
- **Remove resources** that no longer meet certain criteria
- **Schedule periodic cleanup** of temporary or expired resources

This helps maintain cluster hygiene by automatically removing resources that are no longer needed, such as temporary test resources, expired certificates, or resources that violate policies.

## Image Verification

**Kyverno Approach:** Kyverno provides **native image verification** using Sigstore Cosign and Notary.

Image verification is built into Kyverno and supports:

- **Cosign v2 and v3 formats**: Verify container images signed with Cosign
- **Notary v2**: Support for Notary v2 signatures
- **Attestation verification**: Verify SLSA provenance and other attestations
- **Keyless verification**: Support for keyless signing with Sigstore
- **Registry authentication**: Support for private registries

Kyverno can verify images during admission control, ensuring only signed and verified images are deployed to your cluster. This provides strong supply chain security without requiring additional tooling or complex integrations.

## Runtime Controls

**Kyverno Approach:** Kyverno provides **comprehensive runtime policy enforcement** beyond just admission control.

While many policy engines focus only on admission-time validation, Kyverno offers:

- **Background scanning**: Periodic evaluation of existing resources
- **Policy reports**: Continuous monitoring of policy compliance

This means policies aren't just enforced at creation time, but resources are continuously monitored and policies are enforced throughout the resource lifecycle.

## Shift-Left, CI/CD Integration

**Kyverno Approach:** Kyverno provides **strong CI/CD integration** through the Kyverno CLI.

The Kyverno CLI enables shift-left practices by:

- **Testing policies locally** before deploying to clusters
- **Validating Kubernetes manifests** in CI/CD pipelines
- **Validating IaC manifests** such as Terraform plans

This allows teams to catch policy violations early in the development process, reducing the feedback loop and preventing non-compliant resources from reaching production clusters.

## Any Payload

**Kyverno Approach:** Kyverno can validate **any JSON payload**, not just Kubernetes resources.

Through Kyverno JSON policies and the ValidatingPolicy resource type, Kyverno can:

- **Validate any JSON structure** using the same policy language
- **Work outside Kubernetes** via the Kyverno JSON SDK
- **Integrate with web services** and APIs
- **Validate configuration files** and other structured data

This flexibility makes Kyverno useful beyond Kubernetes, allowing organizations to use a single policy engine for multiple use cases.

## Reporting

**Kyverno Approach:** Kyverno provides **comprehensive reporting** through [OpenReports](https://openreports.io).

Kyverno's reporting capabilities include:

- **PolicyReports**: Standard Kubernetes resources for policy results
- **OpenReports API**: Support for the new OpenReports API group
- **Reports Server**: Scalable etcd offload solution for large clusters
- **Background scanning results**: Reports from periodic policy evaluations
- **Integration with reporting tools**: Compatible with various reporting UIs

The reporting system provides visibility into policy compliance across your cluster, making it easy to identify non-compliant resources and track policy effectiveness over time.

## Policy Exceptions

**Kyverno Approach:** Kyverno provides **dedicated PolicyException resources** for managing policy exemptions.

Policy exceptions allow you to:

- **Exempt specific resources** from policy enforcement
- **Define exceptions declaratively** using Kubernetes resources
- **Scope fine-grained exceptions** by namespace, resource name, or labels, or CEL conditions
- **Time bound exceptions** by combining with cleanup policies or TTLs
- **Audit exceptions** through standard Kubernetes APIs

This provides a controlled way to handle legitimate cases where resources need to deviate from standard policies, while maintaining visibility and auditability.

## Test Tooling

**Kyverno Approach:** Kyverno provides **comprehensive testing tools** for policy development.

Kyverno's testing capabilities include:

- **Kyverno CLI test command**: Test policies against sample resources
- **Kyverno Chainsaw**: Advanced testing framework for Kyverno policies

These tools enable policy authors to develop, test, and validate policies before deploying them to production, ensuring policies work as expected and don't break existing workflows.

## Performance

Kyverno is optimized for performance and scalability, with significant results demonstrated in production environments. In addition to other benefits, organizations migrating from OPA/Gatekeeper to Kyverno have reported substantial performance gain (see below.)

The new CEL based policies provide further performance improvements. For detailed reports see the [Scale Tests](/docs/installation/scaling/#scale-testing) documentation.

### Community Migration Stories

Several organizations in the Kyverno community have shared their experiences migrating from OPA/Gatekeeper to Kyverno and seeing improved performance. Here are a few:

- [Adventa](https://adevinta.com/techblog/why-did-we-transition-from-gatekeeper-to-kyverno-for-kubernetes-policy-management/)
- [Wayfair](https://nirmata.com/2023/11/29/why-how-wayfair-migrated-from-opa-to-kyverno/)
- [US DoD](https://docs-bigbang.dso.mil/latest/packages/kyverno/docs/gatekeeper/)
- [PwC](https://medium.com/@glen.yu/why-i-prefer-kyverno-over-gatekeeper-for-native-kubernetes-policy-management-35a05bb94964)

The [Gatekeeper Migration Guide](/docs/guides/gatekeeper/) provides more information to plan your own migration.

## Conclusion

When evaluating policy engines, consider not just feature lists but also:

- **Ease of adoption** for your team
- **Performance characteristics** at your scale
- **Integration** with your existing tooling
- **Community support** and documentation
- **Long-term maintainability**

Kyverno's Kubernetes-native design, comprehensive feature set, and strong performance characteristics make it an excellent choice for organizations looking to implement policy-as-code in their Kubernetes environments.

For more information about specific features, refer to the [Kyverno documentation](/docs/) or explore the [policy library](/policies/) for ready-to-use policies.
