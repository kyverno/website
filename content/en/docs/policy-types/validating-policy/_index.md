---
title: ValidatingPolicy
description: >-
    Validate Kubernetes resource or JSON payloads.
weight: 30
---

Kyverno’s `ValidatingPolicy` extends the Kubernetes `ValidatingAdmissionPolicy` type for complex policy evaluations and other critical features for managing the full Policy as Code lifecycle.

A ValidatingPolicy has a similar structure to the `ValidatingAdmissionPolicy`, with a few additional fields.

 ```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: block-ephemeral-containers
spec:
  validationActions: 
    - Audit
    - Warn
  evaluation:
    admission:
      enabled: true
    background:
      enabled: true
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources: ["pods", "pods/ephemeralcontainers"] 
  validations:
   - expression: >-
      object.spec.?ephemeralContainers.orValue([]).size() == 0
     message: "Ephemeral (debug) containers are not permitted."
 ```

## Comparison with Validating Admission Policy

The table below compares major features with the  `ValidatingAdmissionPolicy`.

| Feature            | ValidatingAdmissionPolicy    | ValidatingPolicy                     |
|--------------------|------------------------------|--------------------------------------|
| Enforcement        | Admission                    | Admission, Background, Pipelines            |
| CEL Functions      | Basic                        | Extended                                    |
| Bindings           | Manual                       | Automatic                                   |
| External Data      | _                            | Kubernetes resources or API calls           |
| Caching            | _                            | Global Context                              |
| Reporting          | _                            | Policy reports                              |
| Auto-generation    | -                            | Pod Controllers, ValidatingAdmissionPolicy  |
| Background scans   | -                            | Periodic, On policy change                  |
| Pipeline scans     | -                            | CLI                                         |
| Exceptions         | -                            | Fine-grained exceptions                     |
| JSON payloads      | -                            | Any payload                                 |


## Additional Fields

The `ValidatingPolicy` includes several additional fields that enhance configuration flexibility and improve policy readability.  

- **evaluation**: Controls whether the policy is enforced during admission, background processing, or both by enabling or disabling the respective controllers.  
- **webhookConfiguration**: Defines `timeoutSeconds`, ensuring policies are evaluated within a specified timeframe to prevent enforcement failures due to webhook delays.  
- **generation**: Automatically generates policies for pod controllers, allowing users to define policies at the pod level while seamlessly applying them to controllers like Deployments, StatefulSets, DaemonSets, and CronJobs. Kyverno also simplifies policy enforcement by automatically generating `ValidatingAdmissionPolicy` and `ValidatingAdmissionPolicyBinding` from a `ValidatingPolicy`, reducing manual effort in managing admission controls.

look at the example below:

```yaml
 apiVersion: policies.kyverno.io/v1alpha1
 kind: ValidatingPolicy
 metadata:
   name: disallow-capabilities
 spec:
   generation:
    podControllers:
      enabled: true
      controllers:
       - deployments
       - cronjobs
   validationActions:
      - Audit
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

## Extended CEL Library  

Kyverno’s `ValidatingPolicy` enhances CEL with a powerful context library, enabling advanced policy enforcement. The following functions provide greater validation flexibility:  

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

- **`ParseServiceAccount()`**: Extracts details from a service account to enforce access control policies.  
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

### Expression  
```cel
images.containers.map(image, expression).all(e, e > 0)
```
- **`images.containers`** → Retrieves all container images in the resource.  
- **`.map(image, expression)`** → Iterates over each image and applies the given expression.  
- **`.all(e, e > 0)`** → Ensures that all evaluated results meet the condition (`e > 0`), meaning the validation passes only if every image satisfies the requirement.  


- **`imagedata()`**: Parses and validates OCI image metadata, including tags, digests, architecture, and more.  
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

The `imagedata()` function extracts key metadata from OCI images, allowing validation based on various attributes.  

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

In addition to these fields, `imagedata()` provides access to many other image metadata attributes, allowing validation based on specific security, compliance, or operational requirements.  


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


## Automatic Bindings

When using `ValidatingPolicy`, you don't need to explicitly handle policy bindings. The policy automatically applies to matching resources without requiring separate policy binding configurations. This simplifies enforcement and ensures that validation is consistently applied across resources.


## External Data

These functions are used in CEL to enable dynamic validation. The `http.Get()` and `http.Post()` functions allow real-time API calls to external services, ensuring policies can validate data dynamically. Additionally, the `globalContext.Get()` function fetches data both from within and outside the cluster through API calls and make it accessible to all the policies in cluster to reduce api call. This enhances Kyverno’s ability to interact with internal and external services, though it requires additional permissions for the Kyverno controller. These API calls are secured using certificates to ensure safe communication.

**Note:** Fetching these resources requires additional permissions for the Kyverno controller. These API calls are secured using certificates to ensure safe and authenticated communication.  

## Caching

In Kyverno's `ValidatingPolicy`, **caching is done internally and is automatically enabled** to enhance performance and reduce the load on the Kubernetes API server.  

### How Caching Works  

Kyverno stores frequently accessed data, such as **ConfigMaps, Secrets, and image metadata**, to **minimize repetitive API calls** during policy evaluations. This ensures that policies are enforced efficiently without unnecessary overhead on the cluster.  

### Benefits of Caching  

- **Improved Performance**: Reduces the time required for policy evaluations by avoiding redundant API queries.  
- **Lower API Server Load**: Minimizes excessive calls to the Kubernetes API, improving overall system stability.  
- **Efficient Policy Enforcement**: Ensures faster validation while maintaining accuracy in decision-making.  

Caching operates transparently in the background, requiring no manual configuration, making policy execution **faster, scalable, and more reliable** within Kyverno.  



## Reporting

In Kyverno's `ValidatingPolicy`, **policy reports** provide visibility into policy violations and compliance status. These reports are generated in **audit mode** and during **background scans**, helping administrators detect misconfigurations and enforce best practices across the cluster.  

### Importance of Policy Reports  

- **Compliance Monitoring**: Policy reports help track adherence to security and governance policies, ensuring compliance with organizational and regulatory standards.  
- **Issue Detection**: By highlighting misconfigurations and violations, policy reports allow administrators to proactively address security risks and operational issues.  
- **Historical Insights**: These reports maintain a record of policy evaluations over time, helping teams analyze trends and improve policy effectiveness.  
- **Cluster-Wide Visibility**: Policy reports provide a centralized view of policy enforcement across namespaces, making it easier to manage security at scale.  

### How Policy Reports Work  

1. **Audit Mode**: When a policy is set to `audit`, violations are recorded in policy reports without blocking resource creation, allowing teams to identify and address issues without disruption.  
2. **Background Scans**: Kyverno periodically scans existing resources in the cluster, generating reports on compliance and flagging misconfigurations.  

### Best Practice: Use `messageExpression` Instead of `message`  

To improve policy reporting, use **`messageExpression`** instead of just `message`. This allows for dynamic failure messages, helping you understand the reason behind policy violations more effectively.  

Example of a Policy Report:  

```yaml
apiVersion: v1
items:
- apiVersion: wgpolicyk8s.io/v1alpha2
  kind: PolicyReport
  metadata:
    generation: 1
    labels:
      app.kubernetes.io/managed-by: kyverno
    ownerReferences:
    - apiVersion: apps/v1
      kind: Deployment
      name: no-env
  results:
  - category: Other
    message: Deployment labels must be env=prod but no env label is present
    policy: check-deployment-labels
    result: fail
    scored: true
    severity: medium
    source: KyvernoValidatingPolicy
  scope:
    apiVersion: apps/v1
    kind: Deployment
    name: no-env
  summary:
    error: 0
    fail: 1
    pass: 0
    skip: 0
    warn: 0
```

## Auto-Generate Policies for Pod Controllers

Kyverno’s `ValidatingPolicy` supports **automatic policy generation** for pod controllers using the `generation` field. This feature simplifies policy management by allowing policies written for **Pods** to be automatically applied to higher-level controllers like **Deployments** and **CronJobs**.  

### How Auto-Generation Works  

When `generation.podControllers.enabled` is set to `true`, Kyverno automatically creates corresponding policies for the specified pod controllers, ensuring consistency in enforcement across different workload types.  

Example configuration:  

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: disallow-privilege-escalation
spec:
  generation:
    podControllers:
      enabled: true
      controllers:
      - deployments
      - cronjobs
  matchConstraints:
    resourceRules:
    - apiGroups:   [""]
      apiVersions: [v1]
      operations:  [CREATE, UPDATE]
      resources:   ["pods"]
  matchConditions:
    - name: "check-prod-label"  
      expression: >- 
        has(object.metadata.labels) && has(object.metadata.labels.prod) && object.metadata.labels.prod == 'true'
  validations:
    - expression: >- 
        object.spec.containers.all(container, has(container.securityContext) &&
        has(container.securityContext.allowPrivilegeEscalation) &&
        container.securityContext.allowPrivilegeEscalation == false)
      message: >-
        Privilege escalation is disallowed. The field
        spec.containers[*].securityContext.allowPrivilegeEscalation must be set to `false`.
```
these lead to generation of cooresponding resource

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
    name: disallow-privilege-escalation
status:
    autogen:
      rules:
      - matchConditions:
        - expression: '!(object.kind ==''Deployment'' || object.kind ==''ReplicaSet''
            || object.kind ==''StatefulSet'' || object.kind ==''DaemonSet'') || has(object.spec.template.metadata.labels)
            && has(object.spec.template.metadata.labels.prod) && object.spec.template.metadata.labels.prod
            == ''true'''
          name: autogen-check-prod-label
        matchConstraints:
          resourceRules:
          - apiGroups:
            - apps
            apiVersions:
            - v1
            operations:
            - CREATE
            - UPDATE
            resources:
            - deployments
        validations:
        - expression: object.spec.template.spec.containers.all(container, has(container.securityContext) &&
             has(container.securityContext.allowPrivilegeEscalation) && container.securityContext.allowPrivilegeEscalation
            == false)
          message: Privilege escalation is disallowed. The field spec.containers[*].securityContext.allowPrivilegeEscalation
            must be set to `false`.
      - matchConditions:
        - expression: '!(object.kind ==''CronJob'') || has(object.spec.jobTemplate.spec.template.metadata.labels)
            && has(object.spec.jobTemplate.spec.template.metadata.labels.prod) &&
            object.spec.jobTemplate.spec.template.metadata.labels.prod == ''true'''
          name: autogen-cronjobs-check-prod-label
        matchConstraints:
          resourceRules:
          - apiGroups:
            - batch
            apiVersions:
            - v1
            operations:
            - CREATE
            - UPDATE
            resources:
            - cronjobs
        validations:
        - expression: object.spec.jobTemplate.spec.template.spec.containers.all(container,
            has(container.securityContext) && has(container.securityContext.allowPrivilegeEscalation) &&
             container.securityContext.allowPrivilegeEscalation == false)
          message: Privilege escalation is disallowed. The field spec.containers[*].securityContext.allowPrivilegeEscalation
            must be set to `false`.
```

## Background Scanning

Kyverno's `ValidatingPolicy` supports **background scanning**, which ensures that policies remain effective even after the initial admission review. While policies are typically evaluated when a resource is created or modified, background scanning helps maintain compliance over time by continuously checking resources against active policies.  

### How Background Scanning Works  

When background scanning is enabled, Kyverno periodically evaluates existing resources against policy rules. This means that even if a resource was initially allowed during admission, it will still be monitored to detect any violations that may arise later due to changes in the policy or the resource’s environment.  

If a resource fails a background scan, Kyverno automatically generates a **policy report**, highlighting the violation. This allows administrators to take corrective actions, ensuring that misconfigurations, security risks, and compliance issues are addressed proactively.  

### Default Behavior and Configuration  

By default, **background scanning is enabled (`true`)** for all policies. However, it can be explicitly configured within a policy definition:  

```yaml
spec:
  evaluation:
    background: 
     enabled: true
```

## Pipeline Scanning

Pipeline scanning is a crucial step in CI/CD workflows, ensuring that policies are properly validated before deployment. When automating policy enforcement in Kubernetes, it is essential to verify that policies function correctly and enforce the intended behavior before they are applied to the cluster. This prevents misconfigurations, unintended policy behavior, and security risks.  

### Why Pipeline Scanning Matters  

Integrating policy validation into CI/CD pipelines allows teams to:  
- **Prevent Misconfigurations**: Ensure policies behave as expected before deployment.  
- **Enhance Security**: Avoid unintended policy bypasses or gaps that could weaken security.  
- **Automate Policy Enforcement**: Verify policies automatically within the pipeline, reducing manual effort.  

### How to Perform Policy Scanning  

Kyverno provides CLI tools to test policies against resources before deployment:  
- **`kyverno test`**: Runs predefined policy test cases to validate policy logic.  
- **`kyverno apply`**: Tests policies against live or locally defined resources to confirm expected behavior.  

These commands help developers catch issues early, ensuring that policies function correctly before reaching the cluster.  

### Enabling ValidatingPolicy Checks  

Previously, policy tests were written for standard policies, but now Kyverno introduces the `isValidatingPolicy` field. This allows explicit validation of **ValidatingPolicy** within test cases, ensuring they are properly checked before deployment. Additionally, Kyverno CLI now supports **ValidatingAdmissionPolicy**, enabling broader validation across policy types.  

```yaml
 apiVersion: cli.kyverno.io/v1alpha1
 kind: Test
 metadata:
   name: allowed-annotations
 policies:
 - ../allowed-annotations.yaml
 resources:
 - resource.yaml
 results:
 - isValidatingPolicy: true
   kind: Pod
   policy: allowed-annotations
   resources:
   - badpod01
   result: fail
 - isValidatingPolicy: true
   kind: Pod
   policy: allowed-annotations
   resources:
   - goodpod01
   result: pass

```
By incorporating **pipeline scanning** into CI/CD workflows, teams can automate policy validation, maintain compliance, and enhance Kubernetes security before policies are enforced in production.  



## Fine-Grained Exceptions in ValidatingPolicy  

Kyverno’s exception mechanism goes beyond simply excluding entire resources or kinds. It allows for **fine-grained control**, enabling policies to dynamically evaluate specific fields within a resource instead of completely bypassing validation. This provides greater flexibility while maintaining security and compliance.  

### How Fine-Grained Exceptions Work  

Instead of excluding entire resource types, exceptions can be applied based on **specific field values** or **dynamic conditions**. This ensures that only relevant parts of a resource are exempted while the policy remains enforced on everything else.  

### Why Fine-Grained Exceptions Matter  

- **More Precise Control**: Exceptions can be applied at a granular level, targeting specific attributes instead of skipping entire resources.  
- **Stronger Admission Enforcement**: Policies remain effective without broad exclusions, ensuring security is maintained.  
- **Flexible Policy Design**: Allows selective validation, making policies more adaptable to complex requirements.  

Fine-grained exceptions are especially useful in **admission control scenarios**, where policies need to allow selective bypassing without altering or disabling the entire enforcement mechanism.  

### Defining a `PolicyException`  

To implement fine-grained exceptions, Kyverno provides the `PolicyException` resource. The `policyRefs` field links the exception to the relevant **ValidatingPolicy**, while `matchConditions` define dynamic criteria for exemption.  

#### Example: Creating a `PolicyException`  

The following example defines a `PolicyException` that skips validation for a specific pod named `skipped-pod` when applying an **ImageValidatingPolicy**:  

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: PolicyException
metadata:
  name: check-name
spec:
  policyRefs:
    - name: ivpol-sample
      kind: ValidatingPolicy
  matchConditions:
    - name: "check-name"
      expression: "object.metadata.name == 'skipped-pod'"
```


## Applying Policies to JSON Payloads  

Kyverno's `ValidatingPolicy` supports **evaluating policies on JSON data**, allowing validation beyond Kubernetes-native resources. This feature enables users to enforce policies on structured JSON payloads, making it useful in various scenarios such as CI/CD pipelines, API validation, and compliance checks.  

### How JSON Payload Evaluation Works  

Kyverno can process and validate arbitrary JSON payloads using the same policy framework applied to Kubernetes resources. Instead of requiring a Kubernetes resource, policies can evaluate raw JSON data directly, ensuring compliance before resources are created or modified.  

### Key Use Cases  

- **Pre-deployment Validation**: Ensures policies function correctly before being applied to live workloads.  
- **Admission Webhooks**: Allows Kyverno to dynamically enforce policies on incoming API requests containing JSON data.  
- **External Data Sources**: Uses functions like `globalContext.Get()` to fetch and validate JSON-structured data from external APIs.  

### Example JSON Payload  

Below is an example JSON payload that can be validated using a `ValidatingPolicy`:  

```json
{
  "metadata": {
    "name": "example-resource",
    "labels": {
      "environment": "production"
    }
  },
  "spec": {
    "replicas": 3,
    "image": "example-registry.com/app:v1.0",
    "securityContext": {
      "runAsNonRoot": true
    }
  }
}
```

## Auto-Generating ValidatingAdmissionPolicy  

Kyverno’s `ValidatingPolicy` supports **automatic generation** of `ValidatingAdmissionPolicy` and `ValidatingAdmissionPolicyBinding`, extending beyond just `podControllers`. This feature streamlines the process of defining **admission validation policies** by eliminating the need to manually write bindings, making policy management more efficient.  

### How Auto-Generation Works  

When enabled, **Kyverno automatically converts a `ValidatingPolicy` into a `ValidatingAdmissionPolicy` along with its corresponding `ValidatingAdmissionPolicyBinding`**. This ensures that the validation logic defined in a single policy is seamlessly transformed into the Kubernetes-native admission policy format.  

### Why Auto-Generation is Useful  

- **Reduces Manual Effort**: Eliminates the need to manually define bindings, saving time and reducing complexity.  
- **Ensures Consistency**: Guarantees that `ValidatingAdmissionPolicy` and its bindings match the original `ValidatingPolicy`.  
- **Simplifies Policy Management**: Makes it easier to adopt Kubernetes-native admission control mechanisms without additional configuration overhead.  

### Enabling Auto-Generation  

To enable automatic generation of `ValidatingAdmissionPolicy`, simply set the `generation.validatingAdmissionPolicy.enabled` field to `true` within the `ValidatingPolicy` spec:  

```yaml
spec:
  generation:
    validatingAdmissionPolicy:
      enabled: true
```

With this configuration, Kyverno will automatically generate and apply the required admission policy and binding, ensuring smooth enforcement of validation rules without additional manual work. This feature is especially useful for users transitioning to Kubernetes-native admission policies while leveraging the flexibility of Kyverno.

