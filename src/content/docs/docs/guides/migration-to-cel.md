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
| **spec.rules.mutate.targets**             | CEL expressions                                                                     |

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
