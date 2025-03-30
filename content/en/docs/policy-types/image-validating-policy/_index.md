---
title: ImageValidatingPolicy
description: >-
    Validate Image Signatures and Attestations
weight: 40
---

Kyverno’s `ImageValidatingPolicy` follows a structure similar to `ValidatingAdmissionPolicy` while supporting advanced policy evaluations and providing essential features for managing the full Policy-as-Code lifecycle.  

For image verification, `ImageValidatingPolicy` integrates with **Cosign** and **Notary**, enabling signature and attestation checks to ensure the integrity and authenticity of container images before deployment. This ensures that only trusted and verified images are used in the cluster, reducing the risk of supply chain attacks.


While `ImageValidatingPolicy` shares a similar structure with `ValidatingAdmissionPolicy`, it includes additional fields tailored for image verification, attestation checks, and registry authentication, enabling more comprehensive enforcement of container security policies.


 ```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: verify-image-ivpol
spec:
  webhookConfiguration:
    timeoutSeconds: 30
  evaluation:
   background:
    enabled: false
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  imageRules:
        - glob : "docker.io/mohdcode/kyverno*"
  mutateDigest: true
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
       images.containers.map(image, verifyImageSignatures(image, [attestors.cosign])).all(e ,e > 0)
      message: >-
       failed the image Signature verification

 ```

## Additional Fields
The `ImageValidatingPolicy` includes several additional fields that enhance configuration flexibility and improve policy readability.  

- **attestations**: Provides a list of image metadata to verify, ensuring compliance with security requirements.  
  - Defines the identification details of the metadata that must be verified.  

  **FIELDS:**  
  - **intoto**: Specifies the attestation details using the in-toto format.  
  - **name**: A unique identifier for the attestation, used in verification.  
  - **referrer**: Defines the attestation details using the OCI 1.1 format.  

- **attestors**: Defines trusted authorities responsible for verifying image integrity.  
  - This field supports two types: **cosign** and **notary**.  
 
- **credentials**: Specifies authentication details for interacting with container registries.  

  - **Credentials** provides authentication details that will be used for registry access.  

    **FIELDS:**  
    - `allowInsecureRegistry` `<boolean>`: Allows insecure access to a registry.  
    - `providers`: Specifies a list of OCI Registry names whose authentication providers are used.  
      - Possible values: `default`, `google`, `azure`, `amazon`, `github`.  
    - `secrets`: Specifies a list of secrets for authentication.  
      - Secrets must exist in the **Kyverno namespace**. 

- **imageRules**: Defines glob patterns and CEL expressions to match images for validation. Only matched images undergo verification.  
  - **ImagesRules** is a list of **Glob** and **CELExpressions** to match images.  
    - Any image that matches one of the rules is considered for validation.  
    - Any image that does not match a rule is skipped, even when passed as arguments to image verification functions.  
    - **ImageRule** defines a **Glob** or a **CEL expression** for matching images.  

- **images**: Uses CEL expressions to extract images from a resource for validation.  
- **mutateDigest**: Enables automatic replacement of image tags with digests, ensuring immutable and verifiable image references. Defaults to `true`.  
- **required**: Ensures that images must pass signature or attestation checks to be considered valid.  
- **verifyDigest**: Ensures that images include a digest for verification, preventing the use of mutable tags.  
- **webhookConfiguration**: Configures webhook parameters, including `timeoutSeconds`, ensuring policy evaluations complete within a specified timeframe.  

### keyless

Keyless signing in Cosign allows signature verification without requiring a predefined key, relying instead on OIDC identity-based authentication.

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: require-vulnerability-scan
spec:
  validationActions: [Audit]
  webhookConfiguration:
    timeoutSeconds: 20
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
        operations: ["CREATE", "UPDATE"]
  imageRules:
    - glob: "ghcr.io/myorg/myrepo:*"
  attestors:
    - name: cosign
      cosign:
          keyless:
            identities:
              - subject: "https://github.com/myorg/myrepo/.github/workflows/*"
                issuer: "https://token.actions.githubusercontent.com"
          ctlog:
               url: "https://rekor.sigstore.dev"
  attestations:
   - name: cosign-attes
     intoto:
       type: cosign.sigstore.dev/attestation/vuln/v1
  validations:
    - expression: >-
        images.containers.map(image, verifyImageSignatures(image,  [attestors.cosign])).all(e, e > 0)
      message: "Images must be from ghcr.io/myorg/myrepo"
    - expression: >-
        images.containers.map(image, verifyAttestationSignatures(image, [attestations.cosign-attes], [attestors.cosign])).all(e, e > 0)
      message: "Failed to verify vulnerability scan attestation with Cosign keyless"
```

## Extended CEL Library  
 We have already discussed the extended CEL library in **ValidatingPolicy**. You can check it [here](../validating-policy/_index.md#extended-cel-library). `ImageValidatingPolicy` supports those functions along with additional functions specifically for image verification.


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

The CEL functions to verify image signatures, attestations, and payload formats to ensure image integrity and compliance.

- **Purpose:** Validates the signature of an image against the provided attestors.  
- **Expression:**  
  ```cel
  verifyImageSignatures(image, [attestors.notary])
  ```
- **Purpose:** Verifies the attestation signature of an image using a given attestation type and attestors.
- **Expression:**  
  ```cel
   verifyAttestationSignatures(image, attestations.sbom ,[attestors.notary])
  ```
- **Purpose:** Extracts the Software Bill of Materials (SBOM) format from an image’s attestation payload.
- **Expression:** 
 ```cel
 payload(image, attestations.sbom).bomFormat == 'CycloneDX'
 ```
- **Return Value:** > 0 if the signature is valid, otherwise fails validation.

look at the example using these function

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ImageValidatingPolicy
metadata:
  name: ivpol-sample
spec:
  webhookConfiguration:
    timeoutSeconds: 20
  failurePolicy: Ignore
  validationActions:
  - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  matchConditions:
    - name: "check-prod-label"  
      expression: >- 
        has(object.metadata.labels) && has(object.metadata.labels.prod) && object.metadata.labels.prod == 'true'
  imageRules:
    - glob: ghcr.io/*
  attestors:
    - name: notary
      notary:
        certs: |-
          -----BEGIN CERTIFICATE-----
          MIIDTTCCAjWgAwIBAgIJAPI+zAzn4s0xMA0GCSqGSIb3DQEBCwUAMEwxCzAJBgNV
          BAYTAlVTMQswCQYDVQQIDAJXQTEQMA4GA1UEBwwHU2VhdHRsZTEPMA0GA1UECgwG
          Tm90YXJ5MQ0wCwYDVQQDDAR0ZXN0MB4XDTIzMDUyMjIxMTUxOFoXDTMzMDUxOTIx
          MTUxOFowTDELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAldBMRAwDgYDVQQHDAdTZWF0
          dGxlMQ8wDQYDVQQKDAZOb3RhcnkxDTALBgNVBAMMBHRlc3QwggEiMA0GCSqGSIb3
          DQEBAQUAA4IBDwAwggEKAoIBAQDNhTwv+QMk7jEHufFfIFlBjn2NiJaYPgL4eBS+
          b+o37ve5Zn9nzRppV6kGsa161r9s2KkLXmJrojNy6vo9a6g6RtZ3F6xKiWLUmbAL
          hVTCfYw/2n7xNlVMjyyUpE+7e193PF8HfQrfDFxe2JnX5LHtGe+X9vdvo2l41R6m
          Iia04DvpMdG4+da2tKPzXIuLUz/FDb6IODO3+qsqQLwEKmmUee+KX+3yw8I6G1y0
          Vp0mnHfsfutlHeG8gazCDlzEsuD4QJ9BKeRf2Vrb0ywqNLkGCbcCWF2H5Q80Iq/f
          ETVO9z88R7WheVdEjUB8UrY7ZMLdADM14IPhY2Y+tLaSzEVZAgMBAAGjMjAwMAkG
          A1UdEwQCMAAwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA0G
          CSqGSIb3DQEBCwUAA4IBAQBX7x4Ucre8AIUmXZ5PUK/zUBVOrZZzR1YE8w86J4X9
          kYeTtlijf9i2LTZMfGuG0dEVFN4ae3CCpBst+ilhIndnoxTyzP+sNy4RCRQ2Y/k8
          Zq235KIh7uucq96PL0qsF9s2RpTKXxyOGdtp9+HO0Ty5txJE2txtLDUIVPK5WNDF
          ByCEQNhtHgN6V20b8KU2oLBZ9vyB8V010dQz0NRTDLhkcvJig00535/LUylECYAJ
          5/jn6XKt6UYCQJbVNzBg/YPGc1RF4xdsGVDBben/JXpeGEmkdmXPILTKd9tZ5TC0
          uOKpF5rWAruB5PCIrquamOejpXV9aQA/K2JQDuc0mcKz
          -----END CERTIFICATE-----
  attestations:
    - name: sbom
      referrer:
        type: sbom/cyclone-dx
  validations:
    - expression: >-
        images.containers.map(image, verifyImageSignatures(image, [attestors.notary])).all(e, e > 0)
      message: failed to verify image with notary cert
    - expression: >-
        images.containers.map(image, verifyAttestationSignatures(image, attestations.sbom ,[attestors.notary])).all(e, e > 0)
      message: failed to verify attestation with notary cer
    - expression: >-
        images.containers.map(image, payload(image, attestations.sbom).bomFormat == 'CycloneDX').all(e, e)
      message: sbom is not a cyclone dx sbom

```

The image parsing function enables iteration over container images, allowing validation and extraction of image-related metadata dynamically.  

### Expression  
```cel
images.containers.map(image, expression).all(e, e > 0)
```
- **`images.containers`** → Retrieves all container images in the resource.  
- **`.map(image, expression)`** → Iterates over each image and applies the given expression.  
- **`.all(e, e > 0)`** → Ensures that all evaluated results meet the condition (`e > 0`), meaning the validation passes only if every image satisfies the requirement.  

- **`imagedata()`**: Parses and validates OCI image metadata, including tags, digests, architecture, and more.[here](../validating-policy/_index.md#extended-cel-library)

## External Data

These functions are used in CEL to enable dynamic validation. The `http.Get()` and `http.Post()` functions allow real-time API calls to external services, ensuring policies can validate data dynamically. Additionally, the `globalContext.Get()` function fetches data both from within and outside the cluster through API calls and make it accessible to all the policies in cluster to reduce api call. This enhances Kyverno’s ability to interact with internal and external services, though it requires additional permissions for the Kyverno controller. These API calls are secured using certificates to ensure safe communication.

**Note:** Fetching these resources requires additional permissions for the Kyverno controller. These API calls are secured using certificates to ensure safe and authenticated communication.  

  

## Caching

In Kyverno's `ImageValidatingPolicy`, **caching is done internally and is automatically enabled** to enhance performance and reduce the load on the Kubernetes API server.  

### How Caching Works  

Kyverno stores frequently accessed data, such as **ConfigMaps, Secrets, and image metadata**, to **minimize repetitive API calls** during policy evaluations. This ensures that policies are enforced efficiently without unnecessary overhead on the cluster.  

### Benefits of Caching  

- **Improved Performance**: Reduces the time required for policy evaluations by avoiding redundant API queries.  
- **Lower API Server Load**: Minimizes excessive calls to the Kubernetes API, improving overall system stability.  
- **Efficient Policy Enforcement**: Ensures faster validation while maintaining accuracy in decision-making.  

Caching operates transparently in the background, requiring no manual configuration, making policy execution **faster, scalable, and more reliable** within Kyverno.  



## Reporting

In Kyverno's `ImageValidatingPolicy`, **policy reports** provide visibility into policy violations and compliance status. These reports are generated in **audit mode** and during **background scans**, helping administrators detect misconfigurations and enforce best practices across the cluster.  

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
apiVersion: wgpolicyk8s.io/v1alpha2
kind: PolicyReport
metadata:
  labels:
    app.kubernetes.io/managed-by: kyverno
  ownerReferences:
  - apiVersion: apps/v1
    kind: Deployment
    name: test-deployment-ivpol-background
scope:
  apiVersion: apps/v1
  kind: Deployment
  name: test-deployment-ivpol-background
results:
- message: Deployment labels must be env=prod but found env=staging
  policy: ivpol-report-background-sample
  result: fail
  scored: true
  source: KyvernoImageValidatingPolicy
summary:
  error: 0
  fail: 1
  pass: 0
  skip: 0
  warn: 0
```

## Auto-Generate Policies for Pod Controllers

Kyverno’s `ImageValidatingPolicy` supports **automatic policy generation** for pod controllers using the `generation` field. This feature simplifies policy management by allowing policies written for **Pods** to be automatically applied to higher-level controllers like **Deployments** and **CronJobs**.  

### How Auto-Generation Works  

When `generation.podControllers.enabled` is set to `true`, Kyverno automatically creates corresponding policies for the specified pod controllers, ensuring consistency in enforcement across different workload types.  

## Background Scanning

Kyverno's `ImageValidatingPolicy` supports **background scanning**, which ensures that policies remain effective even after the initial admission review. While policies are typically evaluated when a resource is created or modified, background scanning helps maintain compliance over time by continuously checking resources against active policies.  

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