---
date: 2026-08-12
title: 'Sigstore in an Isolated Environment: Cosign, RSTUF, Trust Root Distribution, and PR #16591 in Kyverno'
tags:
  - General
  - Security
excerpt: 'Kyverno image verification fails with private RSTUF mirrors. PR #16591 fixes this. Includes a breakdown of TUF repository structure and Sigstore configuration internals.'
authors:
  - name: Roman Petrov
draft: false
---

In today's reality, separately explaining the need for artifact signing and software supply chain protection is already redundant. Many companies are either thinking about it or are already using the relevant solutions.

In this article, I'll describe how I solved the task of signing OCI images in an isolated environment, how I organized the distribution of Sigstore configurations via TUF, and what compatibility nuances I encountered when integrating with Kyverno. I'll also separately cover how this experience led to the preparation of [#16591](https://github.com/kyverno/kyverno/pull/16591).

## The Task

At the beginning of this year, I started researching artifact signing. First and foremost, I was interested in signing OCI images. **Sigstore/Cosign** and the keyless approach were chosen as the main stack.

The goals were as follows:

- deploy Sigstore infrastructure inside an internal environment;
- configure OCI image signing without long-lived user keys;
- ensure signature validation on target environments;
- centrally distribute the trust root, certificates, and configurations;
- prepare the foundation for further integration with admission control policies, particularly with Kyverno.

## Basic Sigstore Environment

The following components were used in my environment:

- [CTLog](https://github.com/sigstore/scaffolding);
- [Fulcio](https://github.com/sigstore/fulcio);
- [Rekor](https://github.com/sigstore/rekor);
- [Trillian](https://github.com/google/trillian).

The environment was deployed using Helm charts: [sigstore/helm-charts](https://github.com/sigstore/helm-charts).

There were no major issues with deploying CTLog, Fulcio, Rekor, and Trillian. However, I discovered that the Helm charts were generally not ready to operate in an environment using a Service Mesh - in my case, **Istio**.

To fix the issues I found, I prepared several pull requests to the Sigstore Helm charts, and they were accepted. Trust for the internal OIDC provider was also configured on the Fulcio side.

At this stage, I had working infrastructure that allowed certificates to be issued via Fulcio, entries to be published to Rekor, and CTLog to be used.

## Sigstore Configurations for Cosign

CTLog, Fulcio, and Rekor have their own public certificates and keys. This information needs to be aggregated somehow and passed to client tools.

Previously, such parameters were usually passed to Cosign via CLI arguments. But with the release of **sigstore-go v1.x**, it became possible to define them through configuration files. These files are `trusted_root.json` and `signing_config.json`.

Example of generating JSON files:

```sh
cosign trusted-root create \
  --fulcio="url=https://fulcio.sigstore.example,certificate-chain=./cert-0.crt,start-time=2026-05-20T00:00:00Z" \
  --rekor="url=https://rekor.sigstore.example,public-key=./rekor.pub,start-time=2026-05-20T00:00:00Z" \
  --ctfe="url=https://ctlog.sigstore.example,public-key=./ctlog.pub,start-time=2026-05-20T00:00:00Z"

cosign signing-config create \
  --fulcio="url=https://fulcio.sigstore.example,api-version=1,start-time=2026-05-20T00:00:00Z,operator=sigstore.example" \
  --rekor="url=https://rekor.sigstore.example,api-version=1,start-time=2026-05-20T00:00:00Z,operator=sigstore.example" \
  --rekor-config="ANY" \
  --oidc-provider="url=https://git.example,api-version=1,start-time=2026-05-20T00:00:00Z,operator=sigstore.example"
```

As a result:

- `trusted_root.json` is required for signature validation;
- `trusted_root.json` and `signing_config.json` are required for signing.

At this stage, the infrastructure already allowed OCI images to be signed and signatures to be verified. But the next question appeared: how should these configurations be distributed to target environments and kept up to date?

## Why TUF Was Needed

Manually distributing `trusted_root.json` and `signing_config.json` across all environments is inconvenient. This is especially true if you take into account future certificate and key rotation, as well as changes to service URLs.

For this task, the Sigstore project suggests using **TUF - The Update Framework**. TUF allows securely distributing the trust root, metadata, and target files, protecting clients against substitution and replay attacks.

In the case of Sigstore, TUF is convenient for distributing:

- `trusted_root.json`;
- `signing_config.json`;
- public keys;
- certificates;
- other configuration files.

Before choosing a solution, I considered several options.

### 1. Public Sigstore TUF

Sigstore has a public TUF server at [tuf-repo-cdn.sigstore.dev](https://tuf-repo-cdn.sigstore.dev/). Its implementation is located in the [sigstore/root-signing](https://github.com/sigstore/root-signing) repository. This is the reference approach from a security perspective, but for a company's internal environment it turned out to be excessive and not the most convenient option to operate.

### 2. TUF Server from sigstore/scaffolding

The next option was the TUF server from [sigstore/scaffolding](https://github.com/sigstore/scaffolding). However, in the Kubernetes context, it turned out to be of limited use for production operation.

The main issues were:

- the project does not allow using your own keys to sign the root;
- new keys are generated on every Pod restart;
- the root is signed with new keys after a restart;
- keys are stored in a Kubernetes Secret but are not correctly reused on the next startup;
- when running several replicas, you can end up with separate instances, each with its own trust root.

### 3. Repository Service for TUF (RSTUF)

Next, I looked at the **Repository Service for TUF** project, or **RSTUF**: [repository-service-tuf](https://github.com/repository-service-tuf). The project is under the OpenSSF umbrella. Its main idea is to implement the TUF specification not as a rigid manual process, but as a ready-made microservice backend with an API that can be integrated into existing automation.

RSTUF fits well into the Kubernetes approach and assumes two main user scenarios:

- **Public TUF repository.** HTTP access to the contents of a storage backend or S3 bucket, that is, to the output produced by worker Pods;
- **Administrative API.** A server through which repository bootstrap, configuration, and root signing are performed.

The following two domains will be used in the examples:

- `rstuf.sigstore.example` - for serving the TUF repository;
- `rstuf-api.sigstore.example` - for the administrative API.

## How the TUF Repository Is Structured

Let's look at the structure of a TUF repository as applied to Sigstore. In the basic case, a TUF server provides a set of metadata and target files:

- **`1.root.json`, `2.root.json`, ...** - the trust root of the TUF repository. It contains information about keys and roles trusted by the client: root, timestamp, snapshot, and targets. `root.json` also specifies signature thresholds and metadata expiration periods. This is the file from which the client starts building the chain of trust. The version number increases during rotation.
- **`timestamp.json`** - this file contains the hash and size of `snapshot.json`. It allows the client to ensure that the downloaded snapshot has not been tampered with and is not outdated. `timestamp.json` is updated more frequently than other metadata and protects clients from replay attacks, where an attacker tries to serve them an outdated repository state.
- **`1.snapshot.json`, `2.snapshot.json`, ...** - contains information about the versions and hashes of other metadata. Primarily `targets.json` and, if present, delegated target metadata. It is needed to verify the integrity and consistency of the repository state.
- **`1.targets.json`, `2.targets.json`, ...** - contains information about target files: names, sizes, hashes, and additional custom metadata if needed.
- **`targets/...`** - the directory with the target files themselves. In the case of Sigstore, this may contain `trusted_root.json`, `signing_config.json`, public keys, certificates, and other configuration files. The client downloads these files separately after verifying the TUF metadata.

In other words, `targets.json` contains metadata: names, sizes, hashes, and so on. The actual files with their contents are available in the `targets` directory.

## First Attempt to Integrate RSTUF and Cosign

A quick look at the documentation and Cosign source code showed that the TUF server must contain the following artifacts:

- `trusted_root.json`;
- `signing_config.json`.

These files had already been generated using Cosign. So the first idea was simple: add them as artifacts to the TUF repository via the `repository-service-tuf` CLI. To publish metadata about the files, I used the command `rstuf artifact add ...`. I placed the `trusted_root.json` and `signing_config.json` files themselves under the path `https://rstuf.sigstore.example/targets/...`.

After that, I tried to configure Cosign to trust our RSTUF server:

```sh
wget -q -O root.json https://rstuf.sigstore.example/1.root.json

cosign initialize \
  --mirror="https://rstuf.sigstore.example" \
  --root="./root.json"
```

The expectation was that Cosign would fetch the TUF metadata, verify it, download the required target files, and initialize the local trusted state.

But it did not work on the first try. I had to go deeper - into the **Cosign v3.1.1** source code, the behavior of **go-tuf**, and RSTUF specifics.

### Investigation Details

During the investigation, several important details became clear:

1. **Filename mismatch.** Cosign expects exactly the file `signing_config.v0.2.json`, with the version specified in the filename, and the file contents must correspond to it. The file generated via `cosign signing-config` contains the field `"mediaType": "application/vnd.dev.sigstore.signingconfig.v0.2+json"`. It also indicates the configuration version.

2. **Consistent snapshots.** The RSTUF server bootstrap using `rstuf admin ceremony` was performed with default settings, so `consistent_snapshot` was set to `true`. More information about consistent snapshots can be found in the [TUF specification](https://theupdateframework.github.io/specification/latest/#consistent-snapshots). When `consistent_snapshot` is true, the TUF client - in the case of Cosign, **sigstore-go**, which uses **go-tuf/v2** - inserts the hash into the URL when downloading target files. Instead of `targets/trusted_root.json`, the client requests `targets/<hash>.trusted_root.json`. Accordingly, the HTTP server must serve files from such paths. This means the files need to be placed in the `targets` directory with the hash in the filename: `<hash>.trusted_root.json` and `<hash>.signing_config.v0.2.json`.

3. **Hash algorithm incompatibility.** If you use `rstuf artifact add ...` to add information about artifacts, the **blake2b-256** algorithm is used for the checksum, and it cannot be changed or selected. Cosign, in turn, has limitations and is compatible only with **sha256** and **sha512**. In addition, the go-tuf module being used takes the first hash from the map. Therefore, I had to stop using the `repository-service-tuf` CLI and use the RSTUF API to upload artifact information with a single `sha256` hash:

```sh
curl -X POST https://rstuf-api.sigstore.example/api/v1/artifacts/ \
  -H 'Content-Type: application/json' \
  -d '{
    "artifacts": [{
      "path": "trusted_root.json",
      "info": {
        "length": <length>,
        "hashes": {
          "sha256": "<sha256>"
        }
      }
    }],
    "publish_artifacts": true
  }'

curl -X POST https://rstuf-api.sigstore.example/api/v1/artifacts/ \
  -H 'Content-Type: application/json' \
  -d '{
    "artifacts": [{
      "path": "signing_config.v0.2.json",
      "info": {
        "length": <length>,
        "hashes": {
          "sha256": "<sha256>"
        }
      }
    }],
    "publish_artifacts": true
  }'
```

4. **Manual file placement.** You need to place the `trusted_root.json` and `signing_config.v0.2.json` files yourself under the path `https://rstuf.sigstore.example/targets/...`. At the same time, you need to add the checksum to the beginning of the filenames: `<hash>.trusted_root.json` and `<hash>.signing_config.v0.2.json`.

After accounting for all these details, I managed to connect RSTUF, CTLog, Fulcio, Rekor, Trillian, the OIDC provider, and Cosign.

## Final Process for Cosign

1. **Initialize Cosign from the internal TUF repository:**

```sh
wget -q -O root.json https://rstuf.sigstore.example/1.root.json

cosign initialize \
  --mirror="https://rstuf.sigstore.example" \
  --root="./root.json"
```

2. **Sign an OCI image:**

```sh
SIGSTORE_ID_TOKEN=... \
  cosign sign \
    oci-registry.example/ko-app@sha256:...
```

3. **Verify the signature:**

```sh
cosign verify \
  --certificate-oidc-issuer="https://git.example" \
  --certificate-identity-regexp="^https://git\.example/.*" \
  oci-registry.example/ko-app@sha256:...
```

## Interim Summary

To sign OCI images in an isolated environment, the minimum required Sigstore components are **CTLog**, **Fulcio**, **Rekor**, and **Trillian**. For convenient and secure operation, you also need a mechanism for distributing and rotating trust configurations. In my case, this role is performed by a TUF server based on **RSTUF**. It distributes `trusted_root.json` and `signing_config.v0.2.json`.

As a result, the TUF server needs to keep both the metadata and the files themselves up to date:

- `trusted_root.json`;
- `signing_config.v0.2.json`.

## Verifying OCI Images in Kubernetes via Kyverno

After signing and verifying OCI images with Cosign started working, the next step was to verify images during deployment to Kubernetes.

For this purpose, **Kyverno v1.18.2** was deployed in the cluster, and an **ImageValidatingPolicy** was prepared. It verifies signatures of images from the internal OCI registry using Cosign and our RSTUF-based TUF repository.

Example policy:

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: sigstore.example
spec:
  evaluation:
    mode: Kubernetes
    background:
      enabled: false
  webhookConfiguration:
    timeoutSeconds: 30
  validationActions: [Deny]
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        resources: ['pods']
        operations: ['CREATE', 'UPDATE']
    namespaceSelector:
      matchExpressions:
        - key: kubernetes.io/metadata.name
          operator: In
          values: [ns-ko-app]
  matchImageReferences:
    - glob: 'oci-registry.example/*'
  attestors:
    - name: cosign
      cosign:
        tuf:
          mirror: 'https://rstuf.sigstore.example'
          root:
            # curl -s https://rstuf.sigstore.example/1.root.json | base64
            data: ...
        keyless:
          identities:
            - issuer: 'https://git.example'
              subjectRegExp: '^https://git\.example/.*'
  validations:
    - message: 'Failed image signature verification'
      expression: 'images.containers.map(image, verifyImageSignatures(image, [attestors.cosign])).all(e, e > 0)'
```

The expectation was simple: when a Pod is created or updated in the `ns-ko-app` namespace, Kyverno should access the internal TUF repository, retrieve the trusted Sigstore materials, and verify the OCI image signature.

I tried restarting a Pod in the `ns-ko-app` namespace - the Pod did not start. That meant I had to dive deeper and look at how Kyverno works with TUF during Sigstore signature verification.

> **Important:** the Kyverno project is actively evolving, so below I will compare the behavior before PR [#16591](https://github.com/kyverno/kyverno/pull/16591) and after it was accepted.

## How Kyverno Worked with TUF Before PR #16591

The TUF integration code was located in the file `pkg/image/verifiers/ivpol/cosign/opts.go`. The main logic was implemented in the `initTUFAndFetch` function:

```go
func initTUFAndFetch(ctx context.Context, t *v1beta1.TUF) (*sigstoreTrustMaterial, error) {
    // Step 1: read optional root bytes - pure I/O, no TUF lock needed.
    ...

    // Step 2: hold the process-wide TUF mutex for init + all reads so
    // that no other goroutine can reinitialize the singleton between them.
    // Note: fn must call sigstore/TUF functions directly (not through
    // sigstoretuf wrappers) to avoid deadlocking on the same mutex.
    var m sigstoreTrustMaterial
    err := sigstoretuf.WithLock(func() error {
        // 1. TUF initialization via go-tuf v0.7.0
        if err := tuf.Initialize(ctx, mirror, rootBytes); err != nil {
            return fmt.Errorf("failed to initialize TUF client (mirror=%q): %w", mirror, err)
        }
        var err error
        // 2. Getting Rekor keys via cosign.GetRekorPubs, target: rekor.pub
        m.rekorPubKeys, err = cosign.GetRekorPubs(ctx)
        if err != nil {
            return fmt.Errorf("getting Rekor public keys: %w", err)
        }
        // 3. Getting CTLog keys via cosign.GetCTLogPubs, target: ctfe.pub
        m.ctlogPubKeys, err = cosign.GetCTLogPubs(ctx)
        if err != nil {
            return fmt.Errorf("getting CTLog public keys: %w", err)
        }
        tufClient, err := tuf.NewFromEnv(ctx)
        if err != nil {
            return fmt.Errorf("initializing tuf client: %w", err)
        }
        // 4. Getting trusted_root.json via tuf.NewFromEnv
        targetBytes, err := tufClient.GetTarget("trusted_root.json")
        if err != nil {
            return fmt.Errorf("error getting target trusted_root.json: %w", err)
        }
        m.trustedRoot, err = root.NewTrustedRootFromJSON(targetBytes)
        if err != nil {
            return fmt.Errorf("error creating trusted root: %w", err)
        }
        // 5. Getting Fulcio certificates via fulcioroots.Get
        m.fulcioRoots, err = fulcioroots.Get()
        if err != nil {
            return fmt.Errorf("failed to fetch Fulcio roots: %w", err)
        }
        m.fulcioIntermediates, err = fulcioroots.GetIntermediates()
        if err != nil {
            return fmt.Errorf("failed to fetch Fulcio intermediates: %w", err)
        }
        return nil
    })
    ...
}
```

In other words, Kyverno sequentially tried to retrieve several types of trusted materials, or **trust material**:

- Rekor public keys;
- CTLog public keys;
- `trusted_root.json`;
- Fulcio root and intermediate certificates.

The key point: **Rekor, CTLog, and Fulcio materials were requested as separate TUF targets.** `trusted_root.json` was also downloaded separately, but it was not used as a fallback data source for these materials.

The old logic effectively assumed the presence of a structure similar to the classic Sigstore TUF repository:

```
repository/
|-- 1.root.json
|-- 1.targets.json
|-- targets/
|   |-- <hash>.rekor.pub
|   |-- <hash>.ctfe.pub
|   |-- <hash>.fulcio.crt.pem
|   |-- <hash>.fulcio_v1.crt.pem
|   |-- <hash>.fulcio_intermediate_v1.crt.pem
|   \-- <hash>.trusted_root.json
|-- 1.snapshot.json
\-- timestamp.json
```

I did not want to reproduce this entire structure and additionally publish separate Rekor, CTLog, and Fulcio files when all the necessary data was already present in `trusted_root.json`.

### What Was Happening on the RSTUF Side

RSTUF supports two delegation modes:

- **Bins** - [TAP-15 succinct_roles](https://github.com/theupdateframework/taps/blob/master/tap15.md), that is, hash-bin delegations, where target files are distributed across N buckets, or bins, based on the hash of their name.
- **Custom Delegations** - custom delegated roles with explicit path patterns instead of automatic hash-based distribution.

With **Bins** mode, the problem was expected: the **go-tuf v0.7.0** library being used cannot work with TAP-15 `succinct_roles` and does not understand the metadata for this type of delegation.

When using **Custom Delegations**, RSTUF creates a delegated role whose name is specified during bootstrap. Target files are assigned to this delegated role when their paths match. At the same time, the top-level `targets.json` remains empty: it contains no target files, only the delegation description.

Kyverno also had a problem with Custom Delegations.

The issue was not only in go-tuf v0.7.0 itself, but also in the `sigstore/pkg/tuf` wrapper from `github.com/sigstore/sigstore` v1.10.8. Inside `sigstore/pkg/tuf/client.go`, the following logic was used:

```go
func (t *TUF) updateMetadataAndDownloadTargets() error {
	targetFiles, err := t.updateClient()
	if err != nil {
		return err
	}

	for name, targetMeta := range targetFiles {
		if err := maybeDownloadRemoteTarget(name, targetMeta, t); err != nil {
			return err
		}
	}

	return nil
}
```

`updateClient()` called `client.Update()` from go-tuf v0.7.0. This method updated the metadata chain - root, timestamp, snapshot, targets - and returned `c.targets`, meaning only the target files from the top-level `targets.json`. In the case of Custom Delegations, `targets.json` was empty, so `updateClient()` returned an empty map. No target files from the delegated role were downloaded.

As a result:

- `tuf.Initialize()` completed successfully - the metadata chain root -> timestamp -> snapshot -> targets -> delegated role was validated;
- But when trying to retrieve any target file from the delegated role, an error occurred: the file was missing from the local cache.

At this stage, I collected information about the behavior of Kyverno v1.18.2 and RSTUF implementation details. This made it possible to prepare PR [#16591](https://github.com/kyverno/kyverno/pull/16591).

## What Changed in PR #16591

PR [#16591](https://github.com/kyverno/kyverno/pull/16591) solves two main problems:

- A new TUF client based on **sigstore-go/pkg/tuf** and **go-tuf/v2** is used to retrieve `trusted_root.json`; it supports TAP-15 and works correctly with delegations;
- A fallback mechanism has been added: if separate TUF targets are unavailable, Rekor, CTLog, and Fulcio materials are extracted from `trusted_root.json`.

PR [#16591](https://github.com/kyverno/kyverno/pull/16591) was based on two preceding PRs:

- [#16663](https://github.com/kyverno/kyverno/pull/16663) - introduced `pkg/sigstoretuf/` with a process-wide mutex for TUF, the `WithLock` function, and the `sigstoreTrustMaterial` structure
- [#16666](https://github.com/kyverno/kyverno/pull/16666) - added `resolveTrustedMaterial` for inline `trustedRoot` and support for signed-timestamp bundles

**Final result:** after PR [#16591](https://github.com/kyverno/kyverno/pull/16591), Kyverno works correctly with private TUF mirrors based on RSTUF, including hash-bin delegations, that is, TAP-15 `succinct_roles`.

## Conclusion

This experience shows that running Sigstore in production inside an isolated environment is not just about "bringing up Fulcio and Rekor." You also need to think through trust root distribution, TUF client compatibility, configuration rotation, and integration with admission control.

Solving this task was interesting. I hope this material helps those facing a similar challenge - signing and validating OCI images in an isolated environment.

## Additional Notes

- **go-tuf v0.7.0** is a transitive dependency pulled in through the `github.com/sigstore/sigstore` v1.10.8 module;
- I am aware of **Rekor v2**, but in the context of this article it is only indirectly related. This article examines one specific implementation option for internal Sigstore infrastructure and integration with TUF/Kyverno;
- During the work, some issues were also found on the RSTUF side. I prepared pull requests for some of them, and they were accepted. For example: [repository-service-tuf-worker#928](https://github.com/repository-service-tuf/repository-service-tuf-worker/pull/928).
