---
date: 2026-04-24
title: Announcing Kyverno 1.18!
tags:
  - Releases
excerpt: Security enhancements, CLI expansion, and policy engine improvements in Kyverno 1.18
draft: false
featured: true
---

# Announcing Kyverno Release 1.18!

We’re excited to announce the release of **Kyverno 1.18**, our **first release since** [graduating within the Cloud Native Computing Foundation](https://www.cncf.io/announcements/2026/03/24/cloud-native-computing-foundation-announces-kyvernos-graduation/).

This release builds on Kyverno’s growing role as a **Kubernetes-native policy engine**, with major investments in **security, CLI capabilities, and policy engine reliability**. It also continues our transition toward **CEL-based policy types**, setting the foundation for the future of policy as code.

## **TL;DR**

Kyverno 1.18 delivers:

- Stronger **security controls** for HTTP-based policy execution and multiple CVE mitigations

- Significant **CLI enhancements** for testing and applying modern policy types

- Policy engine improvements for **performance, observability, and scalability**

- Enhancements to the **policies Helm chart** for better customization

There are **no breaking changes** in this release, but **ClusterPolicy deprecation remains on track**, and users should begin migrating to the newer policy types.

## **Security Improvements**

Security is a core pillar of Kyverno, and 1.18 introduces important safeguards for policy execution.

### **Safer HTTP Execution**

Kyverno policies can call external services via HTTP CEL libraries. In 1.18, this capability is significantly hardened:

- **Blocklist/allowlist enforcement**: by default, unsafe addresses like loopback and metadata services are blocked. Users can configure an allow list and a block list for cluster-scoped and namespaced policies. Additionally, HTTP calls from namespaced policies are default disabled, and need to be explicitly enabled using configuration flags. These changes help prevent SSRF-style abuse. See [CVE-2026-4789](https://github.com/advisories/GHSA-rggm-jjmc-3394) for details.

- **Scoped token authorization**: Previously, Kyverno HTTP calls included a token which could be used to impersonate Kyverno controllers. Now, HTTP calls include a separate scoped token that ensures that servers cannot misuse the token. See [CVE-2026-41323](https://github.com/kyverno/kyverno/security/advisories/GHSA-f9g8-6ppc-pqq4) for details.

These changes reduce the risk of unintended external access while maintaining flexibility for advanced policy use cases.

## **CLI Expansion and Developer Experience**

Kyverno’s CLI continues to evolve as a critical tool for policy development and testing.

### **Expanded Policy Support**

The `kyverno apply` and `kyverno test` commands now support:

- Cleanup policies

- HTTP and Envoy authorization policies

- `mutateExisting` rules in `MutatingPolicy`

- The `--exceptions-with-policies` flag for improved testing workflows

This significantly improves the ability to **test modern policy types locally and in CI pipelines**.

### **Reliability and Usability Improvements**

Numerous fixes address:

- Error handling and reporting

- CRD compatibility without cluster connections

- Stability issues such as panics and file handle leaks

The result is a more predictable and developer-friendly experience when working with policies.

## **Policy Engine Improvements**

Kyverno 1.18 includes several enhancements that improve how policies are executed and managed at scale.

### **Fine-Grained Success Event Filtering**

A new `successEventActions` ConfigMap parameter allows users to control:

- Which success events are emitted

- How noisy or quiet policy reporting should be

This is especially valuable in large environments where event volume needs to be tuned.

### **Performance and Scalability**

Key improvements include:

- **Memory-based HPA autoscaling** for the admission controller

- **TLS support on the /metrics endpoint**

- Improved concurrency handling and reduced risk of race conditions

These changes make Kyverno more resilient in high-scale production environments.

### **CEL and Policy Execution Enhancements**

- Addition of a **gzip CEL library** for more advanced expressions

- Improved compilation and evaluation of policy variables and conditions

- Better alignment between policy types and execution engines

### **Image Verification Improvements**

Several targeted improvements land for image verification:

- For `ClusterPolicies`, `imageRegistryCredentials.secrets` now accepts a `namespace/name` notation, and pod-level `imagePullSecrets` are automatically used as registry credentials, useful in multi-tenant environments where each namespace manages its own pull secrets.

- Reliability fixes for `ImageValidatingPolicy`, including better handling of signed timestamps and TSA certificate chains, Notary resolver fixes, correct `matchImageReferences` filtering, and improved autogen support for namespaced policies.

## **Policies Helm Chart Enhancements**

The policies Helm chart continues to evolve with better customization and control.

New capabilities include:

- Support for **excludes in ValidatingPolicies** (namespace, subject, resource rules, match conditions)

- `auditAnnotation` configuration

- **Per-policy annotation overrides**

These improvements make it easier to tailor policies to specific organizational and operational needs.

## **Updated Support Policy**

As Kyverno continues to grow in adoption, contributions, and overall project scope, we are evolving how we provide release support.

**Starting with the 1.18 release, Kyverno will follow a “main + 1” patch support model.**

This means:

- The current release (main) and the immediately previous release will be supported for patches. Patches are limited to critical and high severity CVEs, and other critical fixes. This provides roughly 3 months of community patch support.

- Older versions will no longer receive regular updates or fixes

### **Why this change**

This adjustment allows the maintainer team to:

- Efficiently manage the **AI driven increase in security issues and PRs**

- Maintain higher standards for **security and responsiveness**

- Focus efforts on **current and actively used versions**

- Keep the project **sustainable and manageable as it scales**

### **What this means for users**

We recommend that users:

- Stay up to date with recent Kyverno releases

- Plan upgrades in alignment with the 3 month support window, or use a commercial distribution that provides higher SLAs and long term support

- Reach out to the community if guidance is needed

This change ensures we can continue to deliver a secure, stable, and forward-moving project for everyone.

## **ClusterPolicy Deprecation Reminder**

As a reminder, `ClusterPolicy` **resources are planned for deprecation later this year**.

We strongly encourage users to begin migrating to the newer policy types:

```
- ValidatingPolicy

- MutatingPolicy

- GeneratingPolicy

- ImageValidatingPolicy

- DeletingPolicy
```

### **What you should do**

- Start migrating existing policies

- Test thoroughly using the CLI

- Report any gaps or issues

Community feedback is essential to ensuring a smooth transition and full feature parity. We ask that you please report issues and help us build full parity in the upcoming months.

## **Community Updates**

Kyverno’s graduation within the CNCF marks a major milestone for the project and its community.

### **Join the Community**

Kyverno community meetings now run at **multiple global-friendly times**:

- APAC / EU: Every other Wednesday 9:00 CET / India 13:30h / EU: 09:00h / Singapore: 16:00h / Australia: 18:00h

- USA/LATAM: Every other Wednesday 16:00 CET / India 20:30h / EU: 16:00h / NYC: 10:00h / SF: 7:00h

You can find all meetings on the [CNCF Calendar](https://www.cncf.io/calendar/) using the Kyverno filter.

Additionally, we are working to create a space where community members can publish case studies and use cases to our community blog in hopes that this will serve as a space where everyone can learn from each other. Please keep an eye out for the announcements of when this section of the blog will be live and if you would like to submit a use case or case study, please reach out to [cortney.nickerson@nirmata.com](mailto:cortney.nickerson@nirmata.com) directly.

**Getting Started and Upgrading**

Kyverno 1.18 has **no breaking changes**, making it a safe and straightforward upgrade for most users.

### **Upgrade**

- Review the release notes

- Test in staging environments

- Follow upgrade guidance in the documentation

### **Install**

[https://kyverno.io/docs/installation/](https://kyverno.io/docs/installation/)

### **Release Notes**

[https://github.com/kyverno/kyverno/releases](https://github.com/kyverno/kyverno/releases)

## **What’s Next**

Looking ahead, the [Kyverno ](https://github.com/kyverno/kyverno/blob/main/ROADMAP.md)[roadmap](https://github.com/kyverno/kyverno/blob/main/ROADMAP.md) focuses on:

- Continued investment in **CEL-based policy types**

- Improved **policy authoring experience**

- Scaling policy across **multi-cluster environments**

- Expanding into **AI governance and policy-driven automation**

## **Conclusion**

**Kyverno 1.18 is a meaningful step forward following our CNCF graduation.**

With stronger security, expanded CLI capabilities, and continued investment in policy engine reliability and Kubernetes-native policy, Kyverno is helping teams move from policy enforcement to policy-driven operations at scale.

As the project continues to grow, we are also evolving how we operate to ensure long-term sustainability. Our move to an **N-1 support model** reflects a commitment to maintaining high-quality releases while keeping pace with the needs of a rapidly expanding community and ecosystem.

**Upgrade to Kyverno 1.18, stay current with supported releases, begin your migration to the new policy types, and help us build the future of policy as code.**
