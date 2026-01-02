---
title: Notary
description: Verify CNCF Notary format signatures using X.509 certificates.
sidebar:
  order: 10
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
oras discover -o tree ghcr.io/kyverno/test-verify-image:signed
ghcr.io/kyverno/test-verify-image@sha256:b31bfb4d0213f254d361e0079deaaebefa4f82ba7aa76ef82e90b4935ad5b105
├── application/vnd.cncf.notary.signature
│   ├── sha256:7f870420d92765b42cec0f71ee8e25bf39b692f64d95d6f6607e9e6e54300265
│   └── sha256:f7d941ed9e93a1ff1d5dee3b091144a87dae1d73481d5be93aa65258a110c689
├── vulnerability-scan
│   └── sha256:f89cb7a0748c63a674d157ca84d725ff3ac09cc2d4aee9d0ec4315e0fe92a5fd
│       └── application/vnd.cncf.notary.signature
│           └── sha256:ec45844601244aa08ac750f44def3fd48ddacb736d26b83dde9f5d8ac646c2f3
├── sbom/cyclone-dx
│   └── sha256:8cad9bd6de426683424a204697dd48b55abcd6bb6b4930ad9d8ade99ae165414
│       └── application/vnd.cncf.notary.signature
│           └── sha256:61f3e42f017b72f4277c78a7a42ff2ad8f872811324cd984830dfaeb4030c322
├── application/vnd.cyclonedx+json
│   └── sha256:aa886b475b431a37baa0e803765a9212f0accece0b82a131ebafd43ea78fa1f8
│       └── application/vnd.cncf.notary.signature
│           ├── sha256:00c5f96577878d79b545d424884886c37e270fac5996f17330d77a01a96801eb
│           └── sha256:f3dc4687f5654ea8c2bc8da4e831d22a067298e8651fb59d55565dee58e94e2d
├── cyclonedx/vex
│   └── sha256:c058f08c9103bb676fcd0b98e41face2436e0a16f3d1c8255797b916ab5daa8a
│       └── application/vnd.cncf.notary.signature
│           └── sha256:79edc8936a4fb8758b9cb2b8603a1c7903f53261c425efb0cd85b09715eb6dfa
└── trivy/scan
    └── sha256:a75ac963617462fdfe6a3847d17e5519465dfb069f92870050cce5269e7cbd7b
        └── application/vnd.cncf.notary.signature
            └── sha256:d1e2b2ba837c164c282cf389594791a190df872cf7712b4d91aa10a3520a8460
```

## Verifying Image Signatures

The following policy checks whether an image is signed with a valid X.509 key that matches the provided public certificate.

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: check-image-notary
spec:
  webhookConfiguration:
    failurePolicy: Fail
    timeoutSeconds: 30
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
            - 'ghcr.io/kyverno/test-verify-image*'
          failureAction: Enforce
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

{% aside title="Tip" type="note" %}
You can manage public keys and certificates as external data in a ConfigMap. See [Variables from ConfigMaps](/docs/policy-types/cluster-policy/external-data-sources#variables-from-configmaps) for details.
{% /aside %}

## Verifying Image Attestations

Consider the following image: `ghcr.io/kyverno/test-verify-image:signed`

```
ghcr.io/kyverno/test-verify-image:signed
├── application/vnd.cncf.notary.signature
│   ├── sha256:7f870420d92765b42cec0f71ee8e25bf39b692f64d95d6f6607e9e6e54300265
│   └── sha256:f7d941ed9e93a1ff1d5dee3b091144a87dae1d73481d5be93aa65258a110c689
├── vulnerability-scan
│   └── sha256:f89cb7a0748c63a674d157ca84d725ff3ac09cc2d4aee9d0ec4315e0fe92a5fd
│       └── application/vnd.cncf.notary.signature
│           └── sha256:ec45844601244aa08ac750f44def3fd48ddacb736d26b83dde9f5d8ac646c2f3
├── sbom/cyclone-dx
│   └── sha256:8cad9bd6de426683424a204697dd48b55abcd6bb6b4930ad9d8ade99ae165414
│       └── application/vnd.cncf.notary.signature
│           └── sha256:61f3e42f017b72f4277c78a7a42ff2ad8f872811324cd984830dfaeb4030c322
├── application/vnd.cyclonedx+json
│   └── sha256:aa886b475b431a37baa0e803765a9212f0accece0b82a131ebafd43ea78fa1f8
│       └── application/vnd.cncf.notary.signature
│           ├── sha256:00c5f96577878d79b545d424884886c37e270fac5996f17330d77a01a96801eb
│           └── sha256:f3dc4687f5654ea8c2bc8da4e831d22a067298e8651fb59d55565dee58e94e2d
├── cyclonedx/vex
│   └── sha256:c058f08c9103bb676fcd0b98e41face2436e0a16f3d1c8255797b916ab5daa8a
│       └── application/vnd.cncf.notary.signature
│           └── sha256:79edc8936a4fb8758b9cb2b8603a1c7903f53261c425efb0cd85b09715eb6dfa
└── trivy/scan
    └── sha256:a75ac963617462fdfe6a3847d17e5519465dfb069f92870050cce5269e7cbd7b
        └── application/vnd.cncf.notary.signature
            └── sha256:d1e2b2ba837c164c282cf389594791a190df872cf7712b4d91aa10a3520a8460
```

This image has:

1. A notary signature.
2. A vulnerability scan report, signed using notary.
3. A CycloneDX SBOM, signed using notary.
4. A CycloneDX VEX report, signed using notary.
5. A Trivy scan report, signed using notary.

This policy checks the signature in the repo `ghcr.io/kyverno/test-verify-image` and ensures that it has been signed by verifying its signature against the provided certificates:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image-attestation
spec:
  webhookConfiguration:
    failurePolicy: Fail
    timeoutSeconds: 30
  rules:
    - name: verify-attestation-notary
      match:
        any:
          - resources:
              kinds:
                - Pod
      context:
        - name: keys
          configMap:
            name: keys
            namespace: kyverno
      verifyImages:
        - type: Notary
          imageReferences:
            - 'ghcr.io/kyverno/test-verify-image*'
          failureAction: Enforce
          attestations:
            - type: sbom/cyclone-dx
              attestors:
                - entries:
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
              conditions:
                - all:
                    - key: '{{ components[].licenses[].expression }}'
                      operator: AllIn
                      value: ['GPL-3.0']
```

After this policy is applied, Kyverno will verify the signature on the sbom/cyclone-dx attestation and check if the license version of all the components in the SBOM is `GPL-3.0`.

```sh
kubectl run test --image=ghcr.io/kyverno/test-verify-image:signed --dry-run=server
pod/test created (server dry run)
```

### Validation across multiple image attestations

Consider the image: `ghcr.io/kyverno/test-verify-image:signed` which image has:

1. A notary signature.
2. A vulnerability scan report, signed using notary.
3. A CycloneDX VEX report, signed using notary.

This policy checks:

1. The signature in the repo `ghcr.io/kyverno/test-verify-image`
2. Ensures that it has a vulnerability scan report of type `trivy/vulnerability`, and a CycloneDX VEX report of type `vex/cyclone-dx`, both are signed using the given certificate.
3. All the vulnerabilities found in the trivy scan report should be allowed in the vex report.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image-attestation
spec:
  validationFailureAction: Enforce
  webhookTimeoutSeconds: 30
  failurePolicy: Fail
  rules:
    - name: verify-attestation-notary
      match:
        any:
          - resources:
              kinds:
                - Pod
      context:
        - name: keys
          configMap:
            name: keys
            namespace: notary-verify-attestation
      verifyImages:
        - type: Notary
          imageReferences:
            - 'ghcr.io/kyverno/test-verify-image*'
          attestations:
            - type: trivy/vulnerability
              name: trivy
              attestors:
                - entries:
                    - certificates:
                        cert: |-
                          -----BEGIN CERTIFICATE-----
                          MIIDmDCCAoCgAwIBAgIUCntgF4FftePAhEa6nZTsu/NMT3cwDQYJKoZIhvcNAQEL
                          BQAwTDELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAldBMRAwDgYDVQQHDAdTZWF0dGxl
                          MQ8wDQYDVQQKDAZOb3RhcnkxDTALBgNVBAMMBHRlc3QwHhcNMjQwNjEwMTYzMTQ2
                          WhcNMzQwNjA4MTYzMTQ2WjBMMQswCQYDVQQGEwJVUzELMAkGA1UECAwCV0ExEDAO
                          BgNVBAcMB1NlYXR0bGUxDzANBgNVBAoMBk5vdGFyeTENMAsGA1UEAwwEdGVzdDCC
                          ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJkEGqbILiWye6C1Jz+jwwDY
                          k/rovpXzxS+EQDvfj/YKvx37Kr4cjboJORu3wtzICWhPUtVWZ21ShfjerKgNq0iB
                          mrlF4cqz2KcOfuUT3XBglH/NwhEAqOrGPQrMsoQEFWgnilr0RTc+j4vDnkdkcTj2
                          K/qPhQHRAeb97TdvFCqcZfAGqiOVUqzDGxd2INz/fJd4/nYRX3LJBn9pUGxqRwZV
                          ElP5B/aCBjJDdh6tAElT5aDnLGAB+3+W2YwG342ELyAl2ILpbSRUpKLNAfKEd7Nj
                          1moIl4or5AIlTkgewZ/AK68HPFJEV3SwNbzkgAC+/mLVCD8tqu0o0ziyIUJtoQMC
                          AwEAAaNyMHAwHQYDVR0OBBYEFFTIzCppwv0vZnAVmETPm1CfMdcYMB8GA1UdIwQY
                          MBaAFFTIzCppwv0vZnAVmETPm1CfMdcYMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQD
                          AgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA0GCSqGSIb3DQEBCwUAA4IBAQB8/vfP
                          /TQ3X80JEZDsttdvd9NLm08bTJ/T+nh0DIiV10aHymQT9/u+iahfm1+7mj+uv8LS
                          Y63LepQCX5p9SoFzt513pbNYXMBbRrOKpth3DD49IPL2Gce86AFGydfrakd86CL1
                          9MhFeWhtRf0KndyUX8J2s7jbpoN8HrN4/wZygiEqbQWZG8YtIZ9EewmoVMYirQqH
                          EvW93NcgmjiELuhjndcT/kHjhf8fUAgSuxiPIy6ern02fJjw40KzgiKNvxMoI9su
                          G2zu6gXmxkw+x0SMe9kX+Rg4hCIjTUM7dc66XL5LcTp4S5YEZNVC40/FgTIZoK0e
                          r1dC2/Y1SmmrIoA1
                          -----END CERTIFICATE-----
            - type: vex/cyclone-dx
              name: vex
              attestors:
                - entries:
                    - certificates:
                        cert: |-
                          -----BEGIN CERTIFICATE-----
                          MIIDmDCCAoCgAwIBAgIUCntgF4FftePAhEa6nZTsu/NMT3cwDQYJKoZIhvcNAQEL
                          BQAwTDELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAldBMRAwDgYDVQQHDAdTZWF0dGxl
                          MQ8wDQYDVQQKDAZOb3RhcnkxDTALBgNVBAMMBHRlc3QwHhcNMjQwNjEwMTYzMTQ2
                          WhcNMzQwNjA4MTYzMTQ2WjBMMQswCQYDVQQGEwJVUzELMAkGA1UECAwCV0ExEDAO
                          BgNVBAcMB1NlYXR0bGUxDzANBgNVBAoMBk5vdGFyeTENMAsGA1UEAwwEdGVzdDCC
                          ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJkEGqbILiWye6C1Jz+jwwDY
                          k/rovpXzxS+EQDvfj/YKvx37Kr4cjboJORu3wtzICWhPUtVWZ21ShfjerKgNq0iB
                          mrlF4cqz2KcOfuUT3XBglH/NwhEAqOrGPQrMsoQEFWgnilr0RTc+j4vDnkdkcTj2
                          K/qPhQHRAeb97TdvFCqcZfAGqiOVUqzDGxd2INz/fJd4/nYRX3LJBn9pUGxqRwZV
                          ElP5B/aCBjJDdh6tAElT5aDnLGAB+3+W2YwG342ELyAl2ILpbSRUpKLNAfKEd7Nj
                          1moIl4or5AIlTkgewZ/AK68HPFJEV3SwNbzkgAC+/mLVCD8tqu0o0ziyIUJtoQMC
                          AwEAAaNyMHAwHQYDVR0OBBYEFFTIzCppwv0vZnAVmETPm1CfMdcYMB8GA1UdIwQY
                          MBaAFFTIzCppwv0vZnAVmETPm1CfMdcYMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQD
                          AgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA0GCSqGSIb3DQEBCwUAA4IBAQB8/vfP
                          /TQ3X80JEZDsttdvd9NLm08bTJ/T+nh0DIiV10aHymQT9/u+iahfm1+7mj+uv8LS
                          Y63LepQCX5p9SoFzt513pbNYXMBbRrOKpth3DD49IPL2Gce86AFGydfrakd86CL1
                          9MhFeWhtRf0KndyUX8J2s7jbpoN8HrN4/wZygiEqbQWZG8YtIZ9EewmoVMYirQqH
                          EvW93NcgmjiELuhjndcT/kHjhf8fUAgSuxiPIy6ern02fJjw40KzgiKNvxMoI9su
                          G2zu6gXmxkw+x0SMe9kX+Rg4hCIjTUM7dc66XL5LcTp4S5YEZNVC40/FgTIZoK0e
                          r1dC2/Y1SmmrIoA1
                          -----END CERTIFICATE-----
          validate:
            deny:
              conditions:
                any:
                  - key: '{{ trivy.Vulnerabilities[*].VulnerabilityID }}'
                    operator: AnyNotIn
                    value: '{{ vex.vulnerabilities[*].id }}'
            message: All vulnerabilities in trivy and vex should be same
```

After this policy is applied, Kyverno will verify the signatures in the image and the attestations and then evaluate the validate deny condition which checks all the vulneribilities in trivy report are there in vex report.

```sh
kubectl run test --image=ghcr.io/kyverno/test-verify-image:signed --dry-run=server
pod/test created (server dry run)
```
