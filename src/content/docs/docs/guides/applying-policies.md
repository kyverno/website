---
title: Applying Policies
excerpt: Apply policies across clusters and delivery pipelines
sidebar:
  order: 40
---

:::tip[Tip]
The [Kyverno Policies](/policies/) repository contains several policies you can immediately apply to your clusters.
:::

## In Clusters

On installation, Kyverno runs as a [dynamic admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) in a Kubernetes cluster. Kyverno receives validating and mutating admission webhook HTTP callbacks from the Kubernetes API server and applies matching policies to return results that enforce admission policies or reject requests.

Exceptions to policies may be defined in the rules themselves or with a separate [PolicyException resource](/docs/guides/exceptions).

[Cleanup policies](/docs/policy-types/cleanup-policy), another separate resource type, can be used to remove existing resources based upon a definition and schedule.

The table below summarizes the core capabilities of Kyverno and their outcomes:

| Capability        | Outcome                                                        |
| :---------------- | :------------------------------------------------------------- |
| **Validate**      | Resources that do not comply with policies are blocked.        |
| **Mutate**        | Resources are modified to match policy definitions.            |
| **Generate**      | New resources are automatically created based on triggers.     |
| **Verify Images** | Container images are verified for signatures and attestations. |
| **Cleanup**       | Existing resources are removed based on a schedule.            |

Kyverno also generates [PolicyReports](/docs/guides/reports) to provide observability for policy results, which can be visualized using tools like [Policy Reporter](https://github.com/kyverno/policy-reporter).

## In Pipelines

You can use the [Kyverno CLI](/docs/subprojects/kyverno-cli) to apply policies to YAML resource manifest files as part of a software delivery pipeline. This command line tool allows integrating Kyverno into GitOps style workflows and checks for policy compliance of resource manifests before they are committed to version control and applied to clusters.

Refer to the [Kyverno apply command section](/docs/kyverno-cli/reference/kyverno_apply) for details on the CLI. And refer to the [Continuous Integration section](/docs/guides/testing-policies#continuous-integration) for an example of how to incorporate the CLI to apply and test policies in your pipeline.

## Via APIs

[Kyverno JSON policies](/docs/subprojects/kyverno-json/) and the new [ValidatingPolicy](/docs/policy-types/validating-policy) and [ImageValidatingPolicy](/docs/policy-types/image-validating-policy) types can be applied to any JSON payload. These policies can be applied via a Golang SDK or web service.
