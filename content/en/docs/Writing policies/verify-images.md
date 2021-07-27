---
title: Verify Images
description: Check image signatures and add digests
weight: 3
---

{{% alert title="Note" color="warning" %}}
Image verification is a **preview** feature. It is not ready for production usage and will likely change before a general availabilty (GA) release.
{{% /alert %}}

The Kyverno `verifyImages` rule uses [Cosign](https://github.com/sigstore/cosign) to verify container image signatures stored in an OCI registry. The rule matches an image reference (wildcards are supported) and specifies a public key to be used to verify the signed image. The policy rule check fails if the image signature is not found in the OCI registry, or if the image was not signed using the specified key.

The rule also mutates the image to add the `image digest` if a digest is not already specified. Using a image digest has the benefit of making images references immutable. This hekos ensure that the expected version of the image is being run, for example the version that was scanned and verified by a vulnerability detection tool.

The `imageVerify` rule executes as part of the mutation webhook, after mutation rules are applied, but before the validation webhook is invoked. 

The `imageVerify` rule can be combined with [auto-gen](docs/writing-policies/autogen/) so that policy rule checks are applied to pod controllers.

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
      - image: "ghcr.io/jimbugwadia/*"
        key: |-
          -----BEGIN PUBLIC KEY-----
          MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE8nXRh950IZbRj8Ra/N9sbqOPZrfM
          5/KAQN0/KjHcorm/J5yctVd7iEcnessRQjU917hmKO6JWVGHpDguIyakZA==
          -----END PUBLIC KEY-----
```

This policy will validate that all images from the `ghcr.io/jimbugwadia` registry are signed with specified key.


A signed image can be run as follows:

```sh
kubectl run pause --image ghcr.io/jimbugwadia/pause
pod/pause created
```

The deployed pod will be mutated to use the image digest.

Attempting to run an unsigned image will produce an policy error as follows:

```sh
kubectl run pause-unsigned --image ghcr.io/jimbugwadia/pause-unsigned
Error from server: admission webhook "mutate.kyverno.svc" denied the request:

resource Pod/default/pause-unsigned was blocked due to the following policies

check-image:
  check-image: 'image verification failed for ghcr.io/jimbugwadia/pause-unsigned:latest:
    signature not found'
```

Similary, attempting to run an image which matches the specified rule but is signed with a different key will produce an error:

```sh
kubectl run pause2 --image ghcr.io/jimbugwadia/pause2
Error from server: admission webhook "mutate.kyverno.svc" denied the request:

resource Pod/default/pause2 was blocked due to the following policies

check-image:
  check-image: 'image verification failed for ghcr.io/jimbugwadia/pause2:latest: invalid
    signature'
```


## Signing images

To sign images install [Cosign](https://github.com/sigstore/cosign#installation) and generate a public-private key pair. Next use the `cosign sign` command and specifying the private key in the `-key` command line argument. This command will sign your image and publish the signature to the OCI registry. You can verify the signature using the `cosign -verify` command.

## Using private registries

To use a private registry you must create an image pull secret in the Kyverno namespace and specify the secret name as an argument for the Kyverno deployment:

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

2. Prometheus metrics and the Kyverno CLI, are currently not supported. Check the [Kyverno GitHub](https://github.com/kyverno/kyverno/labels/imageVerify) for a complete list of pending issues.
