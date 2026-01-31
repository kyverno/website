---
title: Migrating to CEL Policies
weight: 10
description: Complete guide for migrating from `ClusterPolicy` to CEL-based policy types
---

This guide helps you migrate from `ClusterPolicy` to the new CEL-based [policy types](/docs/policy-types/overview/).

:::note[Tip]
Use `kubectl explain cpol.spec` for help on the ClusterPolicy schema.

- `kubectl explain vpol.spec` for ValidatingPolicy schema
- `kubectl explain mpol.spec` for MutatingPolicy schema
- `kubectl explain gpol.spec` for GeneratingPolicy schema
- `kubectl explain dpol.spec` for DeletingPolicy schema
- `kubectl explain ivpol.spec` for ImageValidaingPolicy schema
  :::

## Key Differences

**ClusterPolicy Structure**

A ClusterPolicy contains an [orderered list of rules](/docs/policy-types/cluster-policy/overview/) and [common settings](/docs/policy-types/cluster-policy/policy-settings/).

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
  rules:
    - name: check-labels
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: 'Required labels missing'
        pattern:
          metadata:
            labels:
              app: '?*'
              version: '?*'
```

**CEL-based Policy Structure**

Kyverno CEL-based policies are defined as discrete types where each policy is focused on a single action e.g., validate, mutate, generate, or cleanup. Each CEL-based policy can contain an ordered list of actions of the same type, e.g. `spec.validations`.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-app-version-labels
spec:
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ''
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
  validationActions:
    - Deny
  validations:
    - expression: >
        ['app', 'version'].all(label, 
          object.metadata.?labels[label].orValue('') != ''
        )
      message: 'Required labels missing'
```

## Policy Settings

Here is a mapping of each ClusterPolicy field to the CEL-based equivalent:

**Common Fields**

| **ClusterPolicy**                             | **CEL-based policies**                                                   |
| --------------------------------------------- | ------------------------------------------------------------------------ |
| **spec.admission**                            | `spec.evaluation.admission.enabled`                                      |
| **applyRules**                                | not applicable; convert each rule to a policy and use `matchConditions`. |
| **spec.background**                           | `spec.evaluation.background.enabled`                                     |
| **spec.emitWarning**                          | `spec.validationActions: Warn`                                           |
| **spec.useServerSideApply**                   | See: [#14853](https://github.com/kyverno/kyverno/issues/14853)           |
| **spec.webhookConfiguration.failurePolicy**   | `spec.failurePolicy`                                                     |
| **spec.webhookConfiguration.matchConditions** | `spec.matchConditions`                                                   |
| **spec.webhookConfiguration.timeoutSeconds**  | `spec.webhookConfiguration.timeoutSeconds`                               |

**Rule Fields**

| **ClusterPolicy**                     | **CEL-based policies**                                         |
| ------------------------------------- | -------------------------------------------------------------- |
| **spec.rules.match**                  | `spec.matchExpressions` and `spec.matchConditions`             |
| **spec.rules.exclude**                | `spec.matchConstraints.excludeResourceRules`                   |
| **spec.rules.context**                | `spec.variables`                                               |
| **spec.rules.preconditions**          | `spec.matchConditions`                                         |
| **spec.rules.celPreconditions**       | `spec.matchConditions`                                         |
| **spec.rules.skipBackgroundRequests** | See: [#14852](https://github.com/kyverno/kyverno/issues/14852) |
| **spec.rules.reportProperties**       | `spec.auditAnnotations`                                        |
| **spec.rules.validate**               | `ValidatingPolicy`                                             |
| **spec.rules.mutate**                 | `MutatingPolicy`                                               |
| **spec.rules.generate**               | `GeneratingPolicy`                                             |
| **spec.rules.imageExtactors**         | `variables.expressions`                                        |
| **spec.rules.verifyImages**           | `ImageValidatingPolicy`                                        |

## Validate Rule

| **ClusterPolicy**                               | **CEL-based policies**                                                              |
| ----------------------------------------------- | ----------------------------------------------------------------------------------- |
| **spec.rules.validate.allowExistingViolations** | not supported; use policy exceptions instead                                        |
| **spec.rules.validate.anyPattern**              | `spec.validations`                                                                  |
| **spec.rules.validate.assert**                  | `spec.validations`                                                                  |
| **spec.rules.validate.cel**                     | `spec.validations`                                                                  |
| **spec.rules.validate.deny**                    | `spec.validations` and invert the logic                                             |
| **spec.rules.validate.failureAction**           | `spec.validationActions`                                                            |
| **spec.rules.validate.failureActionOverrides**  | not supported; use policy exceptions instead                                        |
| **spec.rules.validate.foreach**                 | `spec.validations` with CEL comprehensions like `all()`, `exists()`, `exists_one()` |
| **spec.rules.validate.manifests**               | Not supported                                                                       |
| **spec.rules.validate.message**                 | `spec.validations.message` or `spec.validations.messageExpression`                  |
| **spec.rules.validate.pattern**                 | `spec.validations`                                                                  |
| **spec.rules.validate.podSecurity**             | Not supported; use `spec.validations` for each pod security control                 |

**ClusterPolicy validate pattern:**

```yaml
validate:
  pattern:
    spec:
      containers:
        - name: '*'
          image: '!*:latest'
```

**ValidatingPolicy:**

```yaml
validations:
  - expression: >
      ['app', 'version'].all(label, 
        object.metadata.?labels[label].orValue('') != ''
      )
    message: "Pod must have an 'app' and 'version' labels"
```

**ClusterPolicy validate deny**

```yaml
validate:
  deny:
    conditions:
      all:
        - key: '{{ request.object.spec.replicas }}'
          operator: GreaterThan
          value: 10
  message: 'Replica count cannot exceed 10'
```

**ValidatingPolicy:**

Note the logic innversion when converting a `deny` rule to a CEL expression:

```yaml
validate:
  cel:
    expressions:
      - expression: 'object.spec.replicas <= 10'
        message: 'Replica count cannot exceed 10'
```

Refer to the [ValidatingPolicy documentation](/docs/policy-types/validating-policy/) for details and additional examples.

## Mutate Rule

| **ClusterPolicy**                         | **CEL-based policies**                                                              |
| ----------------------------------------- | ----------------------------------------------------------------------------------- |
| **spec.rules.mutate.foreach**             | CEL comprehensions e.g., `all()`, `exists()`, `exists_one()`                        |
| **spec.rules.mutate.mutateExisting**      | `spec.evaluation.mutateExisting.enabled`                                            |
| **spec.rules.mutate.patchStrategicMerge** | not supported; convert to `patchType: ApplyConfiguration` or `patchType: JSONPatch` |
| **spec.rules.mutate.patchesJson6902**     | `patchType: JSONPatch`                                                              |
| **spec.rules.mutate.targets**             | `spec.matchConstraints` or `spec.targetMatchConstraints`                            |

Refer to the [MutatingPolicy documentation](/docs/policy-types/mutating-policy/) for details and examples.

## Generate Rule

| **ClusterPolicy**                                      | **CEL-based policies**                           |
| ------------------------------------------------------ | ------------------------------------------------ |
| **spec.rules.generate.apiVersion**                     | CEL expressions                                  |
| **spec.rules.generate.clone**                          | CEL expressions                                  |
| **spec.rules.generate.cloneList**                      | CEL expressions                                  |
| **spec.rules.generate.data**                           | CEL expressions                                  |
| **spec.rules.generate.foreach**                        | CEL expressions                                  |
| **spec.rules.generate.generateExisting**               | `spec.evaluation.generateExisting`               |
| **spec.rules.generate.kind**                           | CEL expressions                                  |
| **spec.rules.generate.name**                           | CEL expressions                                  |
| **spec.rules.generate.namespace**                      | CEL expressions                                  |
| **spec.rules.generate.orphanDownstreamOnPolicyDelete** | `spec.evaluation.orphanDownstreamOnPolicyDelete` |
| **spec.rules.generate.synchronize**                    | `spec.evaluation.synchronize`                    |

A number of the GeneratingPolicy fields, such as the generated resource properties, are now directly handled as CEL expressions. See [GeneratingPolicy docs](/docs/policy-types/generating-policy/) for details.

## Verify Images Rule

The `verifyImages` rule in ClusterPolicy has been replaced with the dedicated `ImageValidatingPolicy` type in CEL-based policies. This section covers migrating image verification rules from ClusterPolicy to ImageValidatingPolicy.

### Mapping Reference

| **ClusterPolicy verifyImages** | **ImageValidatingPolicy**                                    |
| ------------------------------ | ------------------------------------------------------------ |
| **spec.rules.verifyImages**    | `ImageValidatingPolicy` (dedicated policy type)              |
| **verifyImages.attestations**  | `spec.attestors`                                             |
| **verifyImages.imageReferences** | `spec.matchImageReferences` or `spec.images`                 |
| **verifyImages.required**      | `spec.validationActions` (Deny/Warn)                         |
| **verifyImages.mutateDigest**  | `spec.mutate`                                                |
| **verifyImages.useCache**      | `spec.evaluation.cache.ttlSeconds`                           |
| **match/exclude**              | `spec.matchConstraints`                                      |

### Migration Example

**ClusterPolicy with verifyImages rule:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image
spec:
  validationFailureAction: enforce
  background: false
  rules:
    - name: verify-image-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
      verifyImages:
        - imageReferences:
            - 'ghcr.io/kyverno/*'
          attestations:
            - name: check-signature
              conditions:
                all:
                  - key: '{{ attestation.sbom.path }}'
                    operator: Equals
                    value: 'software-bill-of-materials.spdx.json'
          required: true
```

**ImageValidatingPolicy equivalent:**

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: verify-image
spec:
  failurePolicy: fail
  validationActions:
    - Deny
  evaluation:
    admission:
      enabled: true
    background:
      enabled: false
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchImageReferences:
    - glob: 'ghcr.io/kyverno/*'
  attestors:
    - name: check-signature
      cosign:
        key:
          kms: 'gcpkms://...' # Configure your KMS URI
  validations:
    - expression: >
        attestations.all(attestation, 
          attestation.sbom.path == 'software-bill-of-materials.spdx.json'
        )
      message: 'Image attestation must include SBOM'
```

### Key Differences

1. **Policy Type:** The `verifyImages` rule is now its own dedicated policy type (`ImageValidatingPolicy`) rather than being a rule within a ClusterPolicy.

2. **Image Extraction:** Use `spec.images` for custom resources to define CEL expressions that extract image references.

   ```yaml
   images:
     - name: extracted-images
       expression: '[object.spec.image, object.spec.initContainers[*].image]'
   ```

3. **Matching Images:** Use `spec.matchImageReferences` with glob patterns or CEL expressions:

   ```yaml
   matchImageReferences:
     - glob: 'gcr.io/myorg/*'
     - glob: 'docker.io/library/*'
     - expression: "image.registry == 'ghcr.io' && image.path.startsWith('kyverno/')"
   ```

4. **Attestor Configuration:** The `attestations` field is replaced with `attestors` which provides more structured configuration for cryptographic verification:

   ```yaml
   attestors:
     - name: verify-cosign
       cosign:
         key:
           kms: 'gcpkms://projects/myproject/locations/us/keyRings/my-ring/cryptoKeys/my-key'
         keyless:
           identities:
             - issuer: 'https://token.actions.githubusercontent.com'
               subject: 'https://github.com/myorg/myrepo/.github/workflows/release.yaml@refs/heads/main'
   ```

5. **Validation Actions:** The `required` field is replaced with `spec.validationActions`:
   - `Deny` - block resource creation/update
   - `Warn` - allow with warning

6. **Mutation:** To automatically replace image references with verified digests, use:

   ```yaml
   mutate:
     patchStrategicMerge:
       spec:
         containers:
           - (image): "{{ imageVerificationData.digest }}"
   ```

### Images from Custom Resources

For non-Pod resources, use the `images` field to extract image references:

```yaml
apiVersion: policies.kyverno.io/v1
kind: ImageValidatingPolicy
metadata:
  name: verify-custom-resource
spec:
  evaluation:
    mode: JSON
  matchConstraints:
    resourceRules:
      - apiGroups: ['custom.io']
        apiVersions: ['v1']
        kinds: ['Function']
  images:
    - name: function-images
      expression: '[object.spec.runtime.image, object.spec.build.baseImage]'
  matchImageReferences:
    - glob: 'gcr.io/*'
  attestors:
    - name: verify
      cosign:
        key:
          data: |
            -----BEGIN PUBLIC KEY-----
            ...
            -----END PUBLIC KEY-----
  validations:
    - expression: 'true'
      message: 'Image must be verified'
```

Refer to the [ImageValidatingPolicy documentation](/docs/policy-types/image-validating-policy/) for comprehensive details and additional examples.

## CleanupPolicy

| **CleanupPolicy**                  | **CEL-based policies**                             |
| ---------------------------------- | -------------------------------------------------- |
| **spec.conditions**                | `spec.matchConstraints` and `spec.matchConditions` |
| **spec.context**                   | `spec.variables`                                   |
| **spec.deletionPropagationPolicy** | `spec.deletionPropagationPolicy`                   |
| **spec.exclude**                   | `spec.matchConstraints.excludeResourceRules`       |
| **spec.match**                     | `spec.matchConstraints` and `spec.matchConditions` |
| **spec.schedule**                  | `spec.schedule`                                    |

Refer to the [DeletingPolicy documentation](/docs/policy-types/deleting-policy/) for details and examples.

## Context Variables

| Traditional Kyverno        | CEL Equivalent              | Description                             |
| -------------------------- | --------------------------- | --------------------------------------- |
| `{{ request.object }}`     | `object`                    | The resource being validated            |
| `{{ request.oldObject }}`  | `oldObject`                 | Previous version (for updates)          |
| `{{ request.operation }}`  | `request.operation`         | Operation type (CREATE, UPDATE, DELETE) |
| `{{ serviceAccountName }}` | `request.userInfo.username` | Service account name                    |
| `{{ request.namespace }}`  | `object.metadata.namespace` | Resource namespace                      |

## Testing

You can use the Kyverno CLI to validate the policy syntax:

```bash
# Test with a sample resource
kyverno apply validating-policy.yaml --resource test-pod.yaml
```

Alternatively, you can use the [Kyverno Playground](https://playground.kyverno.io/).

If you have existing [Kyverno CLI tests](/docs/kyverno-cli/reference/kyverno_test), you can use them with the new policy with no changes, and validate it works as expected.

If you have existing [Kyverno Chainsaw](/docs/subprojects/chainsaw/) tests, any policy type and status checks will need to be converted. The rest of the test logic can be reused.

## Troubleshooting

**CEL Expression Errors**

**Error:** `unknown field 'foo'`
**Solution:** Use `has()` or `?` to check field existence:

```yaml
expression: "has(object.metadata.labels) && has(object.metadata.labels.foo) && object.metadata.labels.foo == 'value'"
```

```yaml
expression: "object.metadata.?labels.foo.orValue('') == 'value'"
```

**Error:** `index out of bounds`
**Solution:** Check array length before accessing:

```yaml
expression: "size(object.spec.initContainers) > 0 && object.spec.initContainers[0].image != 'bad'"
```

**Error:** `expression of type 'any' cannot be range of a comprehension (must be list, map, or dynamic)`
**Solution:** Convert JSON types to `dynamic` using `orValue`

```yaml
"name": "deploymentList",
"expression": "resource.List('apps/v1', 'deployments', object.metadata.namespace).items.orValue([])"
```

## Additional Resources

- [CEL Language Specification](https://github.com/google/cel-spec)
- [Kyverno CEL Functions Reference](/docs/policy-types/cel-libraries/)
- [ValidatingPolicy API Reference](/docs/policy-types/validating-policy)
- [Kyverno CLI Testing Guide](/docs/kyverno-cli/reference/kyverno_test)
