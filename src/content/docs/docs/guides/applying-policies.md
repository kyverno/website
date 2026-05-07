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

Kyverno primarily operates as a [dynamic admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) within a Kubernetes cluster. It processes admission webhook requests from the Kubernetes API server and applies policies to validate, mutate, or generate resources. Additionally, Kyverno can verify container images and manage resource lifecycles using cleanup policies.

The following table summarizes these core capabilities and their expected outcomes when applying policies in a cluster:

| Capability        | Outcome                                                                          |
| :---------------- | :------------------------------------------------------------------------------- |
| **Validate**      | Checks resource configurations and blocks non-compliant requests.                |
| **Mutate**        | Modifies resources during admission to ensure they conform to standards.         |
| **Generate**      | Automates the creation of additional resources based on lifecycle triggers.      |
| **Verify Images** | Validates container image signatures and attestations for supply chain security. |
| **Cleanup**       | Removes stale or unwanted resources according to defined criteria and schedules. |

For observability, Kyverno generates [PolicyReports](/docs/guides/reports) that provide detailed results for each policy. These reports can be visualized using tools like [Policy Reporter](https://github.com/kyverno/policy-reporter).

Exceptions to policies may be defined in the rules themselves or with a separate [PolicyException resource](/docs/guides/exceptions).

## In Pipelines

You can use the [Kyverno CLI](/docs/subprojects/kyverno-cli) to apply policies to YAML resource manifest files as part of a software delivery pipeline. This command line tool allows integrating Kyverno into GitOps style workflows and checks for policy compliance of resource manifests before they are committed to version control and applied to clusters.

Refer to the [Kyverno apply command section](/docs/kyverno-cli/reference/kyverno_apply) for details on the CLI. And refer to the [Continuous Integration section](/docs/guides/testing-policies#continuous-integration) for an example of how to incorporate the CLI to apply and test policies in your pipeline.

## Via APIs

[Kyverno JSON policies](/docs/subprojects/kyverno-json/) and the new [ValidatingPolicy](/docs/policy-types/validating-policy) and [ImageValidatingPolicy](/docs/policy-types/image-validating-policy) types can be applied to any JSON payload. These policies can be applied via a Golang SDK or web service.
