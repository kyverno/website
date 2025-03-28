---
title: Applying Policies
description: >-
    Apply policies across clusters and delivery pipelines
weight: 48
---

{{% alert title="Tip" color="info" %}}
The [Kyverno Policies](/policies/) repository contains several policies you can immediately apply to your clusters.
{{% /alert %}}

## In Clusters

On installation, Kyverno runs as a [dynamic admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) in a Kubernetes cluster. Kyverno receives validating and mutating admission webhook HTTP callbacks from the Kubernetes API server and applies matching policies to return results that enforce admission policies or reject requests.

Exceptions to policies may be defined in the rules themselves or with a separate [PolicyException resource](/docs/exceptions).

[Cleanup policies](/docs/policy-types/cluster-policy/cleanup.md), another separate resource type, can be used to remove existing resources based upon a definition and schedule.

## In Pipelines

You can use the [Kyverno CLI](/docs/kyverno-cli/) to apply policies to YAML resource manifest files as part of a software delivery pipeline. This command line tool allows integrating Kyverno into GitOps style workflows and checks for policy compliance of resource manifests before they are committed to version control and applied to clusters.

Refer to the [Kyverno apply command section](/docs/kyverno-cli/usage/apply.md) for details on the CLI. And refer to the [Continuous Integration section](../testing-policies/index.md#continuous-integration) for an example of how to incorporate the CLI to apply and test policies in your pipeline.

## Via APIs

[Kyverno JSON policies](/docs/kyverno-json) and the new [ValidatingPolicy](/docs/policy-types/validating-policy/) and [ImageValidatingPolicy](/docs/policy-types/image-validating-policy/) types can be applied to any JSON payload. These policies can be applied via a Golang SDK or web service.
