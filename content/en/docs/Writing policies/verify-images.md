---
title: Verify Images
description: Check image signatures and add digests
weight: 3
---

{{% alert title="Warning" color="warning" %}}
Image verification is a **beta** feature. It is not ready for production usage and there may be breaking changes. Normal semantic versioning and compatibility rules will not apply.
{{% /alert %}}

[Sigstore](https://sigstore.dev/) is a [Linux Foundation project](https://linuxfoundation.org/) focused on software signing and transparency log technologies to improve software supply chain security. [Cosign](https://github.com/sigstore/cosign) is a sub-project that provides image signing, verification, and storage in an OCI registry.

The Kyverno `verifyImages` rule uses [Cosign](https://github.com/sigstore/cosign) to verify container image signatures, attestations and more stored in an OCI registry. The rule matches an image reference (wildcards are supported) and specifies a public key to be used to verify the signed image or attestations. Background scanning is also supported with this rule type which means reports will show related entries.

## Verifying Image Signatures

Container images can be signed during the build phase of a CI/CD pipeline using Cosign. An image can be signed with multiple signatures, for example at the organization level and at the project level.

The policy rule check fails if the signature is not found in the OCI registry, or if the image was not signed using the specified key.

The rule also mutates matching images to add the [image digest](https://docs.docker.com/engine/reference/commandline/pull/#pull-an-image-by-digest-immutable-identifier) if the digest is not already specified. Using an image digest has the benefit of making image references immutable. This helps ensure that the version of the deployed image does not change and, for example, is the same version that was scanned and verified by a vulnerability scanning and detection tool.

The `imageVerify` rule executes as part of the mutation webhook as the applying policy may insert the image digest. The `imageVerify` rules execute after other mutation rules are applied but before the validation webhook is invoked. This order allows other policy rules to first mutate the image reference if necessary, for example, to replace the registry address, before the image signature is verified.

The `imageVerify` rule can be combined with [auto-gen](/docs/writing-policies/autogen/) so that policy rule checks are applied to Pod controllers.

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
      - image: "ghcr.io/kyverno/test-verify-image:*"
        key: |-
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

### Using private registries

To use a private registry, you must create an image pull secret in the Kyverno namespace and specify the secret name as an argument for the Kyverno deployment:

1. Configure the image pull secret:

```sh
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-password> --docker-email=<your-email> 
-n kyverno
```

2. Update the Kyverno deployment to add the `--imagePullSecrets=regcred` argument:

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

### Using a signature repository

To use a separate registry to store signatures use the [COSIGN_REPOSITORY](https://github.com/sigstore/cosign#specifying-registry) environment variable when signing the image. Then in the Kyverno policy rule specify the repository for each image:

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

## Verifying Image Attestations

Container image signatures prove that the image was signed by the holder of a matching private key. However, signatures do not provide additional data and intent that frameworks like [SLSA (Supply chain Levels for Software Artifacts)](https://security.googleblog.com/2021/06/introducing-slsa-end-to-end-framework.html) require.

An attestation is metadata attached to software artifacts like images. Signed attestations provide verifiable information required for SLSA.

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
  annotations:
    pod-policies.kyverno.io/autogen-controllers: none
spec:
  validationFailureAction: enforce
  background: false
  webhookTimeoutSeconds: 30
  failurePolicy: fail
  rules:
    - name: attest
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - image: "registry.io/org/*"
        key: |-
          -----BEGIN PUBLIC KEY-----
          MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEHMmDjK65krAyDaGaeyWNzgvIu155
          JI50B2vezCw8+3CVeE0lJTL5dbL3OP98Za0oAEBJcOxky8Riy/XcmfKZbw==
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

To sign attestations, use the `cosign attest` command.

```sh
# ${IMAGE} is REPOSITORY/PATH/NAME:TAG
cosign attest --key cosign.key --predicate <file> --type <predicate type>  ${IMAGE}
```

This command will sign your attestations and publish them to the OCI registry. You can verify the attestations using the `cosign verify-attestation` command.

```sh
cosign verify-attestation --key cosign.pub ${IMAGE}
```

Refer to the [Cosign documentation](https://github.com/sigstore/cosign#quick-start) for additional details including [OCI registry support](https://github.com/sigstore/cosign#registry-support).

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
  failurePolicy: fail
  rules:
    - name: check-image
      match:
        any:
        - resources:
            kinds:
              - Pod
      verifyImages:
      - image: "ghcr.io/kyverno/test-verify-image:*"
        key: |-
          -----BEGIN PUBLIC KEY-----
          MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE8nXRh950IZbRj8Ra/N9sbqOPZrfM
          5/KAQN0/KjHcorm/J5yctVd7iEcnessRQjU917hmKO6JWVGHpDguIyakZA==
          -----END PUBLIC KEY-----
        annotations:
          sig: "original"
```

## Known Issues

1. Prometheus metrics and the Kyverno CLI are currently not supported. Check the [Kyverno GitHub](https://github.com/kyverno/kyverno/labels/imageVerify) for a complete list of pending issues.
