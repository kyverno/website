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

The `ValidatingPolicy` extends the [Kubernetes ValidatingAdmissionPolicy](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) with the following additional fields for Kyverno features. A complete reference is provided in the [API specification](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/release-1.14/docs/user/crd/index.html#policies.kyverno.io/v1alpha1.ValidatingPolicy).

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

Kyverno enhances Kubernetes' CEL environment with libraries enabling complex policy logic and advanced features. For comprehensive documentation of all available CEL libraries, see the [CEL Libraries documentation](/docs/policy-types/cel-libraries/).

### Resource library

### Resource Library Examples

In the sample policy below, `resource.Get()` retrieves a ConfigMap which is then used in the policy evaluation logic:  

```yaml
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

This sample policy demonstrates how to use `resource.Post()` to perform a live access check using Kubernetes' `SubjectAccessReview` API:

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

### HTTP Library Examples

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

### User Library Examples

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

### Image Library Examples

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
        object.spec.containers.map(e, parseImageReference(e.image))
        + object.spec.?initContainers.orValue([]).map(e, parseImageReference(e.image))
        + object.spec.?ephemeralContainers.orValue([]).map(e, parseImageReference(e.image))
  validations:
    - expression: >-
        variables.images.map(i, i.containsDigest()).all(e, e)
      message: >-
        images must be specified using a digest
```

### ImageData Library Examples

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

### GlobalContext Library Examples

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
