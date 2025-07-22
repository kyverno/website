---
title: CEL Libraries
description: >-
    Kyverno enhances Kubernetes' CEL environment with libraries enabling complex policy logic and advanced features for ValidatingPolicy and MutatingPolicy.
weight: 10
---

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex policy logic and advanced features. These libraries are available in both ValidatingPolicy and MutatingPolicy.

## Resource library

The **Resource library** provides functions like `resource.Get()` and `resource.List()` to retrieve Kubernetes resources from the cluster, either individually or as a list. These are useful for writing policies that depend on the state of other resources, such as checking existing ConfigMaps, Services, or Deployments before validating or mutating a new object.

| CEL Expression | Purpose |
|----------------|---------|
| `resource.Get("v1", "configmaps", "default", "clusterregistries").data["registries"]` | Fetch a ConfigMap value from a specific namespace |
| `resource.List("apps/v1", "deployments", "").items.size() > 0` | Check if there are any Deployments across all namespaces |
| `resource.Post("authorization.k8s.io/v1", "subjectaccessreviews", {…})` | Perform a live SubjectAccessReview (authz check) against the Kubernetes API |
| `resource.List("apps/v1", "deployments", object.metadata.namespace).items.exists(d, d.spec.replicas > 3)` | Ensure at least one Deployment in the same namespace has more than 3 replicas |
| `resource.List("v1", "services", "default").items.map(s, s.metadata.name).isSorted()` | Verify that Service names in the `default` namespace are sorted alphabetically |
| `resource.List("v1", "services", object.metadata.namespace).items.map(s, s.metadata.name).isSorted()` |  Use `object.metadata.namespace` to dynamically target the current resource's namespace |

## HTTP library

The **HTTP library** allows interaction with external HTTP/S endpoints using `http.Get()` and `http.Post()` within policies. These functions enable real-time validation against third-party systems, remote config APIs, or internal services, supporting secure communication via CA bundles for HTTPS endpoints.

| **CEL Expression**        | **Purpose**                          |
|-------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| `http.Get("https://internal.api/health").status == "ok"  `                                                                      | Validate external service health before proceeding                     |
| `http.Get("https://service/data").metadata.team == object.metadata.labels.team `                                                | Enforce label matching from remote service metadata                    |
| `http.Post("https://audit.api/log", {"kind": object.kind}, {"Content-Type": "application/json"}).logged == true`               | Confirm logging of the resource to an external system                  |
| `http.Get("https://certs.api/rootCA").cert == object.spec.cert`                                                                 | Validate a certificate field in the object against external data       |

## User library

The **User library** includes functions like `parseServiceAccount()` to extract metadata from the user or service account that triggered the admission request. These expressions help enforce policies based on user identity, namespace association, or naming conventions of service accounts.

| CEL Expression | Purpose |
|----------------|---------|
| `parseServiceAccount(request.userInfo.username).Name == "my-sa"` | Validate that the request is made by a specific ServiceAccount |
| `parseServiceAccount(request.userInfo.username).Namespace == "system"` | Ensure the ServiceAccount belongs to the `system` namespace |
| `parseServiceAccount(request.userInfo.username).Name.startsWith("team-")` | Enforce naming convention for ServiceAccounts |
| `parseServiceAccount(request.userInfo.username).Namespace in ["dev", "prod"]` | Restrict access to specific namespaces only |

## Image library

The **Image library** offers functions to parse and analyze image references. It allows policy authors to inspect registries, tags, and digests, ensuring image standards, such as requiring images from a specific registry or prohibiting tags, are enforced.

| CEL Expression | Purpose |
|----------------|---------|
| `image("nginx:latest")` | Convert an image string into an image object (must be used before calling any image methods) |
| `isImage("nginx:latest")` | Check if the string is a valid image |
| `image("nginx:latest").registry()` | Get the image registry (e.g., `docker.io`) |
| `image("nginx:latest").repository()` | Get the image repository path (e.g., `library/nginx`) |
| `image("nginx:latest").identifier()` | Get the image identifier (e.g., tag or digest part) |
| `image("nginx:latest").tag()` | Get the tag portion of the image (e.g., `latest`) |
| `image("nginx@sha256:abcd...").digest()` | Get the digest portion of the image |
| `image("nginx:sha256:abcd...").containsDigest()` | Check if the image string includes a digest |
| `object.spec.containers.map(c, image(c.image)).map(i, i.registry()).all(r, r == "ghcr.io")` | Ensure all container images come from the `ghcr.io` registry |
| `object.spec.containers.map(c, image(c.image)).all(i, i.containsDigest())` | Ensure all images include a digest |

## ImageData library

The **ImageData library** extends image inspection with OCI registry metadata like architecture, OS, digests, tags, and layers. Using `image.GetMetadata()`, it fetches details about container images from OCI registries, enabling precise validation of image content and compatibility.

| CEL Expression | Purpose |
|----------------|---------|
| `image.GetMetadata("nginx:1.21").config.architecture == "amd64"` | Ensure the image architecture is `amd64` |
| `image.GetMetadata("nginx:1.21").config.os == "linux"` | Verify the image is built for Linux |
| `image.GetMetadata("nginx:1.21").config.author == "docker"` | Check the image author |
| `image.GetMetadata("nginx:1.21").config.variant == "v7"` | Validate architecture variant |
| `image.GetMetadata("nginx:1.21").config.created != ""` | Ensure image has a creation timestamp |
| `image.GetMetadata("nginx:1.21").config.docker_version.startsWith("20.")` | Check Docker version used to build the image |
| `image.GetMetadata("nginx:1.21").config.container == "nginx"` | Validate container name |
| `image.GetMetadata("nginx:1.21").config.os_features.exists(f, f == "sse4")` | Check if specific OS feature exists |
| `image.GetMetadata("nginx:1.21").digest.startsWith("sha256:")` | Validate that image has a proper SHA256 digest |
| `image.GetMetadata("nginx:1.21").manifest.schemaVersion == 2` | Check if the image manifest uses schema version 2 |
| `image.GetMetadata("nginx:1.21").manifest.mediaType == "application/vnd.docker.distribution.manifest.v2+json"` | Validate the media type of the image manifest |
| `image.GetMetadata("nginx:1.21").manifest.layers.size() > 0` | Ensure the manifest lists image layers |
| `image.GetMetadata("nginx:1.21").manifest.annotations.exists(a, a.key == "org.opencontainers.image.title")` | Check if a specific annotation is present |
| `image.GetMetadata("nginx:1.21").manifest.subject != null` | Check if the image has a subject (e.g., SBOM reference) |
| `image.GetMetadata("nginx:1.21").manifest.config.mediaType.contains("json")` | Validate that the config descriptor has a JSON media type |
| `image.GetMetadata("nginx:1.21").manifest.layers.all(l, l.mediaType.startsWith("application/vnd.docker"))` | Ensure all layers have Docker-compatible media types |

## GlobalContext library

The **GlobalContext library** introduces shared variables across policies through `globalContext.Get()`. These variables are populated from external API calls via `GlobalContextEntry` resources, making it possible to validate requests against cluster-wide configurations or aggregated data with improved efficiency.

| **CEL Expression**                                                       | **Purpose**                                                         |
|--------------------------------------------------------------------------|----------------------------------------------------------------------|
| `globalContext.Get("gctxentry-apicall-correct", "") != 0`                  | Ensure a specific deployment exists before allowing resource creation |
| `globalContext.Get("team-cluster-values", "").someValue == "enabled"`     | Validate shared cluster-wide configuration using global context data |
| `globalContext.Get("global-pod-labels", "").contains(object.metadata.labels)` | Check that pod labels match predefined global labels                | 