---
title: Automated Governance & Compliance
excerpt: Use Kyverno policies to audit, report, and enforce organizational standards across Kubernetes environments.
sidebar:
  order: 12
---

## Introduction

Automated governance and compliance in Kubernetes means defining organizational standards as policies that are applied consistently across clusters, namespaces, and workloads. These standards may include required labels, security baselines, resource requirements, and compliance controls.

Kyverno helps platform and security teams implement these standards using Kubernetes-native policy as code. Policies can validate resources, apply defaults, generate supporting resources, and report compliance results, helping organizations continuously audit, report, and enforce governance requirements.

## Problem Space

As Kubernetes environments grow, maintaining consistent governance and compliance becomes difficult. Manual reviews do not scale across teams and clusters, making it harder to detect policy violations, configuration drift, and compliance gaps.

| Challenge                  | Risk                                                     |
| -------------------------- | -------------------------------------------------------- |
| Inconsistent standards     | Teams deploy resources differently.                      |
| Manual reviews             | Compliance checks become slow and difficult to maintain. |
| Missing ownership metadata | Resource ownership is unclear.                           |
| Untracked violations       | Non-compliant resources go unnoticed.                    |
| Configuration drift        | Resources move away from approved standards.             |
| Limited visibility         | Teams cannot easily assess compliance posture.           |

Kyverno helps automate governance and compliance through Kubernetes-native policies, audit reporting, and continuous enforcement.

## Desired Outcome

| Outcome               | What it means                                          |
| --------------------- | ------------------------------------------------------ |
| Compliance visibility | Teams can see policy violations and compliance status. |
| Automated enforcement | Non-compliant resources are identified or blocked.     |
| Audit-first adoption  | Policies can start in `Audit` mode before enforcement. |
| Consistent standards  | Labels, metadata, and controls are applied uniformly.  |
| Reduced drift         | Resources stay aligned with approved standards.        |
| Managed exceptions    | Policy exceptions remain controlled and visible.       |
| Shared governance     | Common standards are applied across teams.             |

## Kyverno Capabilities

Kyverno provides Kubernetes-native policy capabilities that help teams automate governance and compliance across clusters and workloads.

### Validation Policies

Validation policies check resources against organizational standards before admission. Teams can use validation rules to enforce required labels, security controls, resource requirements, and compliance standards.

Relevant documentation:

- [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy)

This `ValidatingPolicy` requires Pods to include ownership and environment labels.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-governance-labels
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: >-
        has(object.metadata.labels) &&
        "owner" in object.metadata.labels &&
        "environment" in object.metadata.labels
      message: 'Pods must define owner and environment labels.'
```

### Mutation Policies

Mutation policies automatically apply metadata and configuration defaults. This helps teams standardize resources and reduce manual configuration effort.

Relevant documentation:

- [MutatingPolicy](https://kyverno.io/docs/policy-types/mutating-policy)

This `MutatingPolicy` adds a default governance label to Pods when the label is missing.

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-governance-label
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchConditions:
    - name: governance-label-missing
      expression: >-
        !has(object.metadata.labels) ||
        !("governance" in object.metadata.labels)
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >-
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                governance: "standard"
              }
            }
          }
```

### Generate Policies

Generate policies create baseline resources automatically. Platform teams can use generate rules to bootstrap namespaces with required governance controls.

Relevant documentation:

- [GeneratingPolicy](https://kyverno.io/docs/policy-types/generating-policy)

This `GeneratingPolicy` generates a default `ResourceQuota` for namespaces labeled `governance=enabled`.

```yaml
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: generate-default-resourcequota
spec:
  evaluation:
    synchronize:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['namespaces']
  matchConditions:
    - name: governance-enabled
      expression: >-
        has(object.metadata.labels) &&
        object.metadata.labels["governance"] == "enabled"
  variables:
    - name: targetNamespace
      expression: object.metadata.name
    - name: defaultQuota
      expression: |-
        [
          {
            "apiVersion": dyn("v1"),
            "kind": dyn("ResourceQuota"),
            "metadata": dyn({
              "name": "default-resource-quota"
            }),
            "spec": dyn({
              "hard": dyn({
                "requests.cpu": "4",
                "requests.memory": "8Gi",
                "limits.cpu": "8",
                "limits.memory": "16Gi"
              })
            })
          }
        ]
  generate:
    - expression: generator.Apply(variables.targetNamespace, variables.defaultQuota)
```

### Policy Reports and Audit Mode

Policy reports provide visibility into policy results across the cluster. Teams can start validation policies in `Audit` mode to review violations before moving to `Deny`.

Relevant documentation:

- [Policy Reports](https://kyverno.io/docs/guides/reports)
- [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy)

This `ValidatingPolicy` audits Pods that are missing required labels.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: audit-required-labels
spec:
  validationActions:
    - Audit
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - expression: >-
        has(object.metadata.labels) &&
        "owner" in object.metadata.labels &&
        "environment" in object.metadata.labels
      message: 'Pods should define owner and environment labels.'
```

View policy reports with `kubectl`.

```sh
kubectl get policyreports -A
kubectl get clusterpolicyreports
```

### Policy Exceptions

Policy exceptions allow specific workloads or namespaces to bypass a policy without changing the original policy definition. This helps teams manage exceptions in a controlled and auditable way.

Relevant documentation:

- [Policy Exceptions](https://kyverno.io/docs/guides/exceptions)

For example, a platform team may allow one workload to bypass a specific policy while the broader policy remains enforced across the cluster.

## Real-World Governance Use Cases

| Use case                   | Kyverno outcome                                          |
| -------------------------- | -------------------------------------------------------- |
| Require ownership labels   | Resources can be identified and tracked consistently.    |
| Audit compliance           | Policy violations are reported across the cluster.       |
| Enforce standards          | Resources must meet organizational requirements.         |
| Track policy violations    | Teams gain visibility into compliance status.            |
| Manage exceptions          | Policy exceptions remain controlled and auditable.       |
| Enforce security baselines | Non-compliant resources are reported or blocked.         |
| Report compliance posture  | Teams can review governance results across environments. |

## Outcome Mapping

| User goal                   | Kyverno capability  | Example outcome                                  |
| --------------------------- | ------------------- | ------------------------------------------------ |
| Track compliance violations | Policy Reports      | Policy results are visible across resources.     |
| Enforce standards           | Validation Policies | Non-compliant resources are reported or blocked. |
| Standardize metadata        | Mutation Policies   | Required labels are applied automatically.       |
| Create baseline controls    | Generate Policies   | Required resources are created automatically.    |
| Roll out policies safely    | Audit Mode          | Teams review violations before enforcement.      |
| Manage exceptions           | Policy Exceptions   | Exceptions remain controlled and auditable.      |

## Implementation Path

1. Identify organizational standards and compliance requirements.
2. Start with policies in `Audit` mode and review violations.
3. Review policy reports with application teams.
4. Enforce critical governance controls.
5. Use scoped exceptions when required.
6. Expand governance across teams, namespaces, and clusters.

## Community Resources

Explore these resources to learn more about governance, compliance, and policy-driven operations in Kubernetes.

- [Kyverno Policy Library](https://kyverno.io/policies/)
- [Kyverno Policy Reports](https://kyverno.io/docs/policy-reports/)
- [Kyverno Policy Exceptions](https://kyverno.io/docs/exceptions/)
- [CNCF TAG Security](https://tag-security.cncf.io/)

## Related Documentation

- [ValidatingPolicy](https://kyverno.io/docs/policy-types/validating-policy)
- [MutatingPolicy](https://kyverno.io/docs/policy-types/mutating-policy)
- [GeneratingPolicy](https://kyverno.io/docs/policy-types/generating-policy)
- [Policy Reports](https://kyverno.io/docs/guides/reports)
- [Policy Exceptions](https://kyverno.io/docs/guides/exceptions)
- [Admission Controllers](https://kyverno.io/docs/guides/admission-controllers)
