---
title: Community & Adoption
linkTitle: Community & Adoption
sidebar:
  order: 40
excerpt: Production adopters, case studies, and community feedback sources for Kyverno
---

This page consolidates publicly available evidence of Kyverno production adoption, user feedback, and ecosystem recognition. It is maintained to satisfy the CNCF TOC requirement for linkable user-research and adoption data (ref [issue #15473](https://github.com/kyverno/kyverno/issues/15473)).

## Production Adopters

Kyverno is used in production by organizations across finance, telecommunications, government, cloud providers, and e-commerce. The full list of organizations that have publicly shared their usage is maintained in [ADOPTERS.md](https://github.com/kyverno/kyverno/blob/main/ADOPTERS.md) in the project repository.

Notable adopters include:

- **Spotify** — Uses Kyverno extensively for admission controller capabilities, including best practices and environment-specific data. Spotify received the [CNCF Top End User Award 2023](https://www.cncf.io/announcements/2023/11/08/cloud-native-computing-foundation-presents-the-top-end-user-award-to-spotify/) in part for this work.
- **US DoD Platform One** — The US Department of Defense Platform One uses Kyverno as its default policy engine for Kubernetes.
- **Deutsche Telekom** — Uses Kyverno to enforce policies on managed clusters to prevent privilege escalation and enforce security rules.
- **Bloomberg** — Uses Kyverno to replace custom validation and mutation webhooks in their internal Kubernetes-based platforms.
- **Vodafone** — Policy enforcement and automation on an internal Kubernetes service offering.
- **LinkedIn** — Policy enforcement on on-prem Kubernetes clusters.

## Adopter Case Studies and Blog Posts

The following posts on the Kyverno blog document real-world usage patterns and adopter experiences:

- **[Policy-as-Code on Alibaba Cloud ACK](https://kyverno.io/blog/2026/02/13/policy-as-code-on-alibaba-cloud-container-service-for-kubernetes-flexible-kubernetes-governance-with-kyverno/)** (2026) — Flexible Kubernetes governance with Kyverno on Alibaba Cloud Container Service for Kubernetes, co-authored by engineers from Alibaba Cloud and Nirmata.
- **[Automating EKS CIS Compliance with Kyverno and KubeBench](https://kyverno.io/blog/2025/06/11/automating-eks-cis-compliance-with-kyverno-and-kubebench/)** (2025) — Practical approach to automating CIS compliance for Amazon EKS at scale.
- **[PodSecurityPolicy Migration with Kyverno](https://kyverno.io/blog/2023/05/24/podsecuritypolicy-migration-with-kyverno/)** (2023) — Migration guide used widely by organizations upgrading past Kubernetes v1.25.
- **[Simplifying OpenShift MachineSet Management Using Kyverno](https://kyverno.io/blog/2023/07/28/simplifying-openshift-machineset-management-using-kyverno/)** (2023) — Red Hat engineer demonstrates mutation use cases on OpenShift.

## CNCF Annual Survey Data

Kyverno is included in the CNCF Annual Survey as part of the policy management / security tooling category. The following survey reports are publicly available:

- [CNCF Annual Survey 2022](https://www.cncf.io/reports/cncf-annual-survey-2022/)
- [CNCF Annual Survey 2023](https://www.cncf.io/reports/cncf-annual-survey-2023/)
- [CNCF Annual Survey 2024](https://www.cncf.io/reports/cncf-annual-survey-2024/)

## Community Feedback Channels

User feedback is collected through the following public channels:

- **[GitHub Issues](https://github.com/kyverno/kyverno/issues)** — Feature requests, bug reports, and usage questions
- **[Slack (#kyverno)](https://slack.k8s.io/)** — Real-time community discussion in the Kubernetes Slack workspace
- **[Kyverno Community Meetings](https://kyverno.io/community/)** — Bi-weekly calls open to all; adopters regularly share use cases and request features
- **[CNCF End User Survey](https://www.cncf.io/enduser/)** — Kyverno is included in the annual CNCF survey of end users

Formal UX research studies and structured adopter interviews have not yet been conducted. This is a recognized gap and is tracked in [issue #15473](https://github.com/kyverno/kyverno/issues/15473).
