---
title: Security
description: Security Processes and Guidelines
weight: 90
---

Kyverno serves as an admission controller and is a critical component of the Kubernetes control plane. It is important to properly secure and monitor Kyverno. This section provides guidance on securing Kyverno and the security processes for the Kyverno project.

## Disclosure Process

Security vulnerabilities are best handled swiftly and discretely with the goal of minimizing the total time users remain vulnerable to exploits.

If you find or suspect a vulnerability, please email the security group at kyverno-security@googlegroups.com with the following information:

- description of the problem
- precise and detailed steps (include screenshots) that created the problem
- the affected version(s)
- any known mitigations

The Kyverno security response team will send an initial acknowledgement of the disclosure in 3-5 working days. Once the vulnerability and mitigation are confirmed, the team will plan to release any necessary changes based on the severity and complexity. Additional details on the security policy and processes are available in the Kyverno [git repo](https://github.com/kyverno/kyverno/blob/main/SECURITY.md).

## Security Audits

The Kyverno project participates in 3rd party security audits and reviews that help provide a comprehensive evaluation of the project's security posture.  These are listed below:

## Kyverno Third-Party Security Audit 2023

A Kyverno Third-Party Security Audit was conducted by [Ada Logics](https://adalogics.com/), in collaboration with the project maintainers and was funded by [the Cloud Native Computing Foundation](https://www.cncf.io/). The audit identified and addressed ten security issues, including six CVEs, with fixes in Kyverno v1.10.6 and v1.11.1. Notably, users of official releases were unaffected by CVEs in the Notary verifier. The audit did not reveal any policy by-pass situations, but did identify two security bugs with a third-party dependency. Kyverno was found to demonstrate strong compliance with [SLSA](https://slsa.dev/), earning the highest score, and ensuring tamper-proof build artifacts. More information is available in this [blog post](../../blog/general/2023-security-audit/index.md) with the audit report link at the bottom.

## Kyverno Fuzzing Security Audit 2023

The Kyverno Fuzzing Security Audit was conducted as part of the CNCF's security initiative. Fuzz testing, or fuzzing, is an automated process that injects random inputs into the system to reveal defects and vulnerabilities. The audit, spanning July and August 2023, resulted in 15 fuzzers identifying three bugs.  Post-audit, Kyverno continues to test for bugs and vulnerabilities using  [OSS-Fuzz](https://github.com/google/oss-fuzz).
The audit's findings prompted fixes and ongoing testing to ensure a secure and robust code base. You can read more about the fuzz testing [in this blog post](../../blog/general/2023-security-audit/index.md).

## Contact Us

To communicate with the Kyverno team, for any questions or discussions, use [Slack](https://slack.k8s.io/#kyverno) or [GitHub](https://github.com/kyverno/kyverno).

## Issues

All security related issues are labeled as `security` and can be viewed [here](https://github.com/kyverno/kyverno/labels/security).

## Release Artifacts

The Kyverno container images are available [here](https://github.com/orgs/kyverno/packages).

With each release, the following artifacts are uploaded (where CLI binaries include signature and PEM files):

- checksums.txt
- install.yaml
- kyverno-cli-<version_number>.tar.gz
- kyverno-cli_v<version_number>_darwin_arm64.tar.gz
- kyverno-cli_v<version_number>_darwin_x86_64.tar.gz
- kyverno-cli_v<version_number>_linux_arm64.tar.gz
- kyverno-cli_v<version_number>_linux_s390x.tar.gz
- kyverno-cli_v<version_number>_linux_x86_64.tar.gz
- kyverno-cli_v<version_number>_windows_arm64.zip
- kyverno-cli_v<version_number>_windows_x86_64.zip
- kyverno.io_<crd_names>.yaml
- policies.kyverno.io_<crd_names>.yaml
- reports.kyverno.io_<crd_names>.yaml
- wgpolicyk8s.io_<crd_names>.yaml
- Source code (zip)
- Source code (tar.gz)

## Verifying Kyverno Container Images, Install Manifest and Helm Chart

Kyverno container images and manifests are signed using Cosign and the [keyless signing feature](https://docs.sigstore.dev/cosign/verifying/verify/). The signatures are stored in a separate repository from the container image they reference located at `ghcr.io/kyverno/signatures`. To verify the container image and manifestsusing Cosign v1.x, follow the steps below.

1. Install [Cosign](https://github.com/sigstore/cosign#installation)

2. Configure the Kyverno signature repository:

```sh
export COSIGN_REPOSITORY=ghcr.io/kyverno/signatures
```

3. Verify the image (we are using `jq` to format the JSON output):

{{<tabpane text=true >}}
{{% tab header="**Cosign version**:" disabled=true /%}}
{{% tab header="v1.x" %}}
```sh
# Verify an image
COSIGN_EXPERIMENTAL=1 cosign verify ghcr.io/kyverno/kyverno:<release_tag> | jq

# Verify the kubernetes install manifest
COSIGN_EXPERIMENTAL=1 cosign verify ghcr.io/kyverno/manifests/kyverno:<release_tag> | jq

# Verify the kyverno helm chart
COSIGN_EXPERIMENTAL=1 cosign verify ghcr.io/kyverno/charts/kyverno:<release_tag> | jq
```
{{% /tab %}}
{{% tab header="v2.x" %}}
```sh
# Verfy an image
cosign verify ghcr.io/kyverno/kyverno:<release_tag> \
  --certificate-identity-regexp="https://github.com/kyverno/kyverno/.github/workflows/release.yaml@refs/tags/*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" | jq

# Verify the kubernetes install manifest
cosign verify ghcr.io/kyverno/manifests/kyverno:<release_tag> \
  --certificate-identity-regexp="https://github.com/kyverno/kyverno/.github/workflows/release.yaml@refs/tags/*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" | jq

# Verify the kyverno helm chart
cosign verify ghcr.io/kyverno/charts/kyverno:<release_tag> \
  --certificate-identity-regexp="https://github.com/kyverno/kyverno/.github/workflows/helm-release.yaml@refs/tags/*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" | jq
```
{{% /tab %}}
{{</tabpane>}}

If the artifact was properly signed, the output should be similar to:

```sh
Verification for ghcr.io/kyverno/kyverno:v1.11.2 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The code-signing certificate was verified using trusted certificate authority certificates
[
  {
    "critical": {
      "identity": {
        "docker-reference": "ghcr.io/kyverno/kyverno"
      },
      "image": {
        "docker-manifest-digest": "sha256:c2d33cc05ca2c7bab7ca13f4ef24276f4f1a83687e13a971945475b0e931bde8"
      },
      "type": "cosign container image signature"
    },
    "optional": {
      "1.3.6.1.4.1.57264.1.1": "https://token.actions.githubusercontent.com",
      "1.3.6.1.4.1.57264.1.2": "push",
      "1.3.6.1.4.1.57264.1.3": "5f9ed6f0f81e36a5f94a8bcece67ff94f7777a1a",
      "1.3.6.1.4.1.57264.1.4": "releaser",
      "1.3.6.1.4.1.57264.1.5": "kyverno/kyverno",
      "1.3.6.1.4.1.57264.1.6": "refs/tags/v1.11.2",
      "Bundle": {
        "SignedEntryTimestamp": "MEQCIH+Nnu89Mzm9XEb/f8n868uaQAGd631+kkx9mjcdYU+gAiAVPMEfIBGT5A+QBRfGR+X/Majgt+Jh5tsVNvlyvUu99A==",
        "Payload": {
          "body": "eyJhcGlWZXJzaW9uIjoiMC4w<snip>",
          "integratedTime": 1703770792,
          "logIndex": 59820453,
          "logID": "c0d23d6ad406973f9559f3ba2d1ca01f84147d8ffc5b8445c224f98b9591801d"
        }
      },
      "Issuer": "https://token.actions.githubusercontent.com",
      "Subject": "https://github.com/kyverno/kyverno/.github/workflows/release.yaml@refs/tags/v1.11.2",
      "githubWorkflowName": "releaser",
      "githubWorkflowRef": "refs/tags/v1.11.2",
      "githubWorkflowRepository": "kyverno/kyverno",
      "githubWorkflowSha": "5f9ed6f0f81e36a5f94a8bcece67ff94f7777a1a",
      "githubWorkflowTrigger": "push",
      "ref": "5f9ed6f0f81e36a5f94a8bcece67ff94f7777a1a",
      "repo": "kyverno/kyverno",
      "workflow": "releaser"
    }
  }
]
```

Note that the important fields to verify in the output are `optional.Issuer` and `optional.Subject`. If Issuer and Subject do not match the values shown above, the image is not genuine.

All Kyverno images can be verified.

## Verifying Provenance

Kyverno creates and attests to the provenance of its builds using the [SLSA standard](https://slsa.dev/provenance/v1.0) and meets the SLSA [Level 3](https://slsa.dev/spec/v1.0/levels) specification. The attested provenance may be verified using the `cosign` tool.


{{<tabpane text=true >}}
{{% tab header="**Cosign version**:" disabled=true /%}}
{{% tab header="v1.x" %}}
```sh
COSIGN_EXPERIMENTAL=1 cosign verify-attestation \
  --type slsaprovenance ghcr.io/kyverno/kyverno:<release_tag> | jq .payload -r | base64 --decode | jq
```
{{% /tab %}}
{{% tab header="v2.x" %}}
```sh
cosign verify-attestation --type slsaprovenance \
  --certificate-identity-regexp="https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@refs/tags/*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/kyverno/kyverno:<release_tag> | jq .payload -r | base64 --decode | jq
```
{{% /tab %}}
{{</tabpane>}}

The output will look something similar to the below.

```sh
Verification for ghcr.io/kyverno/kyverno:v1.11.2 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The code-signing certificate was verified using trusted certificate authority certificates
Certificate subject: https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@refs/tags/v1.9.0
Certificate issuer URL: https://token.actions.githubusercontent.com
GitHub Workflow Trigger: push
GitHub Workflow SHA: 5f9ed6f0f81e36a5f94a8bcece67ff94f7777a1a
GitHub Workflow Name: releaser
GitHub Workflow Repository: kyverno/kyverno
GitHub Workflow Ref: refs/tags/v1.11.2
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "ghcr.io/kyverno/kyverno",
      "digest": {
        "sha256": "c2d33cc05ca2c7bab7ca13f4ef24276f4f1a83687e13a971945475b0e931bde8"
      }
    }
  ],
  "predicate": {
    "builder": {
      "id": "https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@refs/tags/v1.9.0"
    },
    "buildType": "https://github.com/slsa-framework/slsa-github-generator/container@v1",
    "invocation": {
      "configSource": {
        "uri": "git+https://github.com/kyverno/kyverno@refs/tags/v1.11.2",
        "digest": {
          "sha1": "5f9ed6f0f81e36a5f94a8bcece67ff94f7777a1a"
        },
        "entryPoint": ".github/workflows/release.yaml"
      },
      "parameters": {},
      "environment": {
```

## Fetching the SBOM for Kyverno

An SBOM (Software Bill of Materials) in [CycloneDX](https://cyclonedx.org/) JSON format is published for each Kyverno release, including pre-releases. Like signatures, SBOMs are stored in a separate repository at `ghcr.io/kyverno/sbom`. To download and verify the SBOM for a specific version, install Cosign and run:

```sh
COSIGN_REPOSITORY=ghcr.io/kyverno/sbom cosign download sbom ghcr.io/kyverno/kyverno:<release_tag>
```

To save the SBOM to a file, run the following command:

```sh
COSIGN_REPOSITORY=ghcr.io/kyverno/sbom cosign download sbom ghcr.io/kyverno/kyverno:<release_tag> > kyverno.sbom.json
```

## Security Scorecard

Kyverno uses [Scorecards by OSSF](https://github.com/ossf/scorecard) to maintain repository-wide security standards. The current OSSF/scorecard score for Kyverno can be found in this [tracker issue](https://github.com/kyverno/kyverno/issues/2617). The Kyverno team is committed to achieving and maintaining a high score. Contributions are welcome.

## Vulnerability Scan Reports

The Kyverno Helm Chart is available via the [Artifact Hub page](https://artifacthub.io/packages/helm/kyverno/kyverno) along with an auto-generated [Security Report](https://artifacthub.io/packages/helm/kyverno/kyverno?modal=security-report) generated by Artifact Hub for all the releases.

## Security Best Practices

The following sections discuss related best practices for Kyverno:

### Pod security

Kyverno Pods are configured to follow security best practices and conform to the [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) `restricted` profile:

* `runAsNonRoot` is set to `true`
* `privileged` is set to `false`
* `allowPrivilegeEscalation` is set to `false`
* `readOnlyRootFilesystem` is set to `true`
* all capabilities are dropped
* limits and quotas are configured
* liveness and readiness probes are configured

### RBAC

The Kyverno RBAC configurations are described in the [installation](/docs/installation/customization.md#role-based-access-controls) section.

Use the following command to view all Kyverno roles:

```sh
kubectl get clusterroles,roles -A | grep kyverno
```

### Networking

Kyverno network traffic is encrypted and should be restricted using NetworkPolicies or similar constructs.

By default, a Kyverno installation does not configure NetworkPolicies (see [this issue](https://github.com/kyverno/kyverno/issues/2917)). The [Kyverno Helm chart](https://artifacthub.io/packages/helm/kyverno/kyverno) has a `networkPolicy.enabled` option to enable a NetworkPolicy.

Kyverno requires the following network communications to be allowed:

* ingress traffic to port 9443 from the API server
* ingress traffic to port 9443 from the host for health checks
* ingress traffic to port 8000 if metrics are collected by Prometheus or other metrics collectors
* egress traffic to the API server if the [API Call](/docs/policy-types/cluster-policy/external-data-sources.md#variables-from-kubernetes-api-server-calls) feature is used
* egress (HTTPS) traffic to OCI registries if [image verification](/docs/policy-types/cluster-policy/verify-images/_index.md) policy rules are configured or if [image registry context variables](/docs/policy-types/cluster-policy/external-data-sources.md#variables-from-image-registries) are used
* egress (HTTP or HTTPS) traffic to external services if the [external service call](/docs/policy-types/cluster-policy/external-data-sources.md#variables-from-service-calls) feature is used

### Webhooks

Use the following command to view all Kyverno webhooks:

```sh
kubectl get mutatingwebhookconfigurations,validatingwebhookconfigurations | grep kyverno
```

Kyverno creates the following mutating webhook configurations:

- `kyverno-policy-mutating-webhook-cfg`: handles policy changes to index and cache policy sets.
- `kyverno-resource-mutating-webhook-cfg`: handles resource admission requests to apply matching Kyverno mutate policy rules.
- `kyverno-verify-mutating-webhook-cfg`: periodically tests Kyverno webhook configurations.

Kyverno creates the following validating webhook configurations:

- `kyverno-policy-validating-webhook-cfg`: validates Kyverno policies with checks that cannot be performed via schema validation.
- `kyverno-resource-validating-webhook-cfg`: handles resource admission requests to apply matching Kyverno validate policy rules.
- `kyverno-cleanup-validating-webhook-cfg`: handles cleanup policies.
- `kyverno-exception-validating-webhook-cfg`: handles policy exceptions.

#### Webhook Failure Mode

Kyverno policies are configured to **fail-closed** by default. This setting can be tuned on a [per policy basis](/docs/policy-types/cluster-policy/policy-settings.md). Kyverno uses the configured policy set to automatically configure webhooks.

#### Webhook authentication and encryption

By default, Kyverno automatically generates and manages TLS certificates used for authentication with the API server and encryption of network traffic. To use a custom CA, please refer to the details in the [installation section](/docs/installation/customization.md#certificate-management).

### Recommended policies

The Kyverno community manages a set of [sample policies](/policies/).

At a minimum, the [Pod Security Standards](../../pod-security.md) and [best practices](/policies/?policytypes=Best%2520Practices) policy sets are recommended for use.

### Securing policies

Kyverno policies can be used to mutate and generate namespaced and cluster-wide resources. Hence, policies should be treated as critical resources and access to policies should be protected using RBAC. Note that some policies in these sets may have alternate versions. All policies should be inspected before being installed.

## Threat Model

The [Kubernetes SIG Security](https://github.com/kubernetes/community/tree/master/sig-security) team has defined an [Admission Control Threat Model](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md). It is highly recommended that Kyverno administrators read and understand the threat model, and use it as a starting point to create their own threat model.

The sections below list each threat, mitigation, and provide Kyverno specific details.

### Threat ID 1 - Attacker floods webhook with traffic preventing its operations

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-1---attacker-floods-webhook-with-traffic-preventing-its-operations)

**Mitigation:**

* [Mitigation ID 2 - Webhook fails closed](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-2---webhook-fails-closed)

  Kyverno policies are configured **fail-closed** by default. This setting can be tuned on a [per policy basis](/docs/policy-types/cluster-policy/policy-settings.md). Kyverno uses the configured policy set to automatically configure webhooks.

### Threat ID 2 - Attacker passes workloads which require complex processing causing timeouts

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-2---attacker-passes-workloads-which-require-complex-processing-causing-timeouts)

**Mitigations:**

* [Mitigation ID 2 - Webhook fails closed](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-2---webhook-fails-closed)

  Kyverno policies are configured **fail-closed** by default. This setting can be tuned on a [per policy basis](/docs/policy-types/cluster-policy/policy-settings.md). Kyverno uses the configured policy set to automatically configure webhooks.

* [Mitigation ID 3 - Webhook authenticates callers](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-3---webhook-authenticates-callers)

  By default, Kyverno generates a CA and X.509 certificates for the webhook registration. A custom CA and certificates can be used as discussed in the [configuration guide](/docs/installation/customization.md#custom-certificates). Currently, Kyverno does not authenticate the API server. A network policy can be used to restrict traffic to the Kyverno webhook port.

### Threat ID 3 - Attacker exploits misconfiguration of webhook to bypass

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-3---attacker-exploits-misconfiguration-of-webhook-to-bypass)

**Mitigation:**

* [Mitigation ID 8 - Regular reviews of webhook configuration catch issues](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-8---regular-reviews-of-webhook-configuration-catch-issues)

  Kyverno automatically generates webhook configurations based on the configured policy set. This ensures that webhooks are always current and minimally configured.

### Threat ID 4 - Attacker has rights to delete or modify the Kubernetes webhook object

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-4---attacker-has-rights-to-delete-or-modify-the-k8s-webhook-object)

**Mitigation:**

* [Mitigation ID 1 - RBAC rights are strictly controlled](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-1---rbac-rights-are-strictly-controlled)

  Kyverno RBAC configurations are described in the [installation section](/docs/installation/customization.md#role-based-access-controls). The `kyverno:admission-controller` role is used by Kyverno to configure webhooks. It is important to limit Kyverno to the required permissions and audit changes in the RBAC roles and role bindings.

### Threat ID 5 - Attacker gets access to valid credentials for the webhook

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-5---attacker-gets-access-to-valid-credentials-for-the-webhook)

**Mitigation:**

* [Mitigation ID 2 - Webhook fails closed](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-2---webhook-fails-closed)

  Kyverno policies are configured **fail-closed** by default. This setting can be tuned on a [per policy basis](/docs/policy-types/cluster-policy/policy-settings.md). Kyverno uses the configured policy set to automatically configure webhooks.

### Threat ID 6 - Attacker gains access to a cluster admin credential

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-6---attacker-gains-access-to-a-cluster-admin-credential)

**Mitigation**

  **N/A**

### Threat ID 7 - Attacker sniffs traffic on the container network

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-7---attacker-sniffs-traffic-on-the-container-network)

**Mitigation**

* [Mitigation ID 4 - Webhook uses TLS encryption for all traffic](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-4---webhook-uses-tls-encryption-for-all-traffic)

  Kyverno uses HTTPS for all webhook traffic.

### Threat ID 8 - Attacker carries out a MITM attack on the webhook

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-8---attacker-carries-out-a-mitm-attack-on-the-webhook)

**Mitigation**

* [Mitigation ID 5 - Webhook mutual TLS authentication is used](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-5---webhook-mutual-tls-authentication-is-used)

  By default, Kyverno generates a CA and X.509 certificates for the webhook registration. A custom CA and certificates can be used as discussed in the [configuration guide](/docs/installation/customization.md#custom-certificates). Currently, Kyverno does not authenticate the API server. A network policy can be used to restrict traffic to the Kyverno webhook port.

### Threat ID 9 - Attacker steals traffic from the webhook via spoofing

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-9---attacker-steals-traffic-from-the-webhook-via-spoofing)

**Mitigation**

* [Mitigation ID 5 - Webhook mutual TLS authentication is used](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-5---webhook-mutual-tls-authentication-is-used)

  By default, Kyverno generates a CA and X.509 certificates for the webhook registration. A custom CA and certificates can be used as discussed in the [configuration guide](/docs/installation/customization.md#custom-certificates). Currently, Kyverno does not authenticate the API server. A network policy can be used to restrict traffic to the Kyverno webhook port.

### Threat ID 10 - Abusing a mutation rule to create a privileged container

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-10---abusing-a-mutation-rule-to-create-a-privileged-container)

**Mitigation**

* [Mitigation ID 6 - All rules are reviewed and tested](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#Mitigation-id-6---all-rules-are-reviewed-and-tested)

  Kyverno rules are Kubernetes resources written in YAML and managed by an OpenAPIv3 schema. This approach makes it easy to understand policy definitions and to apply policy-as-code best practices, like code reviews, to Kyverno policies. The [Kyverno CLI](/docs/kyverno-cli/_index.md) provides a `test` command for executing unit tests as part of a continuous delivery pipeline.

### Threat ID 11 - Attacker deploys workloads to namespaces that are exempt from admission control

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-11---attacker-deploys-workloads-to-namespaces-that-are-exempt-from-admission-control)

**Mitigation**

* [Mitigation ID 1 - RBAC rights are strictly controlled](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-1---rbac-rights-are-strictly-controlled)

  Kyverno RBAC configurations are described in the [configuration section](/docs/installation/customization.md#role-based-access-controls). The `kyverno:admission-controller` role is used by Kyverno to configure webhooks. It is important to limit Kyverno to the required permissions and audit changes in the RBAC roles and role bindings.

  Kyverno excludes certain critical system Namespaces by default including the Kyverno Namespace itself. These exclusions can be managed and configured via the [ConfigMap](/docs/installation/customization.md#configmap-keys).

### Threat ID 12 - Block rule can be bypassed due to missing match (e.g. missing initContainers)

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-12---block-rule-can-be-bypassed-due-to-missing-match-eg-missing-initcontainers)

**Mitigation**

* [Mitigation ID 6 - All rules are reviewed and tested](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#Mitigation-id-6---all-rules-are-reviewed-and-tested)

  Kyverno rules are Kubernetes resources written in YAML and managed by an OpenAPIv3 schema. This approach makes it easy to understand policy definitions and to apply policy-as-code best practices, like code reviews, to Kyverno policies. The [Kyverno CLI](/docs/kyverno-cli/_index.md) provides a `test` command for executing unit tests as part of a continuous delivery pipeline.

### Threat ID 13 - Attacker exploits bad string matching on a blocklist to bypass rules

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-13---attacker-exploits-bad-string-matching-on-a-blocklist-to-bypass-rules)

**Mitigation**

* [Mitigation ID 6 - All rules are reviewed and tested](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#Mitigation-id-6---all-rules-are-reviewed-and-tested)

  Kyverno rules are Kubernetes resources written in YAML and managed by an OpenAPIv3 schema. This approach makes it easy to understand policy definitions and to apply policy-as-code best practices, like code reviews, to Kyverno policies. The [Kyverno CLI](/docs/kyverno-cli/_index.md) provides a `test` command for executing unit tests as part of a continuous delivery pipeline.

### Threat ID 14 - Attacker uses new/old features of the Kubernetes API which have no rules

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-14---attacker-uses-newold-features-of-the-kubernetes-api-which-have-no-rules)

**Mitigation**

* [Mitigation ID 6 - All rules are reviewed and tested](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#Mitigation-id-6---all-rules-are-reviewed-and-tested)

  Kyverno rules are Kubernetes resources written in YAML and managed by an OpenAPIv3 schema. This approach makes it easy to understand policy definitions and to apply policy-as-code best practices, like code reviews, to Kyverno policies. The [Kyverno CLI](/docs/kyverno-cli/_index.md) provides a `test` command for executing unit tests as part of a continuous delivery pipeline.

### Threat ID 15 - Attacker deploys privileged container to node running Webhook controller

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-15---attacker-deploys-privileged-container-to-node-running-webhook-controller)

**Mitigation**

* [Mitigation ID 7 - Admission controller uses restrictive policies to prevent privileged workloads](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-7---admission-controller-uses-restrictive-policies-to-prevent-privileged-workloads)

  The Kyverno [policy library](/policies/) contains policies to restrict container privileges and restrict access to host resources. The Pod Security Standards and best practices policies are highly recommended.

### Threat ID 16 - Attacker mounts a privileged node hostPath allowing modification of Webhook controller configuration

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-16---attacker-mounts-a-privileged-node-hostpath-allowing-modification-of-webhook-controller-configuration)

**Mitigation**

* [Mitigation ID 7 - Admission controller uses restrictive policies to prevent privileged workloads](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-7---admission-controller-uses-restrictive-policies-to-prevent-privileged-workloads)

  The Kyverno [policy library](/policies/) contains policies to restrict container privileges and restrict access to host resources. The Pod Security Standards and best practices policies are highly recommended.

### Threat ID 17 - Attacker has privileged SSH access to cluster node running admission webhook

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-17---attacker-has-privileged-ssh-access-to-cluster-node-running-admission-webhook)

**Mitigation**

  **N/A**

### Threat ID 18 - Attacker uses policies to send confidential data from admission requests to external systems

[Threat Model Link](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#threat-id-18---attacker-uses-policies-to-send-confidential-data-from-admission-requests-to-external-systems)

**Mitigation**

* [Mitigation ID 9 - Strictly control external system access](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/admission-control/kubernetes-admission-control-threat-model.md#mitigation-id-9---strictly-control-external-system-access)

  See [Networking](../security/_index.md#networking) for details on securing networking communications for Kyverno.
