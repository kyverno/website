---
title: ImageValidatingPolicy
description: >-
    Validate container images and their metadata
weight: 0
---

The Kyverno `ImageValidatingPolicy` type is a Kyverno policy type designed for verifying container image signatures and attestations. 

## Additional Fields

The `ImageValidatingPolicy` extends the [Kyverno ValidatingPolicy](/docs/policy-types/validating-policy) with the following additional fields for image verification features. A complete reference is provided in the [API specification](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.ImageValidatingPolicy)


### images

When `Kubernetes` resources are evaluated images for pods and pod templates are automatically extracted for processing. For custom resources, or for `JSON` payloads, the `images` field can be used to declare CEL expressions that extract images from the payload.

For example, this policy declaration will process the image specified in the `imageReference` field:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: sample
spec:
  evaluation:
    mode: JSON
  images:
    - name: imagerefs
      expression: "[object.imageReference]"
  ...
```


### matchImageReferences

The `spec.matchImageReferences` field defines rules for matching container images. It allows specifying glob patterns or CEL expressions that specify which images the policy should match.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  matchImageReferences:  # At least one sub-field is required
    - glob: "ghcr.io/kyverno/*"        # Match images using glob pattern
    - expression: "image.registry == 'ghcr.io'"  # Match using CEL expression
  ...
```

### attestors

The `attestors` field declares trusted signing authorities, such as keys or certificates.

**Cosign attestors:** These use public keys, keyless signing, transparency logs, certificates, or TUF-based metadata for image validation.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  variables:
    - name: cm
      expression: >-
        resource.Get("v1", "configmaps", object.metadata.namespace, "keys")
  attestors:
  - name: cosign                      # A unique name to identify this attestor
    cosign:
      key:                            # Public key-based verification and At least one sub-field is required
        expression: variables.cm.data.pubKey    # CEL expression that resolves to the public key
        kms: "gcpkms://..."           # KMS URI for key verification (e.g., GCP KMS, AWS KMS)
        hashAlgorithm: "sha256"       # Optional hash algorithm used with the key
        data: |                       # Direct inline public key data (optional if secretRef or kms is used)
          -----BEGIN PUBLIC KEY-----
          ...
          -----END PUBLIC KEY-----

      keyless:                        # Keyless signing verification (OIDC-based)
        identities:                   # List of accepted signing identities
          - subject: "https://github.com/myorg/myrepo/.github/workflows/deploy.yaml@refs/heads/main"
            issuer: "https://token.actions.githubusercontent.com"
            subjectRegExp: ".*github\\.com/.*/.*/.github/workflows/.*"  # Optional regex for subject matching
            issuerRegExp: "https://token\\.actions\\.githubusercontent\\.com"  # Optional regex for issuer matching
        root: |                       # Roots is an optional set of PEM encoded trusted root certificates. If not provided, the system roots are used.
            -----BEGIN CERTIFICATE-----
            ...
            -----END CERTIFICATE-----

      ctlog:                          # Transparency log settings (e.g., Rekor)
        url: "https://rekor.sigstore.dev"
        rekorPubKey: |                # Public key for verifying Rekor entries
          -----BEGIN PUBLIC KEY-----
          ...
          -----END PUBLIC KEY-----
        ctLogPubKey: |                # Public key for verifying CT log entries (optional)
          -----BEGIN PUBLIC KEY-----
          ...
          -----END PUBLIC KEY-----
        tsaCertChain: |              # Certificate chain for Time Stamp Authority (optional)
          -----BEGIN CERTIFICATE-----
          ...
          -----END CERTIFICATE-----
        insecureIgnoreTlog: false     # Skip TLog verification (for testing only)
        insecureIgnoreSCT: false      # Skip Signed Certificate Timestamp (for testing only)

      certificate:                    # Certificate-based verification and At least one sub-field is required
        cert:
          value: |                       # Inline signing certificate
            -----BEGIN CERTIFICATE-----
            ...
            -----END CERTIFICATE-----
          expression: variables.cm.data.cert   # CEL expression resolving to certificate
        certChain:        # At least one sub-field is required
          value: |                 # Certificate chain associated with the signer o
            -----BEGIN CERTIFICATE-----
            ...
            -----END CERTIFICATE-----
          expression: variables.cm.data.certChain   # CEL expression resolving to certificate

      source:                         # Optional metadata to constrain image source (optional)
        repository: "ghcr.io/myorg/myimage"   # Limit to specific image repo
        pullSecrets:                  # Kubernetes secrets used to access the registry
          - name: my-registry-secret
        tagPrefix: "v1."              # Restrict verification to images starting with this tag

      tuf: 
        root:
          path: "/var/run/tuf/root.json"  # Local path to TUF root metadata (optional)
          data: |                         # Optional base64-encoded TUF root metadata (optional)
            eyJzaWduZWQiOiB7Li4ufSwgInNpZ25hdHVyZXMiOiBbLi4uXX0=
        mirror: "https://tuf.example.org" # Sigstore TUF mirror URL (optional)

  ...

```
**Notary attestors:** These use certificates and optional Time Stamp Authority (TSA) certificates for image signature verification.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  variables:
    - name: cm
      expression: >-
        resource.Get("v1", "configmaps", object.metadata.namespace, "keys")
     expression:
   - name: 
     expression:
  matchImageReferences:
    - glob: ghcr.io/*                         
  attestors:
        - name: notary                        # Unique identifier for this attestor
          notary:
            certs:      # At least one sub-field is required
              value: |                          # Certificate(s) used to verify the signature or CEL expression resolving to  certificate(s)
                -----BEGIN CERTIFICATE-----
                MIIBjTCCATOgAwIBAgIUdMiN3gC...
                -----END CERTIFICATE-----

              expression: variables.cm.data.cert  # CEL expression resolving to  certificate(s)

            tsaCerts:   # At least one sub-field is required
               value: |                       # Optional: Time Stamp Authority (TSA) certificates 
                -----BEGIN CERTIFICATE-----
                MIIC4jCCAcqgAwIBAgIQAm3T2tWk...
                -----END CERTIFICATE-----

               expression: variables.cm.data.tsaCert #  Optional: CEL expression resolving to TSA certificate(s)

            

```

### attestations

The `attestations` field specifies additional metadata to validate.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  matchImageReferences:
    - glob: ghcr.io/*
  attestors:
        - name: notary
          notary:
            certs:
              value: |-
                  -----BEGIN CERTIFICATE-----
                  MIIBjTCCATOgAwIBAgIUdMiN3gC...
                  -----END CERTIFICATE-----
  attestations:
    - name: sbom                                # Logical name for this attestation
      referrer:                                 # Uses OCI artifact type for verification
        type: sbom/cyclone-dx                   

    - name: toto                                # Another attestation named `toto`
      intoto:
        type: https://example.com/attestations/slsa-provenance/v0.2  # Predicate type URI for in-toto format


```

### validationConfigurations

The `validationConfigurations` field defines settings for mutating image tags to digests, verifying that images are using digests, and enforcing image validation requirements across policies.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  matchImageReferences:
    - glob: ghcr.io/*
  validationConfigurations:
    mutateDigest: true  # Mutates image tags to digests (recommended to avoid mutable tags).
    required: true       # Enforces that images must be validated according to policies.
    verifyDigest: true  # Ensures that images are verified with a digest instead of tags.

```

### credentials
 
Credentials specify the authentication information required to securely access and interact with a registry.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  matchImageReferences:
    - glob: ghcr.io/*
  credentials:
    allowInsecureRegistry: false  # Deny insecure access to registries
    providers: # specifies whose authentication providers are provided
      - "default"  
      - "google"   
      - "azure"    
      - "amazon"
      - "github"

    secrets:
      - "my-registry-secret"  # Secrets specifies a list of secrets that are provided for credentials. Secrets must live in the Kyverno namespace.

```

## Kyverno CEL Libraries

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex policy logic and advanced features for image validation. In addition to common [Kyverno CEL Libraries](/docs/policy-types/validating-policy/#kyverno-cel-libraries) the following additional libraries are supported for ImageValidatingPolicy types. 

### Image Verification Library

Kyverno provides specialized functions for verifying image signatures and attestations:

| CEL Expression | Purpose |
|----------------|---------|
| `images.containers` | Retrieves all container images in the resource |
| `verifyImageSignatures(image, [attestors.notary])` | Verify image signatures using specified attestors |
| `verifyAttestationSignatures(image, attestations.sbom, [attestors.notary])` | Verify attestation signatures for specific metadata |
| `extractPayload(image, attestations.sbom).bomFormat == 'CycloneDX'` | Extract the in-toto payload |

The following policy demonstrates the use of these functions:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  matchImageReferences:
    - glob: ghcr.io/*
      attestors:
        - name: notary
          notary:
            certs:
              value: |-
                  -----BEGIN CERTIFICATE-----
                  ...
                  -----END CERTIFICATE-----
      attestations:
        - name: sbom
          referrer:
            type: sbom/cyclone-dx
  validations:
    - expression: >-
        images.containers.map(image, verifyImageSignatures(image, [attestors.notary])).all(e, e > 0)
      message: failed to verify image with notary cert
    - expression: >-
        images.containers.map(image, verifyAttestationSignatures(image, 
           attestations.sbom, [attestors.notary])).all(e, e > 0)
      message: failed to verify attestation with notary cert
    - expression: >-
        images.containers.map(image, extractPayload(image, attestations.sbom).bomFormat == 'CycloneDX').all(e, e)
      message: sbom is not a cyclone dx sbom
```

This policy ensures that:
1. All images are signed by the specified notary attestor
2. All images have valid SBOM attestations
3. All SBOMs are in CycloneDX format

Note: `extractPayload()` requires prior attestation verification via `verifyAttestationSignatures()`. If not verified, it will return an error.

#### Cosign Keyless Signature and Attestation Verification

This sample policy demonstrates how to verify container image signatures using Cosign keyless signing and validate the presence of a vulnerability scan attestation.

Kyverno supports the use of regular expressions in identities.subjectRegExp and identities.issuerRegExp fields when configuring keyless attestors

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: require-vulnerability-scan
spec:
  validationActions: [Audit]
  webhookConfiguration:
    timeoutSeconds: 15
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE", "UPDATE"]
  matchImageReferences:
    - glob: "ghcr.io/myorg/myrepo:*"
  attestors:
    - name: cosign
      cosign:
          keyless:
            identities:
              - subject: "https://github.com/myorg/myrepo/.github/workflows/*"
                issuer: "https://token.actions.githubusercontent.com"
          ctlog:
               url: "https://rekor.sigstore.dev"
  attestations:
   - name: cosign-attes
     intoto:
       type: cosign.sigstore.dev/attestation/vuln/v1
  validations:
    - expression: >-
        images.containers.map(image, verifyImageSignatures(image,  [attestors.cosign])).all(e, e > 0)
      message: "Failed image signature verification"
    - expression: >-
        images.containers.map(image, verifyAttestationSignatures(image, [attestations.cosign-attes], [attestors.cosign])).all(e, e > 0)
      message: "Failed to verify vulnerability scan attestation with Cosign keyless"

```

#### Cosign Public Key Signature Verification

This policy ensures that container images are signed with a specified Cosign public key before being admitted.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: verify-image-ivpol
spec:
  webhookConfiguration:
    timeoutSeconds: 15
  evaluation:
   background:
    enabled: false
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  matchImageReferences:
        - glob : "docker.io/kyverno/kyverno*"
  attestors:
  - name: cosign
    cosign:
     key:
      data: |
                -----BEGIN PUBLIC KEY-----
                MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE6QsNef3SKYhJVYSVj+ZfbPwJd0pv
                DLYNHXITZkhIzfE+apcxDjCCkDPcJ3A3zvhPATYOIsCxYPch7Q2JdJLsDQ==
                -----END PUBLIC KEY-----
  validations:
    - expression: >-
       images.containers.map(image, verifyImageSignatures(image, [attestors.cosign])).all(e ,e > 0)
      message: >-
       failed the image Signature verification

```
 
 Note: To learn how to sign container images using Cosign with keyless signing, refer to the [official Cosign documentation](https://docs.sigstore.dev/cosign/signing/signing_with_containers/).

 Policies are applied cluster-wide to help secure your cluster. However, there may be times when teams or users need to test specific tools or resources. In such cases, users can use [PolicyException](../../exceptions/_index.md#policyexceptions-with-cel-expressions) to bypass policies without modifying or tweaking the policies themselves. This ensures that your policies remain secure while providing the flexibility to bypass them when needed.
