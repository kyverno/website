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
  * `skipImageReferences`: a list of image reference patterns that should be skipped.
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

The `imageVerify` rule can be combined with [auto-gen](../autogen.md) so that policy rule checks are applied to Pod controllers.

The `attestors` declaration specifies one or more ways of checking image signatures or attestations. The `attestors.count` specifies the required count of attestors in the `entries` list that must be verified. By default, and when not specified, all attestors are verified.

The `attestors.count` specifies the required count of attestors in the entries list that must be verified. By default, and when not specified, all attestors are verified.

The `imageRegistryCredentials` attribute allows configuration of registry credentials per policy. Kyverno falls back to global credentials if this is empty.

The `imageRegistryCredentials.helpers` is an array of credential helpers that can be used for this policy. Allowed values are `default`,`google`,`azure`,`amazon`,`github`.

The `imageRegistryCredentials.secrets` specifies a list of secrets that are provided for credentials. Secrets must be in the Kyverno namespace.

For additional details please reference a section below for the solution used to sign the images and attestations:

### Cache

Image verification requires multiple network calls and can be time consuming. Kyverno has a TTL based cache for image verification which caches successful outcomes of image verification. When cache is enabled, an image once verified by a policy will be considerd to be verified until TTL duration expires or there is a change in policy.

In Kyverno's admission controller deployment, users can configure the cache using the following flags:

`imageVerifyCacheEnabled`: Enable a TTL cache for verified images. Default is `true`.
`imageVerifyCacheMaxSize`: Maximum number of keys that can be stored in the TTL cache. Keys are a combination of policy elements along with the image reference. Default is `1000`. `0` sets the value to default.
`imageVerifyCacheTTLDuration`: Maximum TTL value for a cache expressed as duration. Default is `60m`. `0` sets the value to default.

The cache is enabled by default and significantly helps with execution time of verify image policiess by making not accessing remote repository on every verification attempt. It should be noted that any change to the image/signature in the remote repository will not be reflected till the cache entry expires.