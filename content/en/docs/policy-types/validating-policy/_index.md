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
  generation: true
  environment:
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

## Extended CEL Library

## Automatic Bindings

## External Data

## Caching

## Reporting

## Auto-Generate Policies for Pod Controllers

## Background Scanning

## Pipeline Scanning

## Fine-Grained Exceptions

## Applying to JSON Payloads

## Auto-Generate ValidatingAdmissionPolicies



### Streamlined Policy Creation with Automatic Bindings

VAP requires manual creation and management of `ValidatingAdmissionPolicyBinding` objects to link policies to resources, adding complexity and potential for error. Kyverno’s `ValidatingPolicy` automates this process—bindings are managed by Kyverno upon policy creation, simplifying the workflow and reducing administrative overhead .

- **Use Case**: Define a single `ValidatingPolicy` to enforce rules across multiple namespaces without manually configuring bindings for each.
- **Impact**: `ValidatingPolicy` streamlines policy creation, unlike VAP’s labor-intensive binding management.

###  Efficient Policy Management with Autogen and Variables

`ValidatingPolicy` leverages Kyverno’s autogen feature to automatically generate rules for multiple resource types, controlled via annotations like `kyverno.io/autogen-controllers`. This eliminates repetitive policy writing. Additionally, variables allow reusable expressions within policies, improving readability, reducing duplication, and simplifying error checking.

- **Use Case**: Define a single policy to enforce resource limits across Pods, Deployments, and StatefulSets, with autogen handling the replication and variables standardizing the limit values.
- **Impact**: `ValidatingPolicy` enhances efficiency and clarity, unlike VAP’s static, repetitive rule definitions.

### Enhanced CEL with a Robust Context Library

Kubernetes’ `ValidatingAdmissionPolicy` (VAP) supports only basic CEL expressions that operate on admission request data, limiting its ability to fetch external data or execute complex logic. Kyverno’s `ValidatingPolicy` extends CEL with a powerful context library, enabling more advanced policy enforcement. The following functions enhance validation flexibility:

- **`resource.Get()`**: Fetches specific Kubernetes resources (e.g., ConfigMaps, Secrets) for validation.
- **`resource.List()`**: Retrieves a list of resources of a given type (e.g., all Deployments in a namespace).
- **`http.Get()` / `http.Post()`**: Makes real-time API calls to external services for validation.
- **`ParseServiceAccount()`**: Extracts details from a service account for access control policies.
- **`imagedata()`**: Validates OCI image metadata, such as tags or digests.

 
The example below enforces image registry restrictions by dynamically fetching allowed registries from a ConfigMap and namespace annotations.

```yaml
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
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
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
    - expression: >-
        variables.allContainers.all(container, container.image.startsWith(variables.nsregistries) || container.image.startsWith(variables.registriesData))
      message: This Pod names an image that is not from an approved registry.
```

###  Global Context for Cross-Policy Data Sharing

Kyverno introduces **GlobalContextEntry**, allowing policies to store and access shared data across multiple policies. This reduces redundant API calls and ensures consistent validation across different rules.

#### Defining a Global Context Entry
The following `GlobalContextEntry` fetches deployment data and makes it accessible across all policies.

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

#### Accessing Global Context in a Policy
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



### 6. Ongoing Compliance with Background Controller

VAP validates resources solely at admission time, offering no mechanism to detect post-creation changes. Kyverno’s `ValidatingPolicy` includes a background controller that continuously scans existing resources, generating `PolicyReport` objects to highlight deviations from enforced rules. This ensures ongoing compliance throughout a resource’s lifecycle.

- **Use Case**: Detect and report a Pod modified to use an unapproved image after initial creation, ensuring continuous security.
- **Impact**: `ValidatingPolicy` guarantees long-term compliance.

### 7. CI/CD Integration via CLI Support

VAP lacks a dedicated CLI, forcing administrators to test policies directly in the cluster, which complicates integration with CI/CD pipelines. `ValidatingPolicy` integrates with the Kyverno CLI, enabling pre-deployment validation using commands like `kyverno apply` and `kyverno test`.
CLI is similar as before just have to add `ValidatingPolicy: true` to enable it for `ValidatingPolicy`

- **Example**:
  ```sh
  kyverno apply policy.yaml --resource pod.yaml --keep-failed
  kyverno test .
- **Use Case**: Validate a set of manifests against policies in a CI pipeline, catching issues before cluster deployment.
- **Impact**: ValidatingPolicy boosts workflow efficiency and reliability.

### 8. Flexible Exceptions for Tailored Enforcement

VAP applies rules uniformly, with no exemption mechanism. ValidatingPolicy supports exceptions, allowing specific resources or conditions to bypass rules. This flexibility accommodates edge cases without compromising overall policy integrity.

- **Use Case**: Exempt a specific resource from a strict security policy with Exceptions.
- **Impact**: ValidatingPolicy balances enforcement with flexibility.

### 9. Broad Validation with JSON Payload Support

VAP limits validation to Kubernetes API objects, restricting its scope to standard resources. ValidatingPolicy extends this to raw JSON payloads, supporting custom or non-standard data alongside Kubernetes objects.

- **Use Case**: Validate a custom JSON configuration file used by an application.
- **Impact**: ValidatingPolicy broadens validation scope beyond VAP’s Kubernetes-only focus.

### 10. Advanced Reporting and Insights

Beyond basic denial messages, ValidatingPolicy integrates with Kyverno’s reporting framework, offering detailed admission-time and background scan reports via PolicyReport. This provides actionable insights into policy compliance across the cluster.

- **Use Case**: Generate a compliance dashboard showing all resources failing a specific policy, aiding audit preparation.
- **Impact**: ValidatingPolicy enhances visibility and governance.

### 11. Enhanced Security with Image Validation

Kyverno provides robust image validation through the `imagedata()` function and the `ImageValidatingPolicy`. Unlike VAP, which lacks native image validation, Kyverno allows in-depth analysis of image metadata, including architecture, signatures, tags, and digests, ensuring compliance with security policies.

#### Key Features:
- **Image Metadata Inspection**: Extract and validate image attributes such as architecture, OS, and digest.
- **Dedicated Image Validation Policy**: `ImageValidatingPolicy` strengthens supply chain security by enforcing strict validation rules and ensuring that images are properly signed.

#### Use Case:
- Enforce that all container images meet security standards.

#### Example: Validating Image Architecture
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
      apiVersions: ["v1"]
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
        Image architecture is not supported
```
### Image Utilities 

Kyverno enhances CEL’s capabilities with specialized functions for parsing and iterating over image references within Kubernetes resources. These utilities allow policies to dynamically inspect and validate image properties across all containers in a Pod.
- **Use Case**: Extract image references and metadata from resource specifications.
- **Impact**: Iterate through multiple container images in a single policy evaluation.




## Conclusion

Kyverno’s ValidatingPolicy transforms Kubernetes policy management by combining CEL’s simplicity with a powerful suite of features—webhook augmentation, VAP compatibility, automatic bindings, an extended CEL library, autogen, variables, background scanning, CLI support, exceptions, JSON payload validation, advanced reporting, Kubernetes interoperability, and enhanced image security. These capabilities make ValidatingPolicy a versatile, efficient, and future-proof tool for cluster administrators, far surpassing VAP’s basic functionality. 