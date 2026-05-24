## Software Supply Chain Security

Software supply chain security in Kubernetes focuses on controlling which workloads can run, where container images come from, and how those images were built and verified.

Platform and security teams use admission-time controls because deployment requests are often the last common checkpoint before workloads enter a cluster.

## Problem space

Software supply chain controls are often introduced late and applied inconsistently across Kubernetes environments. Without automated policy enforcement, organizations can struggle to verify image trust, provenance, and workload security posture.

Common risks include:

| Risk                  | Example                                                      |
| --------------------- | ------------------------------------------------------------ |
| Unsigned images       | Untrusted or tampered images deployed from public registries |
| Mutable tags          | `latest` points to a different image than the one tested     |
| Missing provenance    | No SBOM or build attestation available for investigation     |
| Unapproved registries | Workloads deployed from unofficial registries                |
| Privileged workloads  | Containers running as root or with elevated permissions      |
| Compliance drift      | Security controls differ across clusters and environments    |

Kyverno policies help enforce these controls consistently during admission and through background reporting.

## Desired outcome

When Kyverno is used to implement software supply chain security, organizations achieve the following outcomes:

| Outcome                     | What it means                                       |
| --------------------------- | --------------------------------------------------- |
| Trusted registries enforced | Workloads from unapproved registries are blocked    |
| Signed images verified      | Images must include valid signatures                |
| Provenance validated        | Build attestations can be verified during admission |
| Mutable tags restricted     | Policies block tags such as `latest`                |
| Continuous compliance       | Policy reports identify violations and drift        |
| Safer rollout process       | Policies can start in `Audit` before `Deny`         |

## Kyverno capabilities

Kyverno supports software supply chain security through admission-time verification, validation, and policy reporting capabilities.

| Capability          | Policy type                                   | What it does                                                                              |
| ------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Image verification  | `ImageValidatingPolicy`                       | Verifies Cosign or Notary signatures and SLSA attestations before workloads are admitted  |
| Validation          | `ValidatingPolicy`                            | Checks image references, registry sources, tags, and workload fields against policy rules |
| Audit and reporting | `validationActions: [Audit]` + `PolicyReport` | Records violations without blocking admission and tracks compliance posture over time     |

### Image verification

`ImageValidatingPolicy` verifies image signatures and attestations during admission. Verification can use public keys, Sigstore keyless identities, or Notary trust stores. If verification fails, the workload is denied and a clear error is returned to the submitter.

Attestation verification extends this further. Kyverno can validate the content of attached SLSA provenance records, SBOMs, and vulnerability scan attestations.

Relevant documentation:

- [Verify Images](https://kyverno.io/docs/policy-types/cluster-policy/verify-images/sigstore/)
- [ImageValidatingPolicy](https://kyverno.io/docs/policy-types/image-validating-policy/)

### Validation policies

`ValidatingPolicy` evaluates Kubernetes resources using CEL expressions. Common supply chain controls include registry allowlists, immutable image tags, and required workload metadata.

Policies can scope enforcement by namespace, resource kind, or operation type.

Relevant documentation:

- [Validate Rules](https://kyverno.io/docs/policy-types/cluster-policy/validate/)
- [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy/)

### Audit mode and policy reports

Policies can begin in `Audit` mode before moving to `Deny` enforcement. This allows teams to review violations and measure policy impact before blocking workloads.

Background scanning evaluates existing resources and records violations in `PolicyReport` resources for operational review and compliance tracking.

Relevant documentation:

- [Applying Policies](https://kyverno.io/docs/guides/applying-policies/)
- [Policy Reports](https://kyverno.io/docs/guides/reports/)

## Example use cases

### Require images from approved registries

Public registries may contain outdated, modified, or untrusted images. Restricting image sources to approved registries helps ensure workloads pass organizational scanning and review processes before deployment.

Use `ValidatingPolicy` with a registry allowlist. Start in `Audit` mode to identify non-compliant workloads before enforcing.

### Verify image signatures for production namespaces

Image tags alone do not prove authenticity. Signature verification confirms an image was produced by a trusted build pipeline and has not changed after signing.

Use `ImageValidatingPolicy` scoped to production namespaces. Pair with Sigstore keyless signing to avoid managing long-lived signing keys.

### Verify build provenance from trusted build systems

Provenance attestations record how an image was built, which workflow produced it, and which source revision was used. This supports SLSA compliance and improves audit visibility.

Use `ImageValidatingPolicy` with attestation verification. Require a valid SLSA provenance attestation signed by the CI system identity.

### Block mutable image tags

Mutable tags such as `latest` can point to different image digests over time. This makes deployments difficult to reproduce and audit.

Use `ValidatingPolicy` to deny image references using `:latest` or missing explicit tags. This is often a low-risk policy to introduce first in `Audit` mode.

### Require vulnerability scan attestations before deployment

Vulnerability scan results should be verified during admission, not only during image build.

Use `ImageValidatingPolicy` to verify signed vulnerability scan attestations before workloads are admitted. Configure attestation age limits to prevent stale scan results.

### Audit workloads that do not meet image trust requirements

Not every team can move directly to enforcement. Audit mode allows security teams to measure exposure and review violations before blocking deployments.

Use `validationActions: [Audit]` to record violations in `PolicyReport` resources without denying admission. Review reports with application teams before switching policies to `Deny`.

## Example Kyverno policies

The examples below cover common software supply chain security controls in Kubernetes environments. Replace registry prefixes, signing identities, and attestation values with values from your environment.

Start policies with `validationActions: [Audit]` before moving to `Deny` enforcement.

### Restrict image registries

Deny workloads that use images outside approved registries.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-image-registries
spec:
  validationActions:
    - Audit
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: >-
        object.spec.containers.all(container,
        container.image.startsWith("registry.myorg.com/") ||
        container.image.startsWith("gcr.io/myproject/"))
      message: >-
        Images must come from registry.myorg.com or gcr.io/myproject.
        Update the image reference or request an exemption.
```

This policy helps prevent workloads from pulling images from untrusted or unmanaged registries.

### Disallow mutable image tags

Deny workloads that use mutable image tags such as latest.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationActions:
    - Audit
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: >-
        object.spec.containers.all(container,
        (container.image.contains(":") &&
        !container.image.endsWith(":latest")) ||
        container.image.contains("@"))
      message: >-
        Images must specify an immutable version tag or digest.
        Replace ':latest' with a specific tag such as ':v1.2.3' or a digest.
```

:::note
Apply this policy in `Audit` mode first. It typically surfaces the highest number of violations across development workloads and gives teams a clear, low-effort remediation path.
:::

### Verify image signatures using keyless signing

Verify that workloads use images signed by a trusted CI pipeline identity.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: verify-image-signature
spec:
  validationActions:
    - Audit
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchImageReferences:
    - glob: 'registry.myorg.com/*'
  attestors:
    - name: github-actions
      cosign:
        keyless:
          identities:
            - issuer: 'https://token.actions.githubusercontent.com'
              subjectRegExp: 'https://github.com/myorg/.+'
        ctlog:
          url: 'https://rekor.sigstore.dev'
  validations:
    - expression: >-
        images.containers.map(image,
        verifyImageSignatures(image, [attestors.github-actions])).all(e, e > 0)
      message: >-
        Image signature verification failed. The image must be signed by a
        GitHub Actions workflow in the myorg organization.
```

This policy verifies that images were signed by a trusted GitHub Actions workflow identity.

### Verify SLSA provenance attestation

Require workloads to use images with verified SLSA provenance attestations.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: verify-slsa-provenance
spec:
  validationActions:
    - Audit
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchImageReferences:
    - glob: 'registry.myorg.com/*'
  attestors:
    - name: github-actions
      cosign:
        keyless:
          identities:
            - issuer: 'https://token.actions.githubusercontent.com'
              subjectRegExp: 'https://github.com/myorg/.+'
        ctlog:
          url: 'https://rekor.sigstore.dev'
  attestations:
    - type: https://slsa.dev/provenance/v0.2
      attestors:
        - name: github-actions
      conditions:
        - all:
            - key: '{{ buildType }}'
              operator: Equals
              value: 'https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml'
            - key: '{{ builder.id }}'
              operator: StartsWith
              value: 'https://github.com/myorg/'
  validations:
    - expression: >-
        images.containers.map(image,
        verifyImageAttestations(image, [attestors.github-actions],
        [attestations[0]])).all(e, e > 0)
      message: >-
        SLSA provenance attestation missing or invalid. Images in the production
        namespace must have a verified provenance record from the myorg pipeline.
```

This policy verifies that production workloads use images with trusted build provenance attestations.

## Outcome mapping

| User problem                          | Kyverno capability       | Example control                |
| ------------------------------------- | ------------------------ | ------------------------------ |
| Images may be tampered with           | Image verification       | Verify Cosign signatures       |
| Untrusted registries are used         | Validation policies      | Allow only approved registries |
| Mutable tags cause deployment drift   | Validation policies      | Block `latest` image tags      |
| No proof of image provenance          | Attestation verification | Require SLSA provenance        |
| Policies cannot be enforced safely    | Audit and enforce modes  | Start in `Audit` before `Deny` |
| No visibility into compliance posture | Policy reports           | Review `PolicyReport` results  |

## Related documentation

- [Verify Images](https://kyverno.io/docs/policy-types/cluster-policy/verify-images/sigstore/)
- [ImageValidatingPolicy](https://kyverno.io/docs/policy-types/image-validating-policy/)
- [Policy Reports](https://kyverno.io/docs/guides/reports/)
