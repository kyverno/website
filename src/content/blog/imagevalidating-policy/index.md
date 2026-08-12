---
date: 2026-05-26
title: ImageValidatingPolicy - Trust What Your Cluster Actually Runs
tags:
  - General
authors:
  - name: Kirti Goyal
excerpt: A practical guide to ImageValidatingPolicy in Kyverno like verifying container image signatures, checking attestations, and enforcing supply chain security before anything runs in the cluster.
draft: false
---

The other policy covered so far deals with Kubernetes resource configuration.
Labels, resource limits, namespaces, cleanup schedules. All of it is about how
resources are configured.

**ImageValidatingPolicy** deals with something completely different.

Not configuration. **Trust**.

When a Pod is scheduled and Kubernetes pulls a container image like how does the cluster
know that image is actually what it claims to be? How does it know the image wasn't
tampered with after it was built? How does it know it came from the CI pipeline and
not from somewhere else entirely?

By default, Kubernetes itself does not verify where an image came from or whether it was cryptographically signed.
That's the problem this policy type solves.

## The real threat: supply chain attacks

This isn't theoretical. Supply chain attacks on container images are a real and growing
category of security incident.

The attack pattern looks like this:

1. Attacker compromises a registry account or a build dependency
2. Pushes a modified image with the same name and tag as a legitimate one
3. The cluster pulls it on next deployment because the tag looks right
4. Malicious code is now running inside the infrastructure

Image signing breaks this chain. The CI pipeline signs every image it builds using a
cryptographic signature. ImageValidatingPolicy verifies that signature before any Pod
is allowed to run. A tampered image has no valid signature from the pipeline, So, Kyverno
blocks it. Even if the name and tag look identical.

## How ImageValidatingPolicy fits in

Every other policy type in this series runs against Kubernetes resource fields like the
YAML that describes a Pod, Deployment, or namespace.

`ImageValidatingPolicy` goes one layer deeper. It reaches out to the container registry,
fetches the image's signature and attestations, and verifies them cryptographically
before the Pod is admitted.

That's why it needs more time:

```yaml
webhookConfiguration:
  timeoutSeconds: 15 # default is 10; image verification needs more time
```

Image verification often requires a higher timeout because verification may involve registry and transparency log lookups.

For security-sensitive verification policies, it's also common to use:

```yaml
failurePolicy: Fail
```

This means Pods are rejected if image verification cannot complete successfully due to
timeouts, registry failures, or transparency log issues.

## The two signing tools

- **Cosign**: This is part of the Sigstore project. The most widely used tool for signing
  container images today. Two modes:
  - **Key-based** — generate a keypair, sign with the private key, verify with the
    public key. Straightforward but requires managing key rotation.
  - **Keyless** — no keys to manage. Uses OIDC identity (like GitHub Actions) to sign.
    The signature is tied to the workflow identity. No key storage, no rotation headaches.

- **Notary**: This is certificate-based signing standard. More common in enterprise environments with existing PKI infrastructure, especially Azure Container Registry.

For most modern setups, Cosign keyless with GitHub Actions is the default.

## The anatomy of an ImageValidatingPolicy

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: your-policy-name
spec:
  validationActions:
    - Deny
  webhookConfiguration:
    timeoutSeconds: 15 # image verification may require registry lookups
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchImageReferences:
    - glob: 'ghcr.io/myorg/*' # which images to verify
  attestors:
    - name: my-attestor # who do we trust to have signed the image
      cosign:
        keyless:
          identities:
            - subject: '...'
              issuer: '...'
  validations:
    - expression: >-
        images.containers.map(image,
          verifyImageSignatures(image, [attestors.myAttestor])
        ).all(e, e > 0)
      message: 'Image must be signed by the CI pipeline'
```

Five fields that are new compared to ValidatingPolicy:

- `matchImageReferences` — which images get verified. Use glob patterns or CEL
  expressions. Images that don't match are left alone.

- `attestors` — who is trusted to have signed the image. This is the core of the
  policy. You can define signing identities here.

- `attestations` — additional metadata to verify beyond the signature itself. SBOMs,
  vulnerability scan results, SLSA provenance.

- `validationConfigurations` — It digest pinning settings. Controls whether Kyverno
  rewrites image tags to digests automatically.

- `credentials` — authentication for private registries.

## Use case 1: Require images signed by GitHub Actions (Cosign keyless)

The most common setup for teams using GitHub Actions. Every image built by the
pipeline gets signed automatically. The policy verifies that signature before anything
runs.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: require-signed-images
spec:
  validationActions:
    - Deny
  webhookConfiguration:
    timeoutSeconds: 15
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchImageReferences:
    - glob: 'ghcr.io/myorg/*' # only verify images from this org
  attestors:
    - name: githubActions
      cosign:
        keyless:
          identities:
            - subject: 'https://github.com/myorg/myrepo/.github/workflows/build.yaml@refs/heads/main'
              issuer: 'https://token.actions.githubusercontent.com'
        ctlog:
          url: 'https://rekor.sigstore.dev'
  validations:
    - expression: >-
        images.containers.map(image,
          verifyImageSignatures(image, [attestors.githubActions])
        ).all(e, e > 0)
      message: 'Image must be signed by the GitHub Actions build pipeline on main branch'
```

Read the `subject` as: "I only trust images signed by this specific workflow file,
on this specific branch, in this specific repo." An image signed by a fork, a different
workflow, or a different branch fails verification.

The `ctlog.url` points to Rekor, which is a public transparency log where Cosign keyless
signatures are recorded. Kyverno verifies the signature against this log.

## Use case 2: Require a vulnerability scan attestation

A signature proves the image was built by the right pipeline. An attestation proves
something additional like a vulnerability scan was run and the results are attached
to the image.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: require-signed-and-scanned
spec:
  validationActions:
    - Audit # start with Audit, switch to Deny after testing
  webhookConfiguration:
    timeoutSeconds: 15
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        resources: ['pods']
        operations: ['CREATE', 'UPDATE']
  matchImageReferences:
    - glob: 'ghcr.io/myorg/*'
  attestors:
    - name: cosign
      cosign:
        keyless:
          identities:
            - subject: 'https://github.com/myorg/myrepo/.github/workflows/*'
              issuer: 'https://token.actions.githubusercontent.com'
        ctlog:
          url: 'https://rekor.sigstore.dev'
  attestations:
    - name: vulnScan
      intoto:
        type: cosign.sigstore.dev/attestation/vuln/v1
  validations:
    - expression: >-
        images.containers.map(image,
          verifyImageSignatures(image, [attestors.cosign])
        ).all(e, e > 0)
      message: 'Image must be signed by the CI pipeline'
    - expression: >-
        images.containers.map(image,
          verifyAttestationSignatures(image, attestations.vulnScan, [attestors.cosign])
        ).all(e, e > 0)
      message: 'Image must have a verified vulnerability scan attestation'
```

There are two validation rules. Both must pass. If image is not signed then its blocked. If the image is signed but no vulnerability scan is performed then its also blocked. But if both present and verified then allowed.

## Use case 3: Verify with a public key (Cosign key-based)

For teams that manage their own signing keys rather than using keyless signing:

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: verify-with-public-key
spec:
  validationActions:
    - Deny
  webhookConfiguration:
    timeoutSeconds: 15
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchImageReferences:
    - glob: 'ghcr.io/myorg/*'
  attestors:
    - name: cosign
      cosign:
        key:
          data: |
            -----BEGIN PUBLIC KEY-----
            MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE6QsNef3SKYhJVYSVj+ZfbPwJd0pv
            DLYNHXITZkhIzfE+apcxDjCCkDPcJ3A3zvhPATYOIsCxYPch7Q2JdJLsDQ==
            -----END PUBLIC KEY-----
  validations:
    - expression: >-
        images.containers.map(image,
          verifyImageSignatures(image, [attestors.cosign])
        ).all(e, e > 0)
      message: 'Image must be signed with the org signing key'
```

The public key is embedded directly in the policy. The setup is simpler but requires a key
rotation process when the signing key changes, the policy needs to be updated too.

## Use case 4: Verify an SBOM and check its format

An SBOM (Software Bill of Materials) is a list of every dependency inside the image.
Signed SBOMs attached to images prove exactly what's inside them, which is useful for
compliance and for responding to new vulnerabilities quickly.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: require-cyclonedx-sbom
spec:
  validationActions:
    - Deny
  webhookConfiguration:
    timeoutSeconds: 15
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['pods']
  matchImageReferences:
    - glob: 'ghcr.io/myorg/*'
  attestors:
    - name: notary
      notary:
        certs:
          value: |
            -----BEGIN CERTIFICATE-----
            MIIBjTCCATOgAwIBAgIUdMiN3gC...
            -----END CERTIFICATE-----
  attestations:
    - name: sbom
      referrer:
        type: sbom/cyclone-dx
  validations:
    - expression: >-
        images.containers.map(image,
          verifyImageSignatures(image, [attestors.notary])
        ).all(e, e > 0)
      message: 'Image must be signed with the Notary certificate'
    - expression: >-
        images.containers.map(image,
          verifyAttestationSignatures(image, attestations.sbom, [attestors.notary])
        ).all(e, e > 0)
      message: 'Image must have a valid SBOM attestation'
    - expression: >-
        images.containers.map(image,
          extractPayload(image, attestations.sbom).bomFormat == 'CycloneDX'
        ).all(e, e)
      message: 'SBOM must be in CycloneDX format'
```

Three validation rules chained together:

1. Verify the image signature
2. Verify the SBOM attestation is signed
3. Check the SBOM content. It must be CycloneDX format

> Note: `extractPayload()` must always come after `verifyAttestationSignatures()`.
> Trying to extract from an unverified attestation causes an error. Always verify first,
> then extract.

## Digest pinning: mutable tags are a risk

Image tags like `myimage:latest` or `myimage:v1.2.3` are mutable. The same tag can
point to a completely different image tomorrow if someone pushes to it. The cluster
would pull the new image without knowing anything changed.

Image digests solve this. A digest is a **cryptographic hash** of the exact image content-
`myimage@sha256:abc123...` always refers to exactly that one image, forever.

```yaml
spec:
  matchImageReferences:
    - glob: 'ghcr.io/myorg/*'
  validationConfigurations:
    mutateDigest: true # Kyverno rewrites image:tag to image@sha256:digest
    verifyDigest: true # reject images not using digests
    required: true # all images must pass validation
```

`mutateDigest: true` is particularly useful as Kyverno acts like a MutatingPolicy here.
The developer writes `myimage:v1.2.3.` Kyverno automatically rewrites it to
`myimage@sha256:abc123...` before the Pod is stored. The developer uses a friendly tag.
The cluster runs a pinned digest.

## Private registries: credentials

For images in private registries, Kyverno needs authentication to verify signatures:

```yaml
spec:
  matchImageReferences:
    - glob: 'registry.mycompany.com/*'
  credentials:
    allowInsecureRegistry: false # always HTTPS
    providers:
      - 'default' # use Kubernetes imagePullSecrets
    secrets:
      - 'registry-credentials' # must live in the kyverno namespace
```

The Secret must live in the `kyverno` namespace and not the application namespace.
`allowInsecureRegistry: false` means HTTP registries are rejected. Always HTTPS.

## The three CEL functions used constantly

```text
verifyImageSignatures(image, [attestors.name])
```

Returns a number > 0 if the image signature is verified. Check with `.all(e, e > 0)`
across all containers.

```text
verifyAttestationSignatures(image, attestations.name, [attestors.name])
```

Verifies that a specific attestation exists and is signed. Same pattern as it returns a
number > 0 if verified.

```text
extractPayload(image, attestations.name)
```

Gets the actual content of the attestation so specific fields can be checked like
confirming an SBOM is CycloneDX format or that a vulnerability scan has no critical
findings. Always call `verifyAttestationSignatures` first.

## Scoping your policy

Same pattern as all other policy types:

- `ImageValidatingPolicy` — cluster-wide image verification across all namespaces
- `NamespacedImageValidatingPolicy` — scoped to one namespace, manageable without
  cluster-admin permissions

```yaml
apiVersion: policies.kyverno.io/v1
kind: NamespacedImageValidatingPolicy
metadata:
  name: verify-team-images
  namespace: development
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: [CREATE, UPDATE]
        resources: [pods]
  matchImageReferences:
    - glob: 'ghcr.io/myorg/dev-*'
  attestors:
    - name: devAttestor
      cosign:
        keyless:
          identities:
            - issuer: 'https://token.actions.githubusercontent.com'
              subjectRegExp: '.*@myorg.github.io'
  validations:
    - message: 'Image must be signed by the development team pipeline'
      expression: >-
        images.containers.map(image,
          verifyImageSignatures(image, [attestors.devAttestor])
        ).all(e, e > 0)
```

The development team manages this policy themselves. Their images, their signing
rules, their namespace. No cluster-admin is needed.

## PolicyException (for images that genuinely can't be signed)

Sometimes a third-party image or a legacy workload can't be signed yet. The policy
needs to stay intact for everything else, but one specific resource needs an exception.

```yaml
apiVersion: kyverno.io/v2
kind: PolicyException
metadata:
  name: allow-unsigned-legacy
  namespace: legacy-namespace
spec:
  exceptions:
    - policyName: require-signed-images
      ruleNames:
        - require-signed-images
  match:
    any:
      - resources:
          kinds:
            - Pod
          namespaces:
            - legacy-namespace
```

The policy stays strong for everything else. The exception is auditable, reviewable,
and temporary. It should come with a plan to actually sign those images eventually.

## The complete picture (all five policy types together)

This is the full Kyverno policy model:

```text
New namespace created
        ↓
GeneratingPolicy
  - NetworkPolicy created
  - ResourceQuota created
  - pull secret cloned

Developer deploys app
        ↓
MutatingPolicy
  - missing labels added
  - default resource limits set
  - security context injected

ValidatingPolicy (checks)
  - labels present
  - resource limits set
  - security context configured

ImageValidatingPolicy
  - image signature verified
  - vulnerability scan attestation verified
  - digest pinned

        ↓
Pod admitted and running

Next morning at 2 AM
        ↓
DeletingPolicy
  - completed Jobs cleaned up
  - stale test pods removed
```

The developer creates a namespace, writes their app YAML, and deploys. Kyverno handles
provisioning, defaults, enforcement, image trust, and cleanup. The platform team wrote
the policies once. The policies continue enforcing those rules automatically.
