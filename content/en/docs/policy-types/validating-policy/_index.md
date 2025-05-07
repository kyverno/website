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

The `spec.autogen` field defines policy auto-generation behaviors, to automatically generate policies for pod controllers and generate `ValidatingAdmissionPolicy` types for Kubernetes API server execution.

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
| `resource.Post("authorization.k8s.io/v1", "subjectaccessreviews", {…})` | Perform a live SubjectAccessReview (authz check) against the Kubernetes API |
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

This sample policy demonstrates how to use `resource.Post()` to perform a live access check using Kubernetes’ `SubjectAccessReview` API:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-subjectaccessreview
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
    - apiGroups:   ['']
      apiVersions: [v1]
      operations:  [CREATE, UPDATE]
      resources:   [configmaps]
  variables:
    - name: res
      expression: >-
        {
          "kind": dyn("SubjectAccessReview"),
          "apiVersion": dyn("authorization.k8s.io/v1"),
          "spec": dyn({
            "resourceAttributes": dyn({
              "resource": "namespaces",
              "namespace": string(object.metadata.namespace),
              "verb": "delete",
              "group": ""
            }),
            "user": dyn(request.userInfo.username)
          })
        }
    - name: subjectaccessreview
      expression: >-
        resource.Post("authorization.k8s.io/v1", "subjectaccessreviews", variables.res)
  validations:
    - expression: >-
        has(variables.subjectaccessreview.status) && variables.subjectaccessreview.status.allowed == true
      message: >-
        User is not authorized.
  
```

This sample policy uses `resource.List()` to retrieve all existing Ingress resources and ensures that the current Ingress does not introduce duplicate HTTP paths across the cluster:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: unique-ingress-path
spec:
  validationActions: [Deny]
  evaluation:
   background: 
    enabled: false
  matchConstraints:
    resourceRules:
      - apiGroups: ["networking.k8s.io"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["ingresses"]
  variables:
        - name: allpaths
          expression: >-
            resource.List("networking.k8s.io/v1", "ingresses", "" ).items
        - name: nspath
          expression: >-
            resource.List("networking.k8s.io/v1", "ingresses", object.metadata.namespace ).items    
  validations:
    - expression: >-
            !object.spec.rules.orValue([]).exists(rule, 
                rule.http.paths.orValue([]).exists(path, 
                  (
                    variables.allpaths.orValue([]).exists(existing_ingress, 
                      existing_ingress.spec.rules.orValue([]).exists(existing_rule, 
                        existing_rule.http.paths.orValue([]).exists(existing_path, 
                          existing_path.path == path.path 
                        )
                      )
                    )
                    &&
                   ! variables.nspath.orValue([]).exists(existing_ingress, 
                            existing_ingress.metadata.namespace != object.metadata.namespace &&

                      existing_ingress.spec.rules.orValue([]).exists(existing_rule, 
                        existing_rule.http.paths.orValue([]).exists(existing_path, 
                       existing_path.path == path.path
                        )
                      )
                    )
                  )
                )
              )

      message: >-
        The root path already exists in the cluster but not in the namespace.

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

The **User library** includes functions like `parseServiceAccount()` to extract metadata from the user or service account that triggered the admission request. These expressions help enforce policies based on user identity, namespace association, or naming conventions of service accounts.


| CEL Expression | Purpose |
|----------------|---------|
| `parseServiceAccount(request.userInfo.username).Name == "my-sa"` | Validate that the request is made by a specific ServiceAccount |
| `parseServiceAccount(request.userInfo.username).Namespace == "system"` | Ensure the ServiceAccount belongs to the `system` namespace |
| `parseServiceAccount(request.userInfo.username).Name.startsWith("team-")` | Enforce naming convention for ServiceAccounts |
| `parseServiceAccount(request.userInfo.username).Namespace in ["dev", "prod"]` | Restrict access to specific namespaces only |

This sample policy ensures that only service accounts in the `kube-system` namespace with names like `replicaset-controller`, `deployment-controller`, or `daemonset-controller` are allowed to create pods:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: restrict-pod-creation
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
    - name: sa
      expression: parseServiceAccount(request.userInfo.username)
  validations:
    - expression: variables.sa.Namespace == "kube-system"
      message: Only kube-system service accounts can create pods
    - expression: variables.sa.Name in ["replicaset-controller", "deployment-controller", "daemonset-controller"]
      message: Only trusted system controllers can create pods

```

### Image library

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

The `image.GetMetadata()` function extracts key metadata from OCI images, allowing validation based on various attributes.  

This sample policy ensures pod images have metadata, are amd64, and use manifest schema version 2:

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-image-details
spec:
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
      - apiGroups:   [""]
        apiVersions: [v1]
        operations:  [CREATE, UPDATE]
        resources:   [pods]
  variables:
    - name: imageRef
      expression: object.spec.containers[0].image
    - name: imageKey
      expression: variables.imageRef
    - name: image
      expression: image.GetMetadata(variables.imageKey)

  validations:
    - expression: variables.image != null
      message: >-
       Failed to retrieve image metadata

    - expression: variables.image.config.architecture == "amd64"
      messageExpression: >-
        string(variables.image.config.architecture) + ' image architecture is not supported'

    - expression: variables.image.manifest.schemaVersion == 2
      message: >-
       Only schemaVersion 2 image manifests are supported


```


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

In addition to these fields, `image.GetMetadata()` provides access to many other image metadata attributes, allowing validation based on specific security, compliance, or operational requirements.  


### GlobalContext library

The **GlobalContext library** introduces shared variables across policies through `globalContext.Get()`. These variables are populated from external API calls via `GlobalContextEntry` resources, making it possible to validate requests against cluster-wide configurations or aggregated data with improved efficiency.

| **CEL Expression**                                                       | **Purpose**                                                         |
|--------------------------------------------------------------------------|----------------------------------------------------------------------|
| `globalContext.Get("gctxentry-apicall-correct", "") != 0`                  | Ensure a specific deployment exists before allowing resource creation |
| `globalContext.Get("team-cluster-values", "").someValue == "enabled"`     | Validate shared cluster-wide configuration using global context data |
| `globalContext.Get("global-pod-labels", "").contains(object.metadata.labels)` | Check that pod labels match predefined global labels                |


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
      - apiGroups: [""]
        apiVersions: [v1]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  variables:
    - name: dcount
      expression: >-
        globalContext.Get("gctxentry-apicall-correct", "")
  validations:
    - expression: >-
        variables.dcount != 0
      message: >-
        main-deployment should exist
```

By leveraging **Global Context**, Kyverno eliminates redundant queries and enables efficient, cross-policy data sharing, enhancing validation accuracy and performance.


Policies are applied cluster-wide to help secure your cluster. However, there may be times when teams or users need to test specific tools or resources. In such cases, users can use [PolicyException](../../exceptions/_index.md#policyexceptions-with-cel-expressions) to bypass policies without modifying or tweaking the policies themselves. This ensures that your policies remain secure while providing the flexibility to bypass them when needed.
