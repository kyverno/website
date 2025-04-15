---
title: ValidatingPolicy
description: >-
    Validate Kubernetes Resources or JSON payloads
weight: 30
---

The Kyverno `ValidatingPolicy` type extends the Kubernetes `ValidatingAdmissionPolicy` type for complex policy evaluations and other features required for Policy-as-Code. A `ValidatingPolicy` is a superset of a `ValidatingAdmissionPolicy` and contains additional fields for Kyverno specific features.

## Comparison with ValidatingAdmissionPolicy

The table below compares major features across the Kubernetes `ValidatingAdmissionPolicy` and Kyverno `ValidatingPolicy` types.

| Feature            | ValidatingAdmissionPolicy    |  ValidatingPolicy         |
|--------------------|------------------------------|---------------------------------------------|
| Enforcement        | Admission                    | Admission, Background, Pipelines, ...       |
| Payloads           | Kubernetes                   | Kubernetes, Any JSON or YAML                |
| Distribution       | Kubernetes                   | Helm, CLI, Web Service, API, SDK            |
| CEL Library        | Basic                        | Extended                                    |
| Bindings           | Manual                       | Automatic                                   |
| Auto-generation    | -                            | Pod Controllers, ValidatingAdmissionPolicy  |
| External Data      | _                            | Kubernetes resources or API calls           |
| Caching            | _                            | Global Context, image verification results  |
| Background scans   | -                            | Periodic, On policy creation or change      |
| Exceptions         | -                            | Fine-grained exceptions                     |
| Reporting          | _                            | Policy WG Reports API                       |
| Testing            | _                            | Kyverno CLI (unit), Chainsaw (e2e)          |


## Additional Fields

The `ValidatingPolicy` extends the [Kubernetes ValidatingAdmissionPolicy](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) with the following additional fields for Kyverno features. A complete reference is provided in the [API specification](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.ValidatingPolicy)

### evaluation

The `spec.evaluation` field defines how the policy is applied and how the payload is processed. It can be used to enable, or disable, admission request processing and background processing for a policy. It is also used to manage whether the payload is processed as JSON or a Kubernetes resource.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: sample
spec:
  evaluation:
    admission:
      enabled: false
    background:
      enabled: true
    mode : Kubernetes
  ...
```

The `mode` can be set to `JSON` for non-Kubernetes payloads.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.EvaluationConfiguration) for details.

### webhookConfiguration

The `spec.webhookConfiguration` field defines properties used to manage the Kyverno admission controller webhook settings.


```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-deployment-labels
spec:
  webhookConfiguration:
   timeoutSeconds: 15
  ...
```

In the policy above, `webhookConfiguration.timeoutSeconds` is set to `15`, which defines how long the admission request waits for policy evaluation. The default is `10s`, and the allowed range is `1–30s`. After this timeout, the request may fail or ignore the result based on the failure policy. Kyverno reflects this setting in the generated `ValidatingWebhookConfiguration`.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.WebhookConfiguration) for details.


### autogen

The `spec.autogen` field defines policy auto-generation behaviors, to automatically generate policies for pod controllers and geerate `ValidatingAdmissionPolicy` types for Kubernetes API server execution.

Here is an example of generating policies for deployments, jobs, cronjobs, and statefulsets and also generating a `ValidatingAdmissionPolicy` from the `ValidatingPolicy` declaration:

```yaml
 apiVersion: policies.kyverno.io/v1alpha1
 kind: ValidatingPolicy
 metadata:
   name: disallow-capabilities
 spec:
   autogen:
    validatingAdmissionPolicy:
     enabled: true
    podControllers:
      controllers:
       - deployments
       - jobs
       - cronjobs
       - statefulsets
```

Generating a `ValidatingAdmissionPolicy` from a `ValidatingPolicy` provides the benefits of faster and more resilient execution during admission controls while leveraging all features of Kyverno.

Refer to the [API Reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.AutogenConfiguration) for details.


## Kyverno CEL Libraries

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex policy logic and advanced features.

### Resource library

The **Resource library** provides functions like `resource.Get()` and `resource.List()` to retrieve Kubernetes resources from the cluster, either individually or as a list. These are useful for writing policies that depend on the state of other resources, such as checking existing ConfigMaps, Services, or Deployments before validating a new object.

| CEL Expression | Purpose |
|----------------|---------|
| `resource.Get("v1", "configmaps", "default", "clusterregistries").data["registries"]` | Fetch a ConfigMap value from a specific namespace |
| `resource.List("apps/v1", "deployments", "").items.size() > 0` | Check if there are any Deployments across all namespaces |
| `resource.List("apps/v1", "deployments", object.metadata.namespace).items.exists(d, d.spec.replicas > 3)` | Ensure at least one Deployment in the same namespace has more than 3 replicas |
| `resource.List("v1", "services", "default").items.map(s, s.metadata.name).isSorted()` | Verify that Service names in the `default` namespace are sorted alphabetically |
| `resource.List("v1", "services", object.metadata.namespace).items.map(s, s.metadata.name).isSorted()` |  Use `object.metadata.namespace` to dynamically target the current resource's namespace |


In the sample policy below, `resource.Get()` retrieves a ConfigMap which is then used in the policy evaluation logic:  

``` yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: restrict-image-registries
spec:
  validationActions:
    - Deny
  evaluation:
    background:
      enabled: false
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  variables:
    - name: allContainers
      expression: >-
        object.spec.containers 
        + object.spec.?initContainers.orValue([]) 
        + object.spec.?ephemeralContainers.orValue([])
    - name: cm
      expression: >-
        resource.Get("v1", "configmaps", "kube-system", "allowed-registry")
    - name: allowedRegistry
      expression: "variables.cm.data[?'registry'].orValue('')"
  validations:
    - expression: "variables.allContainers.all(c, c.image.startsWith(variables.allowedRegistry))"
      messageExpression: '"image must be from registry: " + string(variables.allowedRegistry)'
```

### HTTP library

The **HTTP library** allows interaction with external HTTP/S endpoints using `http.Get()` and `http.Post()` within policies. These functions enable real-time validation against third-party systems, remote config APIs, or internal services, supporting secure communication via CA bundles for HTTPS endpoints.

| **CEL Expression**        | **Purpose**                          |
|-------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| `http.Get("https://internal.api/health").status == "ok"  `                                                                      | Validate external service health before proceeding                     |
| `http.Get("https://service/data").metadata.team == object.metadata.labels.team `                                                | Enforce label matching from remote service metadata                    |
| `http.Post("https://audit.api/log", {"kind": object.kind}, {"Content-Type": "application/json"}).logged == true`               | Confirm logging of the resource to an external system                  |
| `http.Get("https://certs.api/rootCA").cert == object.spec.cert`                                                                 | Validate a certificate field in the object against external data       |


The following policy fetches data from an external or internal HTTP(S) endpoint and makes it accessible within the policy:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: vpol-http-get
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: [v1]
        operations: [CREATE, UPDATE]
        resources: [pods]
  variables:
    - name: externalData
      expression: >-
        http.Get("http://test-api-service.default.svc.cluster.local:80")
  validations:
    - expression: >-
        variables.externalData.metadata.labels.app == object.metadata.labels.app
      messageExpression: "'only create pod with labels, variables.get.metadata.labels.app: ' + string(variables.get.metadata.labels.app)"

```

The following sample sends a `POST` request with a payload to an external service:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: vpol-http-post
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE"]
  variables:
    - name: response
      expression: >-
       http.Post(
        "http://test-api-service.default.svc.cluster.local/",
        {"labels": object.metadata.labels.app},{"Content-Type": "application/json"})
  validations:
    - expression: variables.response.received == "test"
      messageExpression: >-
       'External POST call did not return the expected response ' + string(variables.response.received)

```

When communicating over HTTPS, Kyverno uses the provided CA bundle to validate the server's certificate.


### User library

The **User library** includes functions like `user.ParseServiceAccount()` to extract metadata from the user or service account that triggered the admission request. These expressions help enforce policies based on user identity, namespace association, or naming conventions of service accounts.


| CEL Expression | Purpose |
|----------------|---------|
| `user.ParseServiceAccount(request.userInfo.username).Name == "my-sa"` | Validate that the request is made by a specific ServiceAccount |
| `user.ParseServiceAccount(request.userInfo.username).Namespace == "system"` | Ensure the ServiceAccount belongs to the `system` namespace |
| `user.ParseServiceAccount(request.userInfo.username).Name.startsWith("team-")` | Enforce naming convention for ServiceAccounts |
| `user.ParseServiceAccount(request.userInfo.username).Namespace in ["dev", "prod"]` | Restrict access to specific namespaces only |

The following policy requires that all service accounts be in the `system` namespace:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: parse-sa-test
spec: 
    validationActions:
      - Deny
    matchConstraints:
      resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE" ,"UPDATE"] 
    variables:
      - name: sa
        expression: >-
          user.ParseServiceAccount(request.userInfo.username)
    validations:
     - expression: >-
          variables.sa.Namespace == "system"
       message: >-
          ServiceAccount must in system namespace
```

### Image library

The **Image library** offers functions to parse and analyze image references. It allows policy authors to inspect registries, tags, and digests, ensuring image standards, such as requiring images from a specific registry or prohibiting tags, are enforced.

| CEL Expression | Purpose |
|----------------|---------|
| `image("nginx:latest").registry() == "docker.io"` | Validate image registry |
| `image("nginx:latest").repository() == "library/nginx"` | Validate repository path |
| `image("nginx:latest").identifier() == "latest"` | Check if the image identifier is a tag |
| `image("nginx:sha256:abcd...").containsDigest()` | Check if the image has a digest |
| `object.spec.containers.map(c, image(c.image)).map(i, i.registry()).all(r, r == "ghcr.io")` | Ensure all images are from `ghcr.io` registry |
| `object.spec.containers.map(c, image(c.image)).all(i, i.containsDigest())` | Ensure images use a digest |


The following sample ensures that all images use a digest:


```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-images
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: [v1]
        operations: [CREATE, UPDATE]
        resources: [pods]
  variables:
    - name: images
      expression: >-
        object.spec.containers.map(e, image(e.image))
        + object.spec.?initContainers.orValue([]).map(e, image(e.image))
        + object.spec.?ephemeralContainers.orValue([]).map(e, image(e.image))
  validations:
    - expression: >-
        variables.images.map(i, i.containsDigest()).all(e, e)
      message: >-
        images must be specified using a digest
```

### ImageData library

The **ImageData library** extends image inspection with OCI registry metadata like architecture, OS, digests, tags, and layers. Using `imagedata.Get()`, it fetches details about container images from OCI registries, enabling precise validation of image content and compatibility.

| CEL Expression | Purpose |
|----------------|---------|
| `imagedata.Get("nginx:1.21").config.architecture == "amd64"` | Ensure the image architecture is `amd64` |
| `imagedata.Get("nginx:1.21").config.os == "linux"` | Verify the image is built for Linux |
| `imagedata.Get("nginx:1.21").config.author == "docker"` | Check the image author |
| `imagedata.Get("nginx:1.21").config.variant == "v7"` | Validate architecture variant |
| `imagedata.Get("nginx:1.21").config.created != ""` | Ensure image has a creation timestamp |
| `imagedata.Get("nginx:1.21").config.docker_version.startsWith("20.")` | Check Docker version used to build the image |
| `imagedata.Get("nginx:1.21").config.container == "nginx"` | Validate container name |
| `imagedata.Get("nginx:1.21").config.os_features.exists(f, f == "sse4")` | Check if specific OS feature exists |
| `imagedata.Get("nginx:1.21").digest.startsWith("sha256:")` | Validate that image has a proper SHA256 digest |
| `imagedata.Get("nginx:1.21").layers.size() > 0` | Confirm the image has layers |
| `imagedata.Get("nginx:1.21").manifest.schemaVersion == 2` | Check if the image manifest uses schema version 2 |
| `imagedata.Get("nginx:1.21").manifest.mediaType == "application/vnd.docker.distribution.manifest.v2+json"` | Validate the media type of the image manifest |
| `imagedata.Get("nginx:1.21").manifest.layers.size() > 0` | Ensure the manifest lists image layers |
| `imagedata.Get("nginx:1.21").manifest.annotations.exists(a, a.key == "org.opencontainers.image.title")` | Check if a specific annotation is present |
| `imagedata.Get("nginx:1.21").manifest.subject != null` | Check if the image has a subject (e.g., SBOM reference) |
| `imagedata.Get("nginx:1.21").manifest.config.mediaType.contains("json")` | Validate that the config descriptor has a JSON media type |
| `imagedata.Get("nginx:1.21").manifest.layers.all(l, l.mediaType.startsWith("application/vnd.docker"))` | Ensure all layers have Docker-compatible media types |

The `imagedata.Get()` function extracts key metadata from OCI images, allowing validation based on various attributes.  

| **Field**       | **Description**                                    | **Example** |
|---------------|------------------------------------------------|-------------|
| `digest`      | The immutable SHA256 hash of the image.        | `sha256:abc123...` |
| `tag`         | The tag associated with the image version.     | `latest`, `v1.2.3` |
| `registry`    | The container registry hosting the image.      | `docker.io`, `gcr.io`, `myregistry.com` |
| `repository`  | The specific repository where the image is stored. | `library/nginx`, `myorg/myapp` |
| `architecture` | The CPU architecture the image is built for.  | `amd64`, `arm64` |
| `os`         | The operating system the image is compatible with. | `linux`, `windows` |
| `mediaType`   | The media type of the image manifest.          | `application/vnd.docker.distribution.manifest.v2+json` |
| `layers`      | A list of layer digests that make up the image. | `["sha256:layer1...", "sha256:layer2..."]` |

In addition to these fields, `imagedata.Get()` provides access to many other image metadata attributes, allowing validation based on specific security, compliance, or operational requirements.  


### GlobalContext library

The **GlobalContext library** introduces shared variables across policies through `globalcontext.Get()`. These variables are populated from external API calls via `GlobalContextEntry` resources, making it possible to validate requests against cluster-wide configurations or aggregated data with improved efficiency.

| **CEL Expression**                                                       | **Purpose**                                                         |
|--------------------------------------------------------------------------|----------------------------------------------------------------------|
| `globalcontext.Get("gctxentry-apicall-correct", "") != 0`                  | Ensure a specific deployment exists before allowing resource creation |
| `globalcontext.Get("team-cluster-values", "").someValue == "enabled"`     | Validate shared cluster-wide configuration using global context data |
| `globalcontext.Get("global-pod-labels", "").contains(object.metadata.labels)` | Check that pod labels match predefined global labels                |


To use this feature, first a `GlobalContextEntry` must be defined:

```yaml
apiVersion: kyverno.io/v2alpha1
kind: GlobalContextEntry
metadata:
  name: gctxentry-apicall-correct
spec:
  apiCall:
    urlPath: "/apis/apps/v1/namespaces/test-globalcontext-apicall-correct/deployments"
    refreshInterval: 1h
```

The following policy ensures that a specific deployment exists before allowing Pod creation.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: cpol-apicall-correct
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: []
        apiVersions: [v1]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  variables:
    - name: dcount
      expression: >-
        globalcontext.Get("gctxentry-apicall-correct", "")
  validations:
    - expression: >-
        variables.dcount != 0
      message: >-
        main-deployment should exist
```

By leveraging **Global Context**, Kyverno eliminates redundant queries and enables efficient, cross-policy data sharing, enhancing validation accuracy and performance.

