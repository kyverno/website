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
    - glob: ghcr.io/*
  ...
```

### attestors

The `attestors` field declares trusted signing authorities, such as keys or certificates.

### attestations

The `attestations` field specifies additional metadata to validate.

### mutateDigest

The `mutateDigest` field enables, or disables, mutating the image reference to replace the tag with a digest. Image tags are mutable and as a best practice digests should be used prior to deployment.

### verifyDigest

The `verifyDigest` field enables, or disables, verififcation that all matching images are using a digest.

### required

The `required` field enables, or disables, a check that all images must be validated by one or more policies.

## Kyverno CEL Libraries

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex policy logic and advanced features for image validation. In addition to common [Kyverno CEL Libraries](/docs/policy-types/validating-policy/#kyverno-cel-libraries) the following additional libraries are supported for ImageValidatingPolicy types. 

### Image Verification Library

Kyverno provides specialized functions for verifying image signatures and attestations:

| CEL Expression | Purpose |
|----------------|---------|
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
