---
title: Verify Images Rules
description: >
  Check container image signatures and attestations for software supply chain security.
weight: 60
---

{{% alert title="Warning" color="warning" %}}
Image verification is a **beta** feature and there may be changes to the API.
{{% /alert %}}

The logical structure of an verifyImages rule is shown below:

<img src="/images/verify-image-rule.png" alt="Image Verification Rule" width="60%"/>
<br/><br/>

Each rule contains the following common configuration attributes:
  * `type`: the signature type. Sigstore Cosign and Notary are supported. 
  * `imageReferences`: a list of image reference patterns to match
  * `required`: enforces that all matching images are verified
  * `mutateDigest`: converts tags to digests for matching images
  * `verifyDigest`: enforces that digests are used for matching images
  * `repository`: use a different repository for fetching signatures
  * `imageRegistryCredentials`: use specific registry credentials for this policy.

A verifyImages rule can contain a list of `attestors` or authorities used to check the attached image signature. The type of attestor supported will vary based on the tool used to sign the image. For example, Sigstore Cosign supports public keys, certificates, and keyless attestors.

A verifyImages rule can contain a list of `attestations` i.e., signed metadata, to checked for the image. The nested `attestations.attestors` are used to verify the signature of the attestation. Any JSON data in an attestation can be verified using a set of `attestations.conditions`.

The rule mutates matching images to add the image digest, when mutateDigest is set to true (which is the default), if the digest is not already specified. Using an image digest has the benefit of making image references immutable and prevents spoofing attacks. Using a digest helps ensure that the version of the deployed image does not change and, for example, is the same version that was scanned and verified by a vulnerability scanning and detection tool.

The imageVerify rule first executes as part of the mutation webhook as the applying policy may insert the image digest. The imageVerify rules execute after other mutation rules are applied but before the validation webhook is invoked. This order allows other policy rules to first mutate the image reference if necessary, for example, to replace the registry address, before the image signature is verified.

The imageVerify rule is also executed as part of the validation webhook to apply the `required` and `verifyDigest` checks:
* When `required` is set to `true` (default) each image in the resource is checked to ensure that an immutable annotation that marks the image as verified is present.
* When `verifyDigest` rule is set to `true` (default) each image is checked for a digest.

The `imageVerify` rule can be combined with [auto-gen](/docs/writing-policies/autogen/) so that policy rule checks are applied to Pod controllers.

The `attestors` declaration specifies one or more ways of checking image signatures or attestations. The `attestors.count` specifies the required count of attestors in the `entries` list that must be verified. By default, and when not specified, all attestors are verified.

The `attestors.count` specifies the required count of attestors in the entries list that must be verified. By default, and when not specified, all attestors are verified.

The `imageRegistryCredentials` attribute allows configuration of registry credentials per policy. Kyverno falls back to global credentials if this is empty.

The `imageRegistryCredentials.helpers` is an array of credential helpers that can be used for this policy. Allowed values are `default`,`google`,`azure`,`amazon`,`github`.

The `imageRegistryCredentials.secret` specifies a list of secrets that are provided for credentials. Secrets must be in the Kyverno namespace.

For additional details please reference a section below for the solution used to sign the images and attestations:

### VerifyImage TTL cache:
Implementing the verifyImage policy on a resource currently triggers image verification each time the resource appears. However, to optimize and streamline this verification procedure, Kyverno introduces an innovative cached strategy for validated images, leveraging a concept known as "Time-to-Live" (TTL). This strategy is based on the notion that once an image's validity is confirmed, its verification status can endure for a specified period.

Initially, the cache is configured to hold up to 1000 records, with a default TTL of 60 minutes. This approach offers an advantageous framework. Nonetheless, users have the flexibility to fine-tune these settings according to their specific requirements.

Within Kyverno's deployment, users have the ability to define certain flags:

`imageVerifyCacheEnabled`: Determines whether to adopt a TTL cache for storing verified images. By default, this is set to true.
`imageVerifyCacheMaxSize`: Establishes a maximum capacity for the TTL cache. Defaults is `1000`.
`imageVerifyCacheTTLDuration`: Specifies the TTL period in the cache. A value of 0 corresponds to the default TTL of 1 hour. (Note: The TTL duration should be provided in minutes.)

The utilization of the verifyImage cache offers substantial benefits. It notably reduces the frequency of verifyImage operations, resulting in significant time savings.

#### Cosign/Notary signature and attestation verification using TTL cache:

Cosider the following ClusterPolicy which contains a verifyImage rule. This policy checks the images in the repo `ghcr.io/kyverno/test-verify-image:*` and ensures that it has been signed by verifying its signature against the provided cosign.pub key :
```
apiVersion: v1
kind: Namespace
metadata:
  name: test-verify-images
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: secret-in-keys
spec:
  validationFailureAction: Enforce
  background: false
  webhookTimeoutSeconds: 30
  failurePolicy: Fail
  rules:
  - name: check-secret-in-keys
    match:
      any:
      - resources:
          kinds:
          - Pod
    verifyImages:
    - imageReferences:
      - "ghcr.io/kyverno/test-verify-image:*"
      attestors:
      - entries:
        - keys:
            secret:
              name: testsecret
              namespace: test-verify-images
            rekor:
              url: https://rekor.sigstore.dev
              ignoreTlog: true
```
We are currently utilizing the `cosign.pub` key sourced from the mentioned secret. However, it's also possible to directly provide the `cosign.pub` key within the cluster policy :
```apiVersion: v1
kind: Secret
metadata:
  name: testsecret
  namespace: test-verify-images
data:
  cosign.pub: LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFOG5YUmg5NTBJWmJSajhSYS9OOXNicU9QWnJmTQo1L0tBUU4wL0tqSGNvcm0vSjV5Y3RWZDdpRWNuZXNzUlFqVTkxN2htS082SldWR0hwRGd1SXlha1pBPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t
type: Opaque
```
After creating this policy now create the following pod resource : 
```apiVersion: v1
kind: Pod
metadata:
  name: test-secret-pod
  namespace: test-verify-images
spec:
  containers:
  - image: ghcr.io/kyverno/test-verify-image:signed
    name: test-secret
```

Inside this pod, there's a container named *test-secret* that holds the image `ghcr.io/kyverno/test-verify-image:signed`. The said image has been signed using the cosign key pair as the one employed in our policy.
After applying this pod now generate the Kyverno log by using : 
```
kubectl logs deployment/kyverno-admission-controller -n kyverno
```
Now You can check in logs that image verify operation has taken around `15 seconds`.

```
Time taken by the image verify operation : %!(EXTRA time.Duration=8.7720561s)
```
Now create another Pod resource by using the same image. 
```apiVersion: v1
kind: Pod
metadata:
  name: test-secret-pod-2
  namespace: test-verify-images
spec:
  containers:
  - image: ghcr.io/kyverno/test-verify-image:signed
    name: test-secret-2
```
Once you have applied this new Pod, regenerate kyverno logs using the identical command. Then, examine the logs to verify that the image verification operation was completed within a mere `39 microseconds`.
```
Time taken by the image verify operation : %!(EXTRA time.Duration=39.892µs)
```
Imagine a situation where thousands of similar calls are being made; in such a scenario, substantial time savings could be attained by using the verifyImage cache. This becomes especially pertinent when handling a high volume of requests.

*Note* : Similarly we can verify the notary signature and attestations by using TTL.