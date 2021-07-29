---
title: Verify Images
description: Check image signatures and add digests
weight: 3
---

{{% alert title="Note" color="warning" %}}
Image verification is an **alpha** feature. It is not ready for production usage and there may be breaking changes. Normal semantic versioning and compatibility rules will not apply.
{{% /alert %}}

[Sigstore](https://sigstore.dev/) is a [Linux Foundation project](https://linuxfoundation.org/) focused on software signing and transparency log technologies to improve software supply chain security. [Cosign](https://github.com/sigstore/cosign) is a sub-project that provides image signing, verification, and storage in an OCI registry.

The Kyverno `verifyImages` rule uses [Cosign](https://github.com/sigstore/cosign) to verify container image signatures stored in an OCI registry. The rule matches an image reference (wildcards are supported) and specifies a public key to be used to verify the signed image. The policy rule check fails if the image signature is not found in the OCI registry, or if the image was not signed using the specified key.

The rule also mutates matching images to add the [image digest](https://docs.docker.com/engine/reference/commandline/pull/#pull-an-image-by-digest-immutable-identifier) if the digest is not already specified. Using an image digest has the benefit of making image references immutable. This helps ensure that the version of the deployed image does not change and, for example, is the same version that was scanned and verified by a vulnerability scanning and detection tool.

The `imageVerify` rule executes as part of the mutation webhook as the applying policy may insert the image digest. The `imageVerify` rules execute after other mutation rules are applied but before the validation webhook is invoked. This order allows other policy rules to first mutate the image reference if necessary, for example, to replace the registry address, before the image signature is verified.

The `imageVerify` rule can be combined with [auto-gen](docs/writing-policies/autogen/) so that policy rule checks are applied to Pod controllers.

Here is a sample image verification policy:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: check-image
      match:
        resources:
          kinds:
            - Pod
      verifyImages:
      - image: "ghcr.io/kyverno/test-image-verify:*"
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

## Signing images

To sign images, install [Cosign](https://github.com/sigstore/cosign#installation) and generate a public-private key pair. 

```sh
cosign generate-key-pair
```

Next, use the `cosign sign` command and specifying the private key in the `-key` command line argument. 

```sh
# ${IMAGE} is REPOSITORY/PATH/NAME:TAG
cosign sign -key cosign.key ${IMAGE}
```

This command will sign your image and publish the signature to the OCI registry. You can verify the signature using the `cosign -verify` command.

```sh
cosign verify -key cosign.pub ${IMAGE}
```

Refer to the [Cosign documentation](https://github.com/sigstore/cosign#quick-start) for usage details and [OCI registry support](https://github.com/sigstore/cosign#registry-support).

## Using private registries

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

## Known Issues

1. Some registry calls can take a few seconds to complete. Hence, the webhook timeout should be set to a higher number such as 15 seconds.

2. Prometheus metrics and the Kyverno CLI are currently not supported. Check the [Kyverno GitHub](https://github.com/kyverno/kyverno/labels/imageVerify) for a complete list of pending issues.
