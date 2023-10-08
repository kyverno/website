---
title: Notary
description: >
  Verify CNCF Notary format signatures using X.509 certificates.
weight: 10
---

[Notary](https://notaryproject.dev/) is a CNCF project that provides a specification and tooling for securing software supply chains.

The [Notation CLI](https://github.com/notaryproject/notation) can be used to sign images and attestations in a CI/CD pipeline. A quick start guide providing a complete example of signing and verifying a container image using Notation can be found [here](https://notaryproject.dev/docs/quickstart/).

The Notation CLI can also be used to inspect details of the container image signature.

```sh
notation inspect ghcr.io/kyverno/test-verify-image@sha256:b31bfb4d0213f254d361e0079deaaebefa4f82ba7aa76ef82e90b4935ad5b105
Inspecting all signatures for signed artifact
ghcr.io/kyverno/test-verify-image@sha256:b31bfb4d0213f254d361e0079deaaebefa4f82ba7aa76ef82e90b4935ad5b105
└── application/vnd.cncf.notary.signature
    └── sha256:7f870420d92765b42cec0f71ee8e25bf39b692f64d95d6f6607e9e6e54300265
        ├── media type: application/jose+json
        ├── signature algorithm: RSASSA-PSS-SHA-256
        ├── signed attributes
        │   ├── signingScheme: notary.x509
        │   └── signingTime: Mon May 22 14:45:04 2023
        ├── user defined attributes
        │   └── (empty)
        ├── unsigned attributes
        │   └── signingAgent: Notation/1.0.0
        ├── certificates
        │   └── SHA256 fingerprint: da1f2d7d648dfacc7ebd59f98a9f35c753c331d80ca4280bb94060f4af4a5357
        │       ├── issued to: CN=test,O=Notary,L=Seattle,ST=WA,C=US
        │       ├── issued by: CN=test,O=Notary,L=Seattle,ST=WA,C=US
        │       └── expiry: Thu May 19 21:15:18 2033
        └── signed artifact
            ├── media type: application/vnd.docker.distribution.manifest.v2+json
            ├── digest: sha256:b31bfb4d0213f254d361e0079deaaebefa4f82ba7aa76ef82e90b4935ad5b105
            └── size: 938
```

You can also use an OCI registry client to discover signatures and attestations for an image.

```sh
oras discover ghcr.io/kyverno/test-verify-image:signed -o tree
ghcr.io/kyverno/test-verify-image:signed
├── application/vnd.cncf.notary.signature
│   └── sha256:7f870420d92765b42cec0f71ee8e25bf39b692f64d95d6f6607e9e6e54300265
├── vulnerability-scan
│   └── sha256:f89cb7a0748c63a674d157ca84d725ff3ac09cc2d4aee9d0ec4315e0fe92a5fd
│       └── application/vnd.cncf.notary.signature
│           └── sha256:ec45844601244aa08ac750f44def3fd48ddacb736d26b83dde9f5d8ac646c2f3
└── sbom/cyclone-dx
    └── sha256:8cad9bd6de426683424a204697dd48b55abcd6bb6b4930ad9d8ade99ae165414
        └── application/vnd.cncf.notary.signature
            └── sha256:61f3e42f017b72f4277c78a7a42ff2ad8f872811324cd984830dfaeb4030c322
```

## Verifying Image Signatures

The following policy checks whether an image is signed with a valid X.509 key that matches the provided public certificate.

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: check-image-notary
spec:
  validationFailureAction: Enforce
  webhookTimeoutSeconds: 30
  failurePolicy: Fail  
  rules:
    - name: verify-signature-notary
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - type: Notary
        imageReferences:
        - "ghcr.io/kyverno/test-verify-image*"
        attestors:
        - count: 1
          entries:
          - certificates:
              cert: |-
                -----BEGIN CERTIFICATE-----
                MIIDTTCCAjWgAwIBAgIJAPI+zAzn4s0xMA0GCSqGSIb3DQEBCwUAMEwxCzAJBgNV
                BAYTAlVTMQswCQYDVQQIDAJXQTEQMA4GA1UEBwwHU2VhdHRsZTEPMA0GA1UECgwG
                Tm90YXJ5MQ0wCwYDVQQDDAR0ZXN0MB4XDTIzMDUyMjIxMTUxOFoXDTMzMDUxOTIx
                MTUxOFowTDELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAldBMRAwDgYDVQQHDAdTZWF0
                dGxlMQ8wDQYDVQQKDAZOb3RhcnkxDTALBgNVBAMMBHRlc3QwggEiMA0GCSqGSIb3
                DQEBAQUAA4IBDwAwggEKAoIBAQDNhTwv+QMk7jEHufFfIFlBjn2NiJaYPgL4eBS+
                b+o37ve5Zn9nzRppV6kGsa161r9s2KkLXmJrojNy6vo9a6g6RtZ3F6xKiWLUmbAL
                hVTCfYw/2n7xNlVMjyyUpE+7e193PF8HfQrfDFxe2JnX5LHtGe+X9vdvo2l41R6m
                Iia04DvpMdG4+da2tKPzXIuLUz/FDb6IODO3+qsqQLwEKmmUee+KX+3yw8I6G1y0
                Vp0mnHfsfutlHeG8gazCDlzEsuD4QJ9BKeRf2Vrb0ywqNLkGCbcCWF2H5Q80Iq/f
                ETVO9z88R7WheVdEjUB8UrY7ZMLdADM14IPhY2Y+tLaSzEVZAgMBAAGjMjAwMAkG
                A1UdEwQCMAAwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA0G
                CSqGSIb3DQEBCwUAA4IBAQBX7x4Ucre8AIUmXZ5PUK/zUBVOrZZzR1YE8w86J4X9
                kYeTtlijf9i2LTZMfGuG0dEVFN4ae3CCpBst+ilhIndnoxTyzP+sNy4RCRQ2Y/k8
                Zq235KIh7uucq96PL0qsF9s2RpTKXxyOGdtp9+HO0Ty5txJE2txtLDUIVPK5WNDF
                ByCEQNhtHgN6V20b8KU2oLBZ9vyB8V010dQz0NRTDLhkcvJig00535/LUylECYAJ
                5/jn6XKt6UYCQJbVNzBg/YPGc1RF4xdsGVDBben/JXpeGEmkdmXPILTKd9tZ5TC0
                uOKpF5rWAruB5PCIrquamOejpXV9aQA/K2JQDuc0mcKz
                -----END CERTIFICATE-----
```

With this policy configured, Kyverno will verify matching container image signatures and only allow the pod to be configured if the signatures are valid.

```sh
kubectl run test --image=ghcr.io/kyverno/test-verify-image:signed --dry-run=server
pod/test created (server dry run)
```

Kyverno will also mutate the pod to replace the image tag with its digest.

```sh
kubectl run test --image=ghcr.io/kyverno/test-verify-image:signed --dry-run=server -o yaml | grep "image: "
  - image: ghcr.io/kyverno/test-verify-image:signed@sha256:b31bfb4d0213f254d361e0079deaaebefa4f82ba7aa76ef82e90b4935ad5b105
```

Attempting to run a pod with an unsigned image will be blocked.

```sh
kubectl run test --image=ghcr.io/kyverno/test-verify-image:unsigned --dry-run=server
Error from server: admission webhook "mutate.kyverno.svc-fail" denied the request:

resource Pod/default/test was blocked due to the following policies

check-image-notary:
  verify-signature-notary: 'failed to verify image ghcr.io/kyverno/test-verify-image:unsigned:
    .attestors[0].entries[0]: failed to verify ghcr.io/kyverno/test-verify-image@sha256:74a98f0e4d750c9052f092a7f7a72de7b20f94f176a490088f7a744c76c53ea5:
    no signature is associated with "ghcr.io/kyverno/test-verify-image@sha256:74a98f0e4d750c9052f092a7f7a72de7b20f94f176a490088f7a744c76c53ea5",
    make sure the image was signed successfully'
```

{{% alert title="Tip" color="info" %}}
You can manage public keys and certificates as external data in a ConfigMap. See [Variables from ConfigMaps](/docs/writing-policies/external-data-sources/#variables-from-configmaps) for details.
{{% /alert %}}

## Verifying Image Attestations

Kyverno does not support verifying attestations signed by Notary. This feature is being implemented and scheduled for the [next minor release](https://github.com/kyverno/kyverno/milestones?direction=asc&sort=due_date&state=open).
