---
date: 2024-10-30
title: Announcing Kyverno Release 1.13!
slug: blog/announcing-kyverno-release-1.13
tags:
  - Releases
excerpt: Kyverno 1.13 released with Sigstore bundle verification, exceptions for validatingAdmissionPolicies, new assertion trees, generate enhancments, enhanced ValidatingAdmissionPolicy and PolicyException support, and tons more!
draft: false
---

Kyverno 1.13 contains [over 700 changes from 39 contributors](https://github.com/kyverno/kyverno/compare/release-1.12...v1.13.0-rc.3)! In this blog, we will highlight some of the major changes and enhancements for the release.

![kyverno](kyverno.png)

## Major Features

### Sigstore Bundle Verification

Kyverno 1.13 introduces support for verifying container images signatures that use the [sigstore bundle format](https://github.com/sigstore/protobuf-specs/blob/main/protos/sigstore_bundle.proto). This enables seamless support for [GitHub Artifact Attestations](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations) to be verified using verification type `SigstoreBundle`. 

The following example verifies images containing SLSA Provenance created and signed using GitHub Artifact Attestation.

Here is an example policy:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sigstore-image-verification
spec:
  validationFailureAction: Enforce
  webhookTimeoutSeconds: 30
  rules:
    - match:
        any:
          - resources:
              kinds:
                - Pod
      name: sigstore-image-verification
      verifyImages:
        - imageReferences:
            - '*'
          type: SigstoreBundle
          attestations:
            - type: https://slsa.dev/provenance/v1
              attestors:
                - entries:
                    - keyless:
                        issuer: https://token.actions.githubusercontent.com
                        subject: https://github.com/nirmata/github-signing-demo/.github/workflows/build-attested-image.yaml@refs/heads/main
                        rekor:
                          url: https://rekor.sigstore.dev
                        additionalExtensions:
                          githubWorkflowTrigger: push
                          githubWorkflowName: build-attested-image
                          githubWorkflowRepository: nirmata/github-signing-demo
              conditions:
                - all:
                    - key: '{{ buildDefinition.buildType }}'
                      operator: Equals
                      value: 'https://actions.github.io/buildtypes/workflow/v1'
                    - key: '{{ buildDefinition.externalParameters.workflow.repository }}'
                      operator: Equals
                      value: 'https://github.com/nirmata/github-signing-demo'
```

The demo repository is available at: https://github.com/nirmata/github-signing-demo.

### Exceptions for ValidatingAdmissionPolicies

Kyverno 1.13 introduces the ability to leverage PolicyException declarations while auto-generating Kubernetes ValidatingAdmissionPolicies directly from Kyverno policies that use the `validate.cel` subrule.

The resources specified within the PolicyException are then used to populate the `matchConstraints.excludeResourceRules` field of the generated ValidatingAdmissionPolicy, effectively creating exclusions for those resources. This functionality is illustrated below with an example of a Kyverno ClusterPolicy and a PolicyException, along with the resulting ValidatingAdmissionPolicy.

Kyverno policy:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-path
spec:
  background: false
  rules:
    - name: host-path
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - StatefulSet
              operations:
                - CREATE
                - UPDATE
              namespaceSelector:
                matchExpressions:
                  - key: type
                    operator: In
                    values:
                      - connector
      validate:
        failureAction: Audit
        cel:
          expressions:
            - expression: '!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))'
              message: 'HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset.'
```

PolicyException:

```yaml
apiVersion: kyverno.io/v2
kind: PolicyException
metadata:
  name: policy-exception
spec:
  exceptions:
    - policyName: disallow-host-path
      ruleNames:
        - host-path
  match:
    any:
      - resources:
          kinds:
            - Deployment
          names:
            - important-tool
          operations:
            - CREATE
            - UPDATE
```

The generated ValidatingAdmissionPolicy and its binding are as follows:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path
  ownerReferences:
    - apiVersion: kyverno.io/v1
      kind: ClusterPolicy
      name: disallow-host-path
spec:
  failurePolicy: Fail
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
          - statefulsets
    namespaceSelector:
      matchExpressions:
        - key: type
          operator: In
          values:
            - connector
    excludeResourceRules:
      - apiGroups:
          - apps
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resourceNames:
          - important-tool
        resources:
          - deployments
  validations:
    - expression:
        '!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume,
        !has(volume.hostPath))'
      message:
        HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath
        must be unset.
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path-binding
  ownerReferences:
    - apiVersion: kyverno.io/v1
      kind: ClusterPolicy
      name: disallow-host-path
spec:
  policyName: disallow-host-path
  validationActions: [Audit, Warn]
```

In addition, Kyverno policies targeting resources within a specific namespace will now generate a ValidatingAdmissionPolicy that utilizes the `matchConstraints.namespaceSelector` field to scope its enforcement to that namespace.

Policy snippet:

```yaml
match:
  any:
    - resources:
        kinds:
          - Deployment
        operations:
          - CREATE
          - UPDATE
        namespaces:
          - production
          - staging
```

The generated ValidatingAdmissionPolicy:

```yaml
matchConstraints:
  namespaceSelector:
    matchExpressions:
      - key: kubernetes.io/metadata.name
        operator: In
        values:
          - production
          - staging
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
```

### Validation Rules with Assertion Trees

Kyverno-JSON allows Kyverno policies to be used anywhere, even for non-Kubernetes workloads. It introduces the powerful concept of [assertion trees](https://kyverno.io/blog/2023/12/13/kyverno-chainsaw-exploring-the-power-of-assertion-trees/).

Previously the [Kyverno CLI added support for assertion trees](https://kyverno.io/docs/kyverno-cli/assertion-trees/), and now in Release 1.13 assertion trees can also be used in validation rules as a sub-type.

Here is an example of a policy that uses an assertion tree to deny pods from using the default service account:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-default-sa
spec:
  validationFailureAction: Enforce
  rules:
    - match:
        any:
          - resources:
              kinds:
                - Pod
      name: disallow-default-sa
      validate:
        message: default ServiceAccount should not be used
        assert:
          object:
            spec:
              (serviceAccountName == ‘default’): false
```

## Other Features and Enhancements

### Generate Changes

The `foreach` declaration allows the generation of multiple target resources of sub-elements in resource declarations. Each `foreach` entry must contain a list attribute, written as a JMESPath expression without braces, that defines sub-elements it processes.

Here is an example of creating networkpolicies for a list of Namespaces, the namespaces are stored in a ConfigMap which can be easily configured dynamically.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: foreach-generate-data
spec:
  rules:
    - match:
        any:
          - resources:
              kinds:
                - ConfigMap
      name: k-kafka-address
      generate:
        generateExisting: false
        synchronize: true
        orphanDownstreamOnPolicyDelete: false
        foreach:
          - list: request.object.data.namespaces | split(@, ‘,’)
            apiVersion: networking.k8s.io/v1
            kind: NetworkPolicy
            name: my-networkpolicy-{{element}}-{{ elementIndex }}
            namespace: ‘{{ element }}’
            data:
              metadata:
                labels:
                  request.namespace: ‘{{ request.object.metadata.name }}’
                  element: ‘{{ element }}’
                  elementIndex: ‘{{ elementIndex }}’
              spec:
                podSelector: {}
                policyTypes:
                  - Ingress
                  - Egress
```

The triggering ConfigMap is defined as follows, the data contains a namespaces field that defines multiple namespaces.

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: default-deny
  namespace: default
data:
  namespaces: foreach-ns-1,foreach-ns-2
```

Similarly, below is an example of a clone source type of `foreach` declaration that clones the source Secret into a list of matching existing namespaces which is stored in the same ConfigMap as above.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: foreach-clone
spec:
  rules:
    - name: k-kafka-address
      match:
        any:
          - resources:
              kinds:
                - ConfigMap
              namespaces:
                - default
      generate:
        generateExisting: false
        synchronize: true
        foreach:
          - list: request.object.data.namespaces | split(@, ',')
            apiVersion: v1
            kind: Secret
            name: cloned-secret-{{ elementIndex }}-{{ element }}
            namespace: '{{ element }}'
            clone:
              namespace: default
              name: source-secret
```

In addition, each `foreach` declaration supports the following declarations: Context and Preconditions. For more information please see [Kyverno documentation](/docs/policy-types/cluster-policy/generate#foreach).

This release also allows updates to the generate rule pattern. In addition to deletion, if the triggering resource is altered in a way such that it no longer matches the definition in the rule, that too will cause the removal of the downstream resource.

### API call enhancements

#### Default Values

In the case where the API server returns an error, `apiCall.default` can be used to provide a fallback value for the API call context entry.

The following example shows how to add default value to context entries:

```yaml
context:
  - name: currentnamespace
    apiCall:
      urlPath: “/api/v1/namespaces/{{ request.namespace }}”
      jmesPath: metadata.name
      default: default
```

#### Custom Headers

Kyverno Service API calls now also support custom headers. This can be useful for authentication or adding other HTTP request headers. Here is an example of adding a token in the HTTP Authorization header:

```yaml
context:
  - name: result
    apiCall:
      method: POST
      data:
        - key: foo
          value: bar
        - key: namespace
          value: '{{ `{{ request.namespace }}` }}'
      service:
        url: http://my-service.svc.cluster.local/validation
        headers:
          - key: 'UserAgent'
            value: 'Kyverno Policy XYZ'
          - key: 'Authorization'
            value: 'Bearer {{ MY_SECRET }}'
```

### Policy Report Enhancements

#### Reports for Mutate and Generate rules

In addition to validate and verifyImages rules, Kyverno 1.13 supports reporting for generate and mutate, including mutate existing policies, to record policy results. The container flag `--enableReporting` can be used to enable or disable reports for specific rule types. It allows the comma-separated values, validate, mutate, mutateExisting, generate, and imageVerify. See details [here](https://main.kyverno.io/docs/installation/customization/#container-flags).

A result entry will be audited in the policy report for rule decision:

```yaml
apiVersion: wgpolicyk8s.io/v1alpha2
kind: PolicyReport
metadata:
  labels:
    app.kubernetes.io/managed-by: kyverno
  namespace: default
results:
  - message: mutated Pod/good-pod in namespace default
    policy: add-labels
    result: pass
    rule: add-labels
    scored: true
    source: kyverno
scope:
  apiVersion: v1
  kind: Pod
  name: good-pod
  namespace: default
```

Note that the proper permissions need to be granted to the reports controller, a warning message will be returned upon policy admission if no RBAC permission is configured.

#### Custom Data in Reports

A new field `reportProperties` is introduced to custom data in policy reports. For example, a validate rule below adds two additional entries operation and objName to the policy reports:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-owner
spec:
  background: false
  rules:
    - match:
        any:
          - resources:
              kinds:
                - Namespace
      name: check-owner
      context:
        - name: objName
          variable:
            jmesPath: request.object.metadata.name
      reportProperties:
        operation: ‘{{ request.operation }}’
        objName: ‘{{ objName }}’
      validate:
        validationFailureAction: Audit
        message: The `owner` label is required for all Namespaces.
        pattern:
          metadata:
            labels:
              owner: ?*
```

You can find the two custom entries added to `results.properties`:

```yaml
apiVersion: wgpolicyk8s.io/v1alpha2
kind: ClusterPolicyReport
metadata:
  ownerReferences:
    - apiVersion: v1
      kind: Namespace
      name: bar
results:
  - message: validation rule ‘check-owner’ passed.
    policy: require-owner
    result: pass
    rule: check-owner
    scored: true
    source: kyverno
    properties:
      objName: bar
      operation: CREATE
scope:
  apiVersion: v1
  kind: Namespace
  name: bar
```

### GlobalContextEntries Enhancements

#### API Call Retry

Kyverno’s GlobalContextEntry provides a powerful mechanism to fetch external data and use it within policies. When leveraging the apiCall feature to retrieve data from an API, transient network issues can sometimes hinder successful retrieval.

To address this, Kyverno now offers built-in retry logic for API calls within GlobalContextEntry. You can now optionally specify a retryLimit for your API calls:

```yaml
apiVersion: kyverno.io/v2alpha1
kind: GlobalContextEntry
metadata:
  name: gctxentry-apicall-correct
spec:
  apiCall:
    urlPath: '/apis/apps/v1/namespaces/test-globalcontext-apicall-correct/deployments'
    refreshInterval: 1h
    retryLimit: 3
```

The `retryLimit` field determines the number of times Kyverno will attempt to make the API call if it initially fails. This field is optional and defaults to 3, ensuring a reasonable level of resilience against temporary network hiccups.

By incorporating this retry mechanism, Kyverno further strengthens its ability to reliably fetch external data, ensuring your policies can function smoothly even in the face of occasional connectivity issues. This enhancement improves the overall robustness and dependability of your Kubernetes policy enforcement framework.

#### CLI-based Injection of Global Context Entries

Kyverno CLI now allows you to dynamically inject global context entries using a Values file. This feature facilitates flexible policy testing and execution by simulating different scenarios without modifying GlobalContextEntry resources in your cluster.

You can now define global values and rule-specific values within the Values file, providing greater control over policy evaluation during testing.

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Value
metadata:
  name: values
globalValues:
  request.operation: CREATE
policies:
  - name: gctx
    rules:
      - name: main-deployment-exists
        values:
          deploymentCount: 1
```

In this example, `request.operation` is set as a global value, and deploymentCount is set for a specific rule in the gctx policy. When using the Kyverno CLI, you can reference this Values file to inject these global context entries into your policy evaluation.

### Security Hardening

The Kyverno project strives to be secure and production-ready, while providing ease of use. This release contains important changes to further enhance the security of the project.

#### Removal of wildcard roles

Prior versions of Kyverno included wildcard view permissions. These have been removed in 1.13 and replaced with a role binding to the system view role.

This change does not impact policy behaviors during admission controls, but may impact users with mutate and generate policies for custom resources, and may impact reporting of policy results for validation rules on custom resources A Helm option was added to upgrade Kyverno without breaking existing policies, see the upgrade guidance [here](https://main.kyverno.io/docs/installation/upgrading/#upgrading-to-kyverno-v113).

#### Removal of insecure configuration for exceptions

In prior versions, policy exceptions were allowed in all namespaces. This creates a potential security issue, as any user with permission to create a policy exception can bypass policies, even in other namespaces. See [CVE-2024-48921](https://github.com/kyverno/kyverno/security/advisories/GHSA-qjvc-p88j-j9rm) for more details.

This release changes the defaults to disable the policy exceptions and only allows exceptions to be created in a specified namespace. To maintain backward compatibility follow the [upgrade guidance](https://main.kyverno.io/docs/installation/upgrading/#upgrading-to-kyverno-v113).

### Warnings for Policy Violations and Mutations

A warning message can now be returned along with admission responses by the policy setting `spec.emitWarning`, this can be used to report policy violations as well as mutations upon admission events.

### Shallow evaluation of Variables

Kyverno performs nested variable substitution by default, this may not be desirable in certain situations. Take the following ConfigMap as an example, it defines a `.hcl` string content using the same `{{ }}` notation which is used in Kyverno for variable syntax. In this case, Kyverno needs to be instructed to not attempt to resolve variables in the HCL, this can be achieved by `{{- ... }}` notation for shallow (one time only) substitution of variables.

```yaml
apiVersion: v1
data:
  config: |-
    from_string
    {{ some hcl tempalte }}
kind: ConfigMap
metadata:
  annotations:
  labels:
    argocd.development.cpl.<removed>.co.at/app: corp-tech-ap-team-ping-ep
  name: vault-injector-config-http-echo
  namespace: corp-tech-ap-team-ping-ep
```

To only substitute the rule data with the HCL, and not perform nested substitutions, the following policy uses the declaration `{{- hcl }}` for shallow substitution.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: vault-auth-backend
spec:
  validationFailureAction: Audit
  background: true
  mutateExistingOnPolicyUpdate: true
  rules:
    - name: vault-injector-config-blue-to-green-auth-backend
      context:
        - name: hcl
          variable:
            jmesPath: replace_all( ‘{{ request.object.data.config }}’, ‘from_string’,‘to_string’)
      match:
        any:
          - resources:
              kinds:
                - ConfigMap
              names:
                - test-*
              namespaces:
                - corp-tech-ap-team-ping-ep
      mutate:
        patchStrategicMerge:
          data:
            config: ‘{{- hcl }}’
        targets:
          - apiVersion: v1
            kind: ConfigMap
            name: ‘{{ request.object.metadata.name }}’
            namespace: ‘{{ request.object.metadata.namespace }}’
```

### Improved ArgoCD Integration

Kyverno-managed webhook configurations are auto-cleaned up upon uninstallation. This behavior could be broken if Kyverno loses RBAC permissions to do so given the random resources deletion order. This release introduces a finalizer-based cleanup solution to ensure webhooks are removed successfully.

This feature is in [beta stage](https://main.kyverno.io/docs/installation/uninstallation/#clean-up-webhooks) and will be used as the default cleanup strategy in the future.

### API Version Management

Kyverno 1.13 introduces new changes in the policy CRDs:

- Both Policy Exceptions and Cleanup Policies have graduated to a stable version (v2).
- Several policy settings are deprecated:
  - spec.validationFailureAction
  - spec.validationFailureActionOverrides
  - spec.mutateExistingOnPolicyUpdate
  - spec.generateExisting

- These are replaced by more granular controls within the rule itself:
  - spec.rules[*].validate.failureAction
  - spec.rules[*].validate.failureActionOverrides
  - spec.rules[*].verifyImages[*].failureAction
  - spec.rules[*].mutate.mutateExisting
  - spec.rules[*].generate.generateExisting

Note that the deprecated fields will be removed in a future release, so migration to the new settings is recommended.

## Conclusion

Kyverno 1.13 promises to be a great release, with many new features, enhancements, and fixes. To get started with Kyverno try the [quick start guides](https://kyverno.io/docs/introduction/quick-start/) or head to the [installation](/docs/installation/installation) section of the docs.

To get the most value out of Kyverno, and check out the [available enterprise solutions](https://kyverno.io/support)!
