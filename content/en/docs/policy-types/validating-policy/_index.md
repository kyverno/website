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

<SAMPLE>

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: vpol-report-background-sample
spec:
  evaluation:
    admission:
      enabled: false
    background:
      enabled: true
    mode : Kubernetes
  validationActions:
  - Audit
  matchConstraints:
    resourceRules:
    - apiGroups:   [apps]
      apiVersions: [v1]
      operations:  [CREATE, UPDATE]
      resources:   [deployments] 
  variables:
    - name: environment
      expression: >-
        has(object.metadata.labels) && 'env' in object.metadata.labels && object.metadata.labels['env'] == 'prod'
  validations:
    - expression: >-
        variables.environment == true
      messageExpression: >-
        'Deployment labels must be env=prod' + (has(object.metadata.labels) && 'env' in object.metadata.labels ? ' but found env=' + string(object.metadata.labels['env']) : ' but no env label is present')
```

- **`mode`**  
  Specifies how the policy evaluates resources.  
  - `"Kubernetes"` (default): Evaluates standard Kubernetes resources.  
  - `"JSON"`: Evaluates arbitrary JSON input.

- **`admission.enabled`** (default: `true`)  
  Controls if rules are applied during the admission process (e.g., on create/update/delete).

- **`background.enabled`** (default: `true`)  
  Controls if rules are applied to existing resources during background scans.  
  Set to `false` if the rule uses variables only available during admission (e.g., user info).

### webhookConfiguration

The `spec.webhookConfiguration` field defines properties used to configure the Kyverno admission controller webhook.


```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-deployment-labels
spec:
  webhookConfiguration:
   timeoutSeconds: 15
  matchConstraints:
    resourceRules:
    - apiGroups:   [apps]
      apiVersions: [v1]
      operations:  [CREATE, UPDATE]
      resources:   [deployments]
  variables:
    - name: environment
      expression: >-
        has(object.metadata.labels) && 'env' in object.metadata.labels && object.metadata.labels['env'] == 'prod'
  validations:
    - expression: >-
        variables.environment == true
      message: >-
        Deployment labels must be env=prod

```

In the policy above, `webhookConfiguration.timeoutSeconds` is set to `15`, which defines how long the admission request waits for policy evaluation. The default is `10s`, and the allowed range is `1–30s`. After this timeout, the request may fail or ignore the result based on the failure policy. Kyverno reflects this setting in the generated `ValidatingWebhookConfiguration`.


### autogen

The `spec.autogen` field defines policy auto-generation behaviors for pod controllers and API server execution.

Here is an example of generating policies for deployments and cronjobs:

```yaml
 apiVersion: policies.kyverno.io/v1alpha1
 kind: ValidatingPolicy
 metadata:
   name: disallow-capabilities
 spec:
   autogen:
    validatingAdmissionPolicy:
     enabled: false
    podControllers:
      controllers:
       - deployments
       - cronjobs
   evaluation:
     background:
       enabled: true
   matchConstraints:
    resourceRules:
     - apiGroups:   [""]
       apiVersions: ["v1"]
       operations:  ["CREATE", "UPDATE"]
       resources:   ["pods"]
   variables:
     - name: allowedCapabilities
       expression: >-
         ['AUDIT_WRITE','CHOWN','DAC_OVERRIDE','FOWNER','FSETID','KILL','MKNOD','NET_BIND_SERVICE','SETFCAP','SETGID','SETPCAP','SETUID','SYS_CHROOT']
     - name: allContainers
       expression: >-
         (object.spec.containers + 
         object.spec.?initContainers.orValue([]) + 
         object.spec.?ephemeralContainers.orValue([]))
   validations:
     - expression: >-
         variables.allContainers.all(container, 
         container.?securityContext.?capabilities.?add.orValue([]).all(capability, capability == '' ||
         capability in variables.allowedCapabilities))
       message: >-
           Any capabilities added beyond the allowed list (AUDIT_WRITE, CHOWN, DAC_OVERRIDE, FOWNER,
```

 - `validatingAdmissionPolicy.enabled`: Disables ValidatingAdmissionPolicy generation when set to `false`. Default is `false`.
  - `podControllers.controllers`: Specifies pod-based controllers like `Deployments`, `CronJobs`, etc. Default is an empty list.

## Kyverno CEL Libraries

Kyverno’s `ValidatingPolicy` enhances Kubernetes' CEL environment with a powerful context library, enabling advanced policy enforcement. The following functions provide greater validation flexibility: 

### Resource library

The **Resource library** provides functions like `resource.Get()` and `resource.List()` to retrieve Kubernetes resources from the cluster, either individually or as a list. These are useful for writing policies that depend on the state of other resources, such as checking existing ConfigMaps, Services, or Deployments before validating a new object.


#### Examples: 

| CEL Expression | Purpose |
|----------------|---------|
| `resource.Get("v1", "configmaps", "default", "clusterregistries").data["registries"]` | Fetch a ConfigMap value from a specific namespace |
| `resource.List("apps/v1", "deployments", "").items.size() > 0` | Check if there are any Deployments across all namespaces |
| `resource.List("apps/v1", "deployments", object.metadata.namespace).items.exists(d, d.spec.replicas > 3)` | Ensure at least one Deployment in the same namespace has more than 3 replicas |
| `resource.List("v1", "services", "default").items.map(s, s.metadata.name).isSorted()` | Verify that Service names in the `default` namespace are sorted alphabetically |
| `resource.List("v1", "services", object.metadata.namespace).items.map(s, s.metadata.name).isSorted()` |  Use `object.metadata.namespace` to dynamically target the current resource's namespace |




- **`resource.Get()`**: Retrieves specific Kubernetes resources (e.g., ConfigMaps, Secrets, Pods) for validation.  

``` yaml
 apiVersion: policies.kyverno.io/v1alpha1
 kind: ValidatingPolicy
 metadata:
   name: advanced-restrict-image-registries
 spec:
   validationActions: 
     - Audit
   evaluation:
     background:
       enabled: false
   matchConstraints:
     resourceRules:
     - apiGroups:   [""]
       apiVersions: ["v1"]
       operations:  ["CREATE", "UPDATE"]
       resources:   ["pods"]
   variables:
             - name: cm
               expression: >-
                resource.Get("v1", "configmaps", "default", "clusterregistries")
             - name: allContainers
               expression: "object.spec.containers + object.spec.?initContainers.orValue([]) + object.spec.?ephemeralContainers.orValue([])"
             - name: nsregistries
               expression: >-
                 namespaceObject.metadata.?annotations[?'corp.com/allowed-registries'].orValue(' ')
             - name: registriesData
               expression: "variables.cm.data[?'registries'].orValue(' ')"
   validations:
             - expression: "variables.allContainers.all(container, container.image.startsWith(variables.nsregistries) || container.image.startsWith(variables.registriesData))"
               message: This Pod names an image that is not from an approved registry.

```
- **`resource.List()`**: Fetches a list of resources of a given type (e.g., all Deployments in a namespace or across the cluster).  
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

### User library

The **User library** includes functions like `user.ParseServiceAccount()` to extract metadata from the user or service account that triggered the admission request. These expressions help enforce policies based on user identity, namespace association, or naming conventions of service accounts.


#### Examples: 

| CEL Expression | Purpose |
|----------------|---------|
| `user.ParseServiceAccount(request.userInfo.username).Name == "my-sa"` | Validate that the request is made by a specific ServiceAccount |
| `user.ParseServiceAccount(request.userInfo.username).Namespace == "default"` | Ensure the ServiceAccount belongs to the `default` namespace |
| `user.ParseServiceAccount(request.userInfo.username).Name.startsWith("team-")` | Enforce naming convention for ServiceAccounts |
| `user.ParseServiceAccount(request.userInfo.username).Namespace in ["dev", "prod"]` | Restrict access to specific namespaces only |



- **`user.ParseServiceAccount()`**: Extracts details from a service account to enforce access control policies.  


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
          variables.sa.Name== "my-sa"
       message: >-
          ServiceAccount must be my-sa 
     - expression: >-
          variables.sa.Namespace == "default"
       message: >-
          ServiceAccount must in default namespace
      
```

### Image library

The **Image library** offers functions to parse and analyze image references directly from container specs. It allows policy authors to inspect registries, tags, and digests, ensuring image standards, such as requiring images from a specific registry or prohibiting digested images, are enforced.

#### Examples: 

| CEL Expression | Purpose |
|----------------|---------|
| `image("nginx:latest").registry() == "docker.io"` | Validate image registry |
| `image("nginx:latest").repository() == "library/nginx"` | Validate repository path |
| `image("nginx:latest").identifier() == "latest"` | Check if the image identifier is a tag |
| `image("nginx:sha256:abcd...").containsDigest()` | Check if the image has a digest |
| `object.spec.containers.map(c, image(c.image)).map(i, i.registry()).all(r, r == "ghcr.io")` | Ensure all images are from `ghcr.io` registry |
| `object.spec.containers.map(c, image(c.image)).all(i, !i.containsDigest())` | Ensure images are tagged, not digested |



- **`image`**: Used within policies to imageReference, enabling iteration over all images in a resource for validation and manipulation through function parsing function.  


```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-images
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: [apps]
        apiVersions: [v1]
        operations: [CREATE, UPDATE]
        resources: [deployments]
  variables:
    - name: images
      expression: >-
        object.spec.template.spec.containers.map(e, image(e.image))
  validations:
    - expression: >-
        variables.images.map(i, i.registry() == "ghcr.io" && !i.containsDigest()).all(e, e)
      message: >-
        Deployment must be have images from ghcr and images should be tagged
```

The image parsing function enables iteration over container images, allowing validation and extraction of image-related metadata dynamically.  

```cel
images.containers.map(image, expression).all(e, e > 0)
```
- **`images.containers`** → Retrieves all container images in the resource.  
- **`.map(image, expression)`** → Iterates over each image and applies the given expression.  
- **`.all(e, e > 0)`** → Ensures that all evaluated results meet the condition (`e > 0`), meaning the validation passes only if every image satisfies the requirement.  


- **`imagedata.Get()`**: Parses and validates OCI image metadata, including tags, digests, architecture, and more.  
```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: check-image-arch
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
      expression: imagedata.Get(variables.imageKey)
       
  validations:
    - expression: >-
         variables.image.config.architecture == "amd64"  
      message: >-
        image architecture is not supported
     
```

### ImageData library

The **ImageData library** extends image inspection with rich metadata like architecture, OS, digests, tags, and layers. Using `imagedata.Get()`, it fetches details about container images from OCI registries, enabling precise validation of image content and compatibility.


#### Examples: 


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


#### Examples: 


| **CEL Expression**                                                       | **Purpose**                                                         |
|--------------------------------------------------------------------------|----------------------------------------------------------------------|
| `globalcontext.Get("gctxentry-apicall-correct", "") != 0`                  | Ensure a specific deployment exists before allowing resource creation |
| `globalcontext.Get("team-cluster-values", "").someValue == "enabled"`     | Validate shared cluster-wide configuration using global context data |
| `globalcontext.Get("global-pod-labels", "").contains(object.metadata.labels)` | Check that pod labels match predefined global labels                |



- **`globalcontext.Get`** : it fetches deployment data and makes it accessible across all policies.

defining `GlobalContextEntry` 

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

### HTTP library

The **HTTP library** allows interaction with external services using `http.Get()` and `http.Post()` within policies. These functions enable real-time validation against third-party systems, remote config APIs, or internal services, supporting secure communication via CA bundles for HTTPS endpoints.

#### Examples: 


| **CEL Expression**                                                                                                            | **Purpose**                                                           |
|-------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| `http.Get("https://internal.api/health").status == "ok"  `                                                                      | Validate external service health before proceeding                     |
| `http.Get("https://service/data").metadata.team == object.metadata.labels.team `                                                | Enforce label matching from remote service metadata                    |
| `http.Post("https://audit.api/log", {"kind": object.kind}, {"Content-Type": "application/json"}).logged == true`               | Confirm logging of the resource to an external system                  |
| `http.Get("https://certs.api/rootCA").cert == object.spec.cert`                                                                 | Validate a certificate field in the object against external data       |


- **`http.Get`** :   Fetches data from an external or internal HTTP(S) endpoint and makes it accessible within the policy. Example:

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
    - name: get
      expression: >-
        http.Get("http://test-api-service.default.svc.cluster.local:80")
  validations:
    - expression: >-
        variables.get.metadata.labels.app == object.metadata.labels.app
      messageExpression: "'only create pod with labels, variables.get.metadata.labels.app: ' + string(variables.get.metadata.labels.app)"

```

- **`http.Post`** : Sends a POST request with a payload, often used to validate or log data externally.

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

When communicating over HTTPS, Kyverno uses the provided CA bundle to validate the server's certificate, ensuring the connection is secure and trusted. Therefore, it's recommended to use https whenever possible for secure communication.


