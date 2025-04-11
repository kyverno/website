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

### webhookConfiguration

The `spec.webhookConfiguration` field defines properties used to configure the Kyverno admission controller webhook.

<SAMPLE>

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

## Kyverno CEL Libraries

Kyverno’s `ValidatingPolicy` enhances Kubernetes' CEL environment with a powerful context library, enabling advanced policy enforcement. The following functions provide greater validation flexibility: 

### Resource library

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

