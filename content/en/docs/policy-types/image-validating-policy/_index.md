---
title: ImageValidatingPolicy
description: >-
    Validate container images and their metadata
weight: 30
---

The Kyverno `ImageValidatingPolicy` type is a Kyverno policy type designed for verifying container image signatures and attestations. 
           | _                            | Kyverno CLI (unit), Chainsaw (e2e)          |

## Additional Fields

The `ImageValidatingPolicy` extends the [Kyverno ValidatingPolicy](/docs/policy-types/validating-policy) with the following additional fields for image verification features. 

A complete reference is provided in the [API specification](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.ImageValidatingPolicy)


### images

When `Kubernetes` resources are evaluated images for pods and pod templates are automatically extracted for processing. For custom resources, or for `JSON` payloads, the `images` field can be used to declare CEL expressions that extract images from the payload.

For example, this 

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageVerificationPolicy
metadata:
  name: sample
spec:
  evaluation:
    mode: JSON
  imageRules:
    - glob: ghcr.io/*
  images:
    - name: imagerefs
      expression: "[object.imageReference]"
  ...
```


### imageRules

The `spec.imageRules` field defines rules for matching and validating container images. It allows specifying glob patterns for image references and configuring attestors for image verification.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: check-images
spec:
  images: 
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
```

The `glob` pattern matches image references using globbing. Optionally, a `cel` expression can be used to match images.



### attestors

The `attestors` field declares trusted . 

### attestations

The `attestations` field specifies additional metadata to verify, such as SBOMs.

### mutateDigest

### verifyDigest

### required



## Kyverno CEL Libraries

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex policy logic and advanced features for image validation.

### Image Verification Functions

Kyverno provides specialized functions for verifying image signatures and attestations:

| CEL Expression | Purpose |
|----------------|---------|
| `verifyImageSignatures(image, [attestors.notary])` | Verify image signatures using specified attestors |
| `verifyAttestationSignatures(image, attestations.sbom, [attestors.notary])` | Verify attestation signatures for specific metadata |
| `payload(image, attestations.sbom).bomFormat == 'CycloneDX'` | Validate SBOM format and content |

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
        images.containers.map(image, verifyAttestationSignatures(image, attestations.sbom, [attestors.notary])).all(e, e > 0)
      message: failed to verify attestation with notary cert
    - expression: >-
        images.containers.map(image, payload(image, attestations.sbom).bomFormat == 'CycloneDX').all(e, e)
      message: sbom is not a cyclone dx sbom
```

This policy ensures that:
1. All images are signed by the specified notary attestor
2. All images have valid SBOM attestations
3. All SBOMs are in CycloneDX format
