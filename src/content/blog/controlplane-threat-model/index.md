---
date: 2026-07-29
title: Kyverno End User Threat Model and Hardening Guide, by ControlPlane
tags:
  - General
  - Security
authors:
  - name: Shuting Zhao
excerpt: Announcing a comprehensive end user threat model and hardening guide for Kyverno, authored by ControlPlane
---

![ControlPlane and Kyverno](assets/controlplane-kyverno-logos.png)

The Kyverno project is excited to announce the publication of the [Kyverno End User Threat Model and Hardening Guide](/blog/controlplane-threat-model/assets/kyverno-end-user-threat-model-and-hardening-guide.pdf), authored by the security experts at [ControlPlane](https://control-plane.io).

The report is [available to download for free](/blog/controlplane-threat-model/assets/kyverno-end-user-threat-model-and-hardening-guide.pdf) and provides an in-depth analysis of the threats that could affect your Kyverno installation, along with practical, layered mitigations to address them.

## Summary of the report

Kyverno functions as a critical security control plane, meaning its operational integrity is inseparable from a cluster's overall security posture. The most significant risks stem from misconfigurations, such as permissive `failurePolicy: Ignore` settings, weak RBAC, or unverified policy supply chains, rather than software vulnerabilities. These issues can appear across different common deployment patterns, which have been documented in the threat model, so you can best understand how to harden common Kyverno deployments and how a layered approach to mitigations can reduce overall risk.

## Who should read it

If you are running Kyverno in production — or planning to — you should absolutely read this report. It establishes a shared baseline for how the community evaluates threats to Kyverno, and it will help direct where the project invests in security improvements going forward.

## Acknowledgment

Thank you to ControlPlane for their continued efforts in supporting the security of open source and providing recommendations for deploying Kyverno securely across different environments. Interested in more? Check them out: [https://control-plane.io/contact/](https://control-plane.io/contact/).

## Links

- [Kyverno End User Threat Model and Hardening Guide (PDF)](/blog/controlplane-threat-model/assets/kyverno-end-user-threat-model-and-hardening-guide.pdf)
- [ControlPlane](https://control-plane.io)
- [Kyverno](https://kyverno.io)
