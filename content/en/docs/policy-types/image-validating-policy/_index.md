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
kind: ImageVerificationPolicy
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


### imageRules

The `spec.imageRules` field defines rules for matching container images. It allows specifying glob patterns or CEL expressions that specify which images the policy should match.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  images: 
  imageRules:
    - glob: "ghcr.io/kyverno/*"        # Match images using glob pattern
    - cel: "image.registry == 'ghcr.io'"  # Match using CEL expression
  ...
```

### attestors

The `attestors` field declares trusted signing authorities, such as keys or certificates.

**Cosign attestors:** These use public keys, keyless signing, transparency logs, certificates, or TUF-based metadata for image validation

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
  attestors:
  - name: cosign                      # A unique name to identify this attestor
    cosign:
      key:                            # Public key-based verification
        secretRef:                    # Reference to a Kubernetes secret that holds the cosign public key
          name: cosign-pubkey-secret
          namespace: kyverno
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
        root:                         # Root certificate for verifying signatures
          data: |                     # PEM-encoded certificate
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

      certificate:                    # Certificate-based verification
        cert: |                       # Inline signing certificate
          -----BEGIN CERTIFICATE-----
          ...
          -----END CERTIFICATE-----
        certChain: |                 # Certificate chain associated with the signer
          -----BEGIN CERTIFICATE-----
          ...
          -----END CERTIFICATE-----

      source:                         # Optional metadata to constrain image source
        repository: "ghcr.io/myorg/myimage"   # Limit to specific image repo
        pullSecrets:                  # Kubernetes secrets used to pull private images
          - name: my-registry-secret
        tagPrefix: "v1."              # Restrict verification to images starting with this tag

      tuf:                            # TUF-based trust metadata (for cosign + TUF)
        root:
          path: "/var/run/tuf/root.json"    # Path to root metadata file on disk
          data: |                           # Inline TUF root metadata
            {
              "signed": {...},
              "signatures": [...]
            }
        mirror: "https://tuf.example.org"   # URL of TUF mirror to fetch metadata
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
  imageRules:
    - glob: ghcr.io/*                         
  attestors:
        - name: notary                        # Unique identifier for this attestor
          notary:
            certs: |                          # Certificate(s) used to verify the signature
              -----BEGIN CERTIFICATE-----
              MIIBjTCCATOgAwIBAgIUdMiN3gC...
              -----END CERTIFICATE-----
            tsaCerts: |                       # Optional: Time Stamp Authority (TSA) certificates
              -----BEGIN CERTIFICATE-----
              MIIC4jCCAcqgAwIBAgIQAm3T2tWk...
              -----END CERTIFICATE-----

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
  imageRules:
    - glob: ghcr.io/*
  attestors:
        - name: notary
          notary:
            certs: |-
              -----BEGIN CERTIFICATE-----
              MIIBjTCCATOgAwIBAgIUdMiN3gC...
              -----END CERTIFICATE-----
   attestations:
        - name: sbom                                # Logical name for this attestation
          referrer:                                 # Refers to OCI artifact by media type
            type: sbom/cyclone-dx                   # Supported types: sbom/spdx, sbom/cyclone-dx, vuln, custom
        - name: toto                                 # Another attestation named `toto`
          intoto:
            type: https://example.com/attestations/slsa-provenance/v0.2  # URI of the in-toto predicate type

```

### mutateDigest

The `mutateDigest` field enables, or disables, mutating the image reference to replace the tag with a digest. Image tags are mutable and as a best practice digests should be used prior to deployment.

### verifyDigest

The `verifyDigest` field enables, or disables, verififcation that all matching images are using a digest.

### required

The `required` field enables, or disables, a check that all images must be validated by one or more policies.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  imageRules:
    - glob: ghcr.io/*
  mutateDigest: true
  required: true
  verifyDigest: true

```

### credentials
 
Credentials specify the authentication information required to securely access and interact with a registry.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  imageRules:
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
| `payload(image, attestations.sbom).bomFormat == 'CycloneDX'` | Extract the in-toto payload |
 

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
  imageRules:
    - glob: ghcr.io/*
      attestors:
        - name: notary
          notary:
            certs: |-
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
        images.containers.map(image, payload(image, attestations.sbom).bomFormat == 'CycloneDX').all(e, e)
      message: sbom is not a cyclone dx sbom
```

This policy ensures that:
1. All images are signed by the specified notary attestor
2. All images have valid SBOM attestations
3. All SBOMs are in CycloneDX format
