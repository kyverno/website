---
date: 2023-11-28
title: Kyverno Completes Third-Party Security Audit
slug: kyverno-completes-third-party-security-audit
tags:
  - General
excerpt: Presenting the results from the Kyverno security audit
---

The Kyverno project is pleased to announce the completion of its third-party security audit. The audit was conducted by [Ada Logics](https://adalogics.com) in collaboration with the Kyverno maintainers, the [Open Source Technology Improvement Fund](https://ostif.org) and was funded by the [Cloud Native Computing Foundation](https://www.cncf.io).

The audit was a holistic security audit with four goals:

1. Define a formal threat model for Kyverno.
2. Conduct a manual code audit for security vulnerabilities.
3. Assess Kyverno's fuzzing suite against the threat model.
4. Evaluate Kyverno's supply-chain risks against SLSA.

Ada Logics found 10 security issues during the manual code auditing goal. Four of these had their root cause in the Notary verifier which had not been released prior to the audit. One of the findings was in a third-party dependency to Kyverno and was fixed by the Cosign project maintainers.

In total, 6 CVEs were assigned during the audit for the following components:

| CVE ID         | Vulnerable Kyverno Component | CVE Severity |
| -------------- | ---------------------------- | ------------ |
| CVE-2023-42816 | Notary verifier              | Moderate     |
| CVE-2023-42815 | Notary verifier              | Low          |
| CVE-2023-42813 | Notary verifier              | Moderate     |
| CVE-2023-42814 | Notary verifier              | Low          |
| CVE-2023-47630 | Kyverno Engine Image Loader  | High         |
| CVE-2023-46737 | Cosign (upstream)            | Low          |

Users consuming Kyverno from official releases have not been affected by the four CVE’s in the Notary verifier, since the Notary verifier has never been part of a public release, before Ada Logics reported the findings during the security audit. Only users building Kyverno from the main branch would be affected by these, however, building from main is highly discouraged.

During the fuzzing goal of the audit, Ada Logics wrote three new fuzzers and added them to Kyverno's fuzzing suite; Earlier this year, Kyverno completed its dedicated fuzzing security audit during which Ada Logics integrated Kyverno into OSS-Fuzz and built a fuzzing suite focusing on hitting high-coverage entry points. During the current security audit, Ada Logics wrote two fuzzers specifically for policy enforcement that attempt to create admission requests that are able to bypass Kyverno policies. In addition, Ada Logics wrote a fuzzer for a third-party dependency that implements complex data processing routines. The two policy fuzzers did not find any possible policy bypasses; the fuzzer for the third-party dependency found two reliability bugs.

During the SLSA goal, the auditors found that Kyverno impressively complies with the highest possible SLSA score and thereby ensures tamper-proof artifacts to consumers. Kyverno adopts the [slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator) which ensures SLSA level 3 compliance by generating verifiable provenance alongside releases on GitHub actions. Consumers can verify Kyverno's provenance by using the [slsa-verifier](https://github.com/slsa-framework/slsa-verifier).

The Kyverno maintainers have quickly addressed all issues found during the audit, with fixes incorporated in Kyverno v1.10.6 and v1.11.1. By prioritizing security work, the Kyverno team aims to provide a seamless and secure experience for consumers. Kyverno will continue to invest in robust security measures, staying ahead of potential threats and vulnerabilities.

Security researchers interested in contributing to Kyverno can find information about getting started [here](https://github.com/kyverno/kyverno/blob/main/SECURITY.md) or [engage with the Kyverno community](https://kyverno.io/community).

## Links

- [Audit report (PDF)](/blog/2023-security-audit/kyverno-2023-security-audit-report.pdf)
