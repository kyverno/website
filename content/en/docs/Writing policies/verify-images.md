---
title: Verify Images
description: Check image signatures and add digests
weight: 3
---

{{% alert title="Warning" color="warning" %}}
Image verification is a **beta** feature. It is not ready for production usage and there may be breaking changes. Normal semantic versioning and compatibility rules will not apply.
{{% /alert %}}

[Sigstore](https://sigstore.dev/) is a [Linux Foundation project](https://linuxfoundation.org/) focused on software signing and transparency log technologies to improve software supply chain security. [Cosign](https://github.com/sigstore/cosign) is a sub-project that provides image signing, verification, and storage in an OCI registry.

The Kyverno __verifyImages__ rule uses [Cosign](https://github.com/sigstore/cosign) to verify container image signatures and [in-toto attestations](https://github.com/in-toto/attestation/blob/main/spec/README.md) stored in an OCI registry.

The logical structure of the rule is shown below:

<img src="/images/image-verify-rule.png" alt="Image Verification Rule" width="75%"/>
<br/><br/>

Each rule contains:

* One or more image reference patterns to match
* Common configuration attributes:
  * required: enforces that all matching images are verified
  * mutateDigest: converts tags to digests, for matching images
  * verifyDigest: enforces that digests are used, for matching images
* Zero or more __attestors__ which can be public keys, certificates, and keyless configuration attributes used to identify trust authorities
* Zero or more [in-toto attestation](https://github.com/in-toto/attestation/blob/main/spec/README.md) __statements__ to be verified. If attestations are provided, at least one attestor is required.

## Verifying Image Signatures

Container images can be signed during the build phase of a CI/CD pipeline using Cosign. An image can be signed with multiple signatures, for example at the organization level and at the project level.

The policy rule check fails if the signature is not found in the OCI registry, or if the image was not signed using the specified key.

The rule mutates matching images to add the [image digest](https://docs.docker.com/engine/reference/commandline/pull/#pull-an-image-by-digest-immutable-identifier), when `mutateDigest` is set to `true` (which is the default), if the digest is not already specified. Using an image digest has the benefit of making image references immutable. This helps ensure that the version of the deployed image does not change and, for example, is the same version that was scanned and verified by a vulnerability scanning and detection tool.

The `imageVerify` rule first executes as part of the mutation webhook as the applying policy may insert the image digest. The `imageVerify` rules execute after other mutation rules are applied but before the validation webhook is invoked. This order allows other policy rules to first mutate the image reference if necessary, for example, to replace the registry address, before the image signature is verified.

The rule is also executed as part of the validation webhook to apply the `required` and `verifyDigest` checks.

When `required` is set to `true` (this is the default) each image in the resource is checked to ensure that an immutable annotation that marks the image as verified is present.

When `verifyDigest` rule is set to `true` (this is the default) each image is checked for a digest.

The `imageVerify` rule can be combined with [auto-gen](/docs/writing-policies/autogen/) so that policy rule checks are applied to Pod controllers.

The `attestors` declaration specifies one or more ways of checking image signatures or attestations. The `attestors.count` specifies the requires count of attestors in the `entries` list that must be verified. By default, and when not specified, the all attestors are verified.

Here is a sample image verification policy:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image
spec:
  validationFailureAction: enforce
  background: false
  webhookTimeoutSeconds: 30
  failurePolicy: Fail
  rules:
    - name: check-image
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - imageReferences:
        - "ghcr.io/kyverno/test-verify-image:*"
        attestors:
        - count: 1
          entries:
          - keys:
              publicKeys: |-
                -----BEGIN PUBLIC KEY-----
                MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE8nXRh950IZbRj8Ra/N9sbqOPZrfM
                5/KAQN0/KjHcorm/J5yctVd7iEcnessRQjU917hmKO6JWVGHpDguIyakZA==
                -----END PUBLIC KEY-----
```

This policy will validate that all images that match `ghcr.io/kyverno/test-verify-image:*` are signed with the specified key.

A signed image can be run as follows:

```sh
kubectl run signed --image=ghcr.io/kyverno/test-verify-image:signed
pod/signed created
```

The deployed Pod will be mutated to use the image digest.

Attempting to run an unsigned image will produce a policy error as follows:

```sh
kubectl run unsigned --image=ghcr.io/kyverno/test-verify-image:unsigned
Error from server: admission webhook "mutate.kyverno.svc" denied the request:

resource Pod/default/unsigned was blocked due to the following policies

check-image:
  check-image: 'image verification failed for ghcr.io/kyverno/test-verify-image:unsigned:
    signature not found'
```

Similarly, attempting to run an image which matches the specified rule but is signed with a different key will produce an error:

```sh
kubectl run signed-other --image=ghcr.io/kyverno/test-verify-image:signed-by-someone-else
Error from server: admission webhook "mutate.kyverno.svc" denied the request:

resource Pod/default/signed-other was blocked due to the following policies

check-image:
  check-image: 'image verification failed for ghcr.io/kyverno/test-verify-image:signed-by-someone-else:
    invalid signature'
```

### Signing images

To sign images, install [Cosign](https://github.com/sigstore/cosign#installation) and generate a public-private key pair.

```sh
cosign generate-key-pair
```

Next, use the `cosign sign` command and specifying the private key in the `-key` command line argument.

```sh
# ${IMAGE} is REPOSITORY/PATH/NAME:TAG
cosign sign --key cosign.key ${IMAGE}
```

This command will sign your image and publish the signature to the OCI registry. You can verify the signature using the `cosign -verify` command.

```sh
cosign verify --key cosign.pub ${IMAGE}
```

Refer to the [Cosign documentation](https://github.com/sigstore/cosign#quick-start) for usage details and [OCI registry support](https://github.com/sigstore/cosign#registry-support).

## Verifying Image Attestations

Container image signatures prove that the image was signed by the holder of a matching private key. However, signatures do not provide additional data and intent that frameworks like [SLSA (Supply chain Levels for Software Artifacts)](https://security.googleblog.com/2021/06/introducing-slsa-end-to-end-framework.html) require.

An attestation is metadata attached to software artifacts like images. Signed attestations provide verifiable information required for [SLSA](https://slsa.dev/).

The [in-toto attestation format](https://github.com/in-toto/attestation) provides a flexible scheme for metadata such as repository and build environment details, vulnerability scan reports, test results, code review reports, or any other information that is used to verify image integrity. Each attestation contains a signed statement with a `predicateType` and a `predicate`. Here is an example derived from the in-toto site:

```json
{
  "payloadType": "https://example.com/CodeReview/v1",
  "payload": {
    "_type": "https://in-toto.io/Statement/v0.1",
    "predicateType": "https://example.com/CodeReview/v1",
    "subject": [
      {
        "name": "registry.io/org/app",
        "digest": {
          "sha256": "b31bfb4d0213f254d361e0079deaaebefa4f82ba7aa76ef82e90b4935ad5b105"
        }
      }
    ],
    "predicate": {
      "author": "alice@example.com",
      "repo": {
        "branch": "main",
        "type": "git",
        "uri": "https://git-repo.com/org/app"
      },
      "reviewers": [
        "bob@example.com"
      ]
    }
  },
  "signatures": [
    {
      "keyid": "",
      "sig": "MEYCIQDtJYN8dq9RACVUYljdn6t/BBONrSaR8NDpB+56YdcQqAIhAKRgiQIFvGyQERJJYjq2+6Jq2tkVbFpQMXPU0Zu8Gu1S"
    }
  ]
}
```

The `imageVerify` rule can contain one or more attestation checks that verify the contents of the `predicate`. Here is an example that verifies the repository URI, the branch, and the reviewers.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: attest-code-review
spec:
  validationFailureAction: enforce
  background: false
  webhookTimeoutSeconds: 30
  failurePolicy: Fail
  rules:
    - name: attest
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - imageReferences:
        - "registry.io/org/app*"
        attestors:
        - entries:
          - keys:
              publicKeys: |-
                -----BEGIN PUBLIC KEY-----
                MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEzDB0FiCzAWf/BhHLpikFs6p853/G
                3A/jt+GFbOJjpnr7vJyb28x4XnR1M5pwUUcpzIZkIgSsd+XcTnrBPVoiyw==
                -----END PUBLIC KEY-----
        attestations:
          - predicateType: https://example.com/CodeReview/v1
            conditions:
              - all:
                - key: "{{ repo.uri }}"
                  operator: Equals
                  value: "https://git-repo.com/org/app"            
                - key: "{{ repo.branch }}"
                  operator: Equals
                  value: "main"
                - key: "{{ reviewers }}"
                  operator: In
                  value: ["ana@example.com", "bob@example.com"]
```

The policy rule above fetches and verifies that the attestations are signed with the matching private key, decodes the payloads to extract the predicate, and then applies each [condition](/docs/writing-policies/preconditions/#any-and-all-statements) to the predicate.

Each `verifyImages` rule can be used to verify signatures or attestations, but not both. This allows the flexibility of using separate signatures for attestations.

### Signing attestations

To sign attestations, use the `cosign attest` command. This command will sign your attestations and publish them to the OCI registry.

```sh
# ${IMAGE} is REPOSITORY/PATH/NAME:TAG
cosign attest --key cosign.key --predicate <file> --type <predicate type>  ${IMAGE}
```

You can use a custom attestation type with a JSON document as the predicate. For example, with the code review example above the predicate body can be specified in a file `predicate.json` with the contents:

```json
{
    "author": "alice@example.com",
    "repo": {
        "branch": "main",
        "type": "git",
        "uri": "https://git-repo.com/org/app"
    },
    "reviewers": [
        "bob@example.com"
    ]
}
```

The following cosign command creates the in-toto format attestation and signs it with the specified credentials using the custom predicate type `https://example.com/CodeReview/v1`:

```sh
cosign attest ghcr.io/jimbugwadia/app1:v1 --key <KEY> --predicate predicate.json  --type https://example.com/CodeReview/v1
```

This flexible scheme allows attesting and verifying any JSON document, including vulnerability scan reports and Software Bill Of Materials (SBOMs).

Attestations, such as the snippet shown above, are base64 encoded by default and may be verified and viewed with the `cosign verify-attestation` command. For example, the below command will verify and decode the attestations for a given image which was signed with the [keyless signing ability](/docs/writing-policies/verify-images/#keyless-signing-and-verification).

```sh
COSIGN_EXPERIMENTAL=true cosign verify-attestation registry.io/myrepo/myimage:mytag | jq .payload -r | base64 --decode | jq
```

```sh
cosign verify-attestation --key cosign.pub ${IMAGE}
```

Refer to the [Cosign documentation](https://github.com/sigstore/cosign#quick-start) for additional details including [OCI registry support](https://github.com/sigstore/cosign#registry-support).

## Certificate based signing and verification

This policy checks if an image is signed using a certificate. The root certificate, and any intermediary certificates in the signing chain, can also be provided in the `certChain` declaration.

```yaml
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image
spec:
  validationFailureAction: enforce
  rules:
    - name: verify-signature
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - imageReferences:
        - "ghcr.io/kyverno/test-verify-image:signed-cert"
        attestors:
        - entries:
          - certificates:
              cert: |-
                -----BEGIN CERTIFICATE-----
                MIIDuzCCAqOgAwIBAgIUDG7gFB8RMMOMGkDm6uEusOE8FWgwDQYJKoZIhvcNAQEL
                BQAwbDELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAkNBMQwwCgYDVQQHDANTSkMxEDAO
                BgNVBAoMB05pcm1hdGExEDAOBgNVBAMMB25pcm1hdGExHjAcBgkqhkiG9w0BCQEW
                D2ppbUBuaXJtYXRhLmNvbTAeFw0yMjA0MjgxOTU0NDFaFw0yNDA3MzExOTU0NDFa
                MGwxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJDQTEMMAoGA1UEBwwDU0pDMRAwDgYD
                VQQKDAdOaXJtYXRhMRAwDgYDVQQDDAduaXJtYXRhMR4wHAYJKoZIhvcNAQkBFg9q
                aW1AbmlybWF0YS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDP
                LObWc4VM4CULHrjScdjAXwdeJ6o1SwS9Voz9wTYAASp54EDqgzecWGjtn409NF9o
                4tqd5LotEFscoMXGpmm7dBpv76MQhGym7JBhlYaBksmnKp17nTfAmsgiDiUnjnG6
                BQ5/FIdZYHtpJmMZ/SZqQ3ehXLaGj2qogPrEsObN1S/1b+0guLC/gVi1fiuUgd4Z
                SDEmDaLjSuIQBrtba08vQnl5Ihzrag3A85+JNNxk9WBDFnLHMsRvlrUMU4565FS9
                X57epDZakKvLATAK0/gKI2ZvWfY0hoO3ngEk4Rkek6Qeh1vXFBc8Rsym8W0RXjux
                JDkye5RTsYrlXxSavP/xAgMBAAGjVTBTMB8GA1UdIwQYMBaAFBF3uwHovsxj7WxS
                vDDKBTwuR+oaMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgTwMBgGA1UdEQQRMA+CDWhl
                bGxmaXNoLnRlc3QwDQYJKoZIhvcNAQELBQADggEBAHtn9KptJyHYs45oTsdmXrO0
                Fv0k3jZnmqxHOX7OiFyAkpcYUTezMYKHGqLdme0p2VE/TdQmGPEq1dqlQbF7UMb/
                o+SrvFpmAJ1iAVjLYQ7KDCE706NgnVkxaPfU8UBOw2vF5nsgIxcheOyxTplbVOVM
                vcYYwAWXxkNhrQ4sYygXuNgZawruxY1HdUgGWlh9XY0J5OBrXyinh2YGBUGQJgQR
                NEmM+GQjdquPqAgDsb3kvWgFDrcbBZJBc/CyZU8GH9uIuPDgfVhDTqFtiz9W/F5s
                Hh8yD7VAIWgL9TkGWRwWdD6Qx/BAu7dMdpjAxdGpMLn3O4SDAZDnQneaHx6qr/I=
                -----END CERTIFICATE-----
              certChain: |-
                -----BEGIN CERTIFICATE-----
                MIIDuTCCAqGgAwIBAgIUU1kkhcMc+7ci1qvkLCre5lbH68owDQYJKoZIhvcNAQEL
                BQAwbDELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAkNBMQwwCgYDVQQHDANTSkMxEDAO
                BgNVBAoMB05pcm1hdGExEDAOBgNVBAMMB25pcm1hdGExHjAcBgkqhkiG9w0BCQEW
                D2ppbUBuaXJtYXRhLmNvbTAeFw0yMjA0MjgxOTE2NTJaFw0yNzA0MjcxOTE2NTJa
                MGwxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJDQTEMMAoGA1UEBwwDU0pDMRAwDgYD
                VQQKDAdOaXJtYXRhMRAwDgYDVQQDDAduaXJtYXRhMR4wHAYJKoZIhvcNAQkBFg9q
                aW1AbmlybWF0YS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCx
                hpgJ/YUXtUyLNjJgoOBQHSIL6PrdNj9iemgddVg1WGzQrtMnleVY1Wh31C3nV2oN
                VrcH2+i/14fyTWpAPEoJ/E6/3Pd8EYokFffm6AXvSCX6gaRpgeiWySK9T62bI7TP
                4VplppF4lkUJbYxtFiVt5q2T4+lm+k8Q5kDtxU8d1067ApM82f9kHgoLqJwuuGM7
                VPHX023orJ2YU68gJo78qGbv+1/aoPpcEZelk5RBXplvOT23DbMgEi3SxWjJ3djU
                svQu+FMLG9xWpTdH5P98/1hY89xxYk+paEVDX0xSmINt2nfFGV5x1ChEMaZSC/7Q
                9Z5qRX2e26/Mm+jFnIIJAgMBAAGjUzBRMB0GA1UdDgQWBBQRd7sB6L7MY+1sUrww
                ygU8LkfqGjAfBgNVHSMEGDAWgBQRd7sB6L7MY+1sUrwwygU8LkfqGjAPBgNVHRMB
                Af8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCGMBvR7wGHQdofwP4rCeXY9OlR
                RamGcOX7GLI5zQnO717l+kZqJQAQfhgehbm14UkXx3/1iyqSYpNUIeY6XZaiAxMC
                fQI8ufcaws4f522QINGNLQGzzt2gkDAg25ARTgH4JVmRxiViTsfrb+VgjcYhkLK5
                mWffp3LpCiybZaRKwS93SNWo95ld2VzDgzGNLLGejifCe9nPSfvkuXHfDW9nSRMP
                plXrFYd7TTMUaENRmTQtl1KyIlnLEp+A6ZBpY1Pxdc9SnflYQVQb0hsxSa+Swkb6
                hRkMf01X7+GAI75hpgoX/CuCjd8J5kozsXLzUtKRop5gXyZxuFL8yUW9gfQs
                -----END CERTIFICATE-----
```

To verify using the root certificate only, the leaf certificate declaration `cert` can be omitted.

```yaml
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image
spec:
  validationFailureAction: enforce
  rules:
    - name: verify-signature
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - imageReferences:
        - "ghcr.io/kyverno/test-verify-image:signed-cert"
        attestors:
        - entries:
          - certificates:
              certChain: |-
                -----BEGIN CERTIFICATE-----
                MIIDuTCCAqGgAwIBAgIUU1kkhcMc+7ci1qvkLCre5lbH68owDQYJKoZIhvcNAQEL
                BQAwbDELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAkNBMQwwCgYDVQQHDANTSkMxEDAO
                BgNVBAoMB05pcm1hdGExEDAOBgNVBAMMB25pcm1hdGExHjAcBgkqhkiG9w0BCQEW
                D2ppbUBuaXJtYXRhLmNvbTAeFw0yMjA0MjgxOTE2NTJaFw0yNzA0MjcxOTE2NTJa
                MGwxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJDQTEMMAoGA1UEBwwDU0pDMRAwDgYD
                VQQKDAdOaXJtYXRhMRAwDgYDVQQDDAduaXJtYXRhMR4wHAYJKoZIhvcNAQkBFg9q
                aW1AbmlybWF0YS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCx
                hpgJ/YUXtUyLNjJgoOBQHSIL6PrdNj9iemgddVg1WGzQrtMnleVY1Wh31C3nV2oN
                VrcH2+i/14fyTWpAPEoJ/E6/3Pd8EYokFffm6AXvSCX6gaRpgeiWySK9T62bI7TP
                4VplppF4lkUJbYxtFiVt5q2T4+lm+k8Q5kDtxU8d1067ApM82f9kHgoLqJwuuGM7
                VPHX023orJ2YU68gJo78qGbv+1/aoPpcEZelk5RBXplvOT23DbMgEi3SxWjJ3djU
                svQu+FMLG9xWpTdH5P98/1hY89xxYk+paEVDX0xSmINt2nfFGV5x1ChEMaZSC/7Q
                9Z5qRX2e26/Mm+jFnIIJAgMBAAGjUzBRMB0GA1UdDgQWBBQRd7sB6L7MY+1sUrww
                ygU8LkfqGjAfBgNVHSMEGDAWgBQRd7sB6L7MY+1sUrwwygU8LkfqGjAPBgNVHRMB
                Af8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCGMBvR7wGHQdofwP4rCeXY9OlR
                RamGcOX7GLI5zQnO717l+kZqJQAQfhgehbm14UkXx3/1iyqSYpNUIeY6XZaiAxMC
                fQI8ufcaws4f522QINGNLQGzzt2gkDAg25ARTgH4JVmRxiViTsfrb+VgjcYhkLK5
                mWffp3LpCiybZaRKwS93SNWo95ld2VzDgzGNLLGejifCe9nPSfvkuXHfDW9nSRMP
                plXrFYd7TTMUaENRmTQtl1KyIlnLEp+A6ZBpY1Pxdc9SnflYQVQb0hsxSa+Swkb6
                hRkMf01X7+GAI75hpgoX/CuCjd8J5kozsXLzUtKRop5gXyZxuFL8yUW9gfQs
                -----END CERTIFICATE-----
```

This enables use cases where in an enterprise with a private CA all each team has their own leaf certificate used for signing their images, and a global policy is used to verify all images signatures.

### Signing images using certificates

To use certificates for image signing, you must first extract the public key using the `cosign import` command.

Assuming you have a root CA `myCA.pem` and a public-private certificate pair `test.crt` and `test.key`, you can convert the public certificate to a key as follows:

```sh
cosign import-key-pair --key  test.key
```

This creates the `import-cosign.key`  and `import-cosign.pub` files. You can then sign using the certificate as follows:

```sh
cosign sign $IMAGE --key import-cosign.key --cert test.crt --cert-chain myCA.pem 
```

This image can now be verified using the leaf or root certificates.

## Keyless signing and verification

The following policy verifies an image signed using ephemeral keys and signing data stored in a transparency log, known as [keyless signing](https://github.com/sigstore/cosign/blob/main/KEYLESS.md):

```yaml
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image-keyless
spec:
  validationFailureAction: enforce
  webhookTimeoutSeconds: 30
  rules:
    - name: check-image-keyless
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - imageReferences:
        - "ghcr.io/kyverno/test-verify-image:signed-keyless"
        attestors:
        - entries:
          - keyless:
              subject: "*@nirmata.com"
              issuer: "https://accounts.google.com"
```

### Keyless signing

To sign images using the keyless flow, use the following cosign command:

```sh
COSIGN_EXPERIMENTAL=1 cosign sign ghcr.io/kyverno/test-verify-image:signed-keyless
```

This command generate ephemeral keys and launch a webpage to confirm an OIDC identity using providers like GitHub, Microsoft, or Google. The subject and issuer used in the policy must match the identity information provided during signing.

### Keyless signing with GitHub Workflows

GitHub supports [OpenID Connect (OIDC) tokens](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) for workflow identities that eliminates the need for managing hard-coded secrets. A GitHub OIDC Token can be used for keyless signing. In this case, the `subject` in the ephemeral certificate provides the identity of the workflow that executes the image signing tasks.

Since GitHub workflows can be reused in other workflows, it is important to verify the identity of the both the executing workflow and the actual workflow used for signing. This can be done using attributes stored in X.509 certificate extensions.

The policy rule fragment checks for the `subject` and `issuer` from the certificate. The rule also checks for additional extensions registered using [Fulcio Object IDs](https://github.com/sigstore/fulcio/blob/main/docs/oid-info.md).

```yaml
attestors:
- entries:
  - keyless:
      subject: "https://github.com/{{ORGANIZATION}}/{{REPOSITORY}}/.github/workflows/{{WORKFLOW}}@refs/tags/*"
      issuer: "https://token.actions.githubusercontent.com"
      additionalExtensions:
        githubWorkflowTrigger: push
        githubWorkflowSha: {{WORKFLOW_COMMIT_SHA}}
        githubWorkflowName: {{WORKFLOW_NAME}}
        githubWorkflowRepository: {{WORKFLOW_ORGANIZATION}}/{{WORKFLOW_REPOSITORY}}
```

## Using a Key Management Service (KMS)

Kyverno and Cosign support using Key Management Services (KMS) such as AWS, GCP, Azure, and HashiCorp Vault. This integration allows referencing public and private keys using a URI syntax, instead of embedding the key directly in the policy.

The supported formats include:

* azurekms://[VAULT_NAME][VAULT_URI]/[KEY]
* awskms://[ENDPOINT]/[ID/ALIAS/ARN]
* gcpkms://projects/[PROJECT]/locations/global/keyRings/[KEYRING]/cryptoKeys/[KEY]
* hashivault://[KEY]

Refer to https://docs.sigstore.dev/cosign/kms_support for additional details.

### Enabling IRSA to access AWS KMS

When running Kyverno in a AWS EKS cluster, you can use IAM Roles for Service Accounts ([IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)) to grant the Kyverno ServiceAccount permission to retrieve the public key(s) it needs from AWS KMS.

Once IRSA is enabled, the Kyverno ServiceAccount will have a new annotation with the IAM role it can assume, and the Kyverno Pod will assume this IAM role through the cluster's OIDC provider. To understand how IRSA works internally, see links below:

* [IAM roles for service accounts (EKS Documentation)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
* [IAM Roles for Service Accounts (eksworkshop.com)](https://www.eksworkshop.com/beginner/110_irsa/)
* [Understanding IAM roles for service accounts, IRSA, on AWS EKS (Medium)](https://medium.com/@ankit.wal/the-how-of-iam-roles-for-service-accounts-irsa-on-aws-eks-3d76badb8942)

Sample steps to enable IRSA for Kyverno using `eksctl` (see links above if you prefer to use `AWS CLI` instead):

1. Associate IAM OIDC provider

    ```sh
    eksctl utils associate-iam-oidc-provider --cluster <cluster-name> --approve
    ```  

2. Create IAM policy

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "kms:GetPublicKey",
                    "kms:DescribeKey"
                ],
                "Resource": "arn:aws:kms:<region>:<account-id>:key/<key-id>"
            }
        ]
    }
    ```

3. Create IAM role and annotate the Kyverno ServiceAccount with it

    ```sh
    eksctl create iamserviceaccount \
        --name kyverno \
        --namespace kyverno \
        --cluster <cluster-name> \
        --attach-policy-arn "arn:aws:iam::<account-id>:policy/<iam-policy>" \
        --approve \
        --override-existing-serviceaccounts
    ```

{{% alert title="Note" color="info" %}}
Kyverno needs to know the AWS region for the KMS store in use. To provide this information, the environment variables `AWS_DEFAULT_REGION` and `AWS_REGION` need to be set in the Kyverno Deployment.
{{% /alert %}}

## Verifying Image Annotations

Cosign has the ability to add annotations when signing and image, and Kyverno can be used to verify these annotations with the `verifyImage.annotations` field. For example, this policy checks for the annotation of `sig: original`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image
spec:
  validationFailureAction: enforce
  background: false
  webhookTimeoutSeconds: 30
  failurePolicy: Fail
  rules:
    - name: check-image
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - image: "ghcr.io/kyverno/test-verify-image:signed-keyless"
        key: |-
          -----BEGIN PUBLIC KEY-----
          MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE8nXRh950IZbRj8Ra/N9sbqOPZrfM
          5/KAQN0/KjHcorm/J5yctVd7iEcnessRQjU917hmKO6JWVGHpDguIyakZA==
          -----END PUBLIC KEY-----
        annotations:
          sig: "original"
```

## Using private registries

Private registries are defined as those requiring authentication in order to pull images. To use a private registry, you must create an image pull secret in the Kyverno Namespace and specify the Secret name as an argument for the Kyverno Deployment:

1. Configure the image pull secret:

```sh
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-password> --docker-email=<your-email> 
-n kyverno
```

2. Update the Kyverno Deployment to add the `--imagePullSecrets=regcred` argument:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: kyverno
   ...
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kyverno
      app.kubernetes.io/name: kyverno
  template:
    spec:
      containers:
      - args:
        ...
        - --webhooktimeout=15
        - --imagePullSecrets=regcred
```

If multiple imagePullSecrets are needed, they can be specified as comma-separated values to the `--imagePullSecrets` container flag.

## Using a signature repository

To use a separate registry to store signatures use the [COSIGN_REPOSITORY](https://github.com/sigstore/cosign#specifying-registry) environment variable when signing the image. Then in the Kyverno policy rule, specify the repository for each image:

```yaml
...
verifyImages:
- image: "ghcr.io/kyverno/test-verify-image:*"
  repository: "registry.io/signatures"
  key: |-
    -----BEGIN PUBLIC KEY-----
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE8nXRh950IZbRj8Ra/N9sbqOPZrfM
    5/KAQN0/KjHcorm/J5yctVd7iEcnessRQjU917hmKO6JWVGHpDguIyakZA==
    -----END PUBLIC KEY-----
...
```

## Verifying images in Custom Resources

In addition to Kubernetes pods, custom resources, such as Tekton Tasks and Argo Workflow Steps can also reference container images. In other cases, rather than an image, an OCI Artifact like a Tekton Pipeline bundle may be signed.

Kyverno supports verification for images and OCI Artifacts in custom resources by allowing the declaration of an `imageExtractor`, which specifies the location of the image or artifact in the custom resource.

Here is an example of a policy that verifies that Tekton task steps are signed using a private key that matches the specified public key:

```yaml

apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: signed-task-image
spec:
  validationFailureAction: enforce
  rules:
  - name: check-signature
    match:
      any:
      - resources:
          kinds:
          - tekton.dev/v1beta1/TaskRun.status
    imageExtractors:
      TaskRun:
        - name: "taskrunstatus"
          path: "/status/taskSpec/steps/*"
          value: "image"
          key: "name"
    verifyImages:
    - imageReferences:
      - "*"
      required: false
      attestors:
      - entries:
        - keys: 
            publicKeys: |-
              -----BEGIN PUBLIC KEY-----
              MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEahmSvGFmxMJABilV1usgsw6ImcQ/
              gDaxw57Sq+uNGHW8Q3zUSx46PuRqdTI+4qE3Ng2oFZgLMpFN/qMrP0MQQg==
              -----END PUBLIC KEY-----   
```

This policy rule checks that Tekton pipeline bundles are signed with a private key that matches the specified public key:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: signed-pipeline-bundle
spec:
  validationFailureAction: enforce
  rules:
  - name: check-signature
    match:
      any:
      - resources:
          kinds:
          - PipelineRun
    imageExtractors:
      PipelineRun:
        - name: "pipelineruns"
          path: /spec/pipelineRef
          value: "bundle"
          key: "name"
    verifyImages:
    - imageReferences:
      - "*"
      attestors:
      - entries:
        - keys: 
            publicKeys: |-
              -----BEGIN PUBLIC KEY-----
              MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEahmSvGFmxMJABilV1usgsw6ImcQ/
              gDaxw57Sq+uNGHW8Q3zUSx46PuRqdTI+4qE3Ng2oFZgLMpFN/qMrP0MQQg==
              -----END PUBLIC KEY-----
```

## Offline Registries

In Kyverno 1.8.0, the policy-level setting `failurePolicy` when set to `Ignore` additionally means that failing calls to image registries will be ignored. This allows for Pods to not be blocked if the registry is offline, useful in situations where images already exist on the nodes.

## Known Issues

Check the [Kyverno GitHub repo](https://github.com/kyverno/kyverno/labels/imageVerify) for a list of pending issues for this feature.
