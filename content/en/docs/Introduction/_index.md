---
title: "Introduction"
linkTitle: "Introduction"
weight: 10
description: >
  Learn about Kyverno and create your first policy.
---

## Features

Kyverno is a policy engine designed for Kubernetes. Here are some of its features:

* policies as Kubernetes resources (no new language to learn!)
* validate, mutate, or generate any resource
* match resources using label selectors and wildcards
* validate and mutate using overlays (like Kustomize!)
* synchronize configurations across namespaces
* block non-conformant resources using admission controls, or report policy violations
* test policies and validate resources using the Kyverno CLI, in your CI/CD pipeline, before applying to your cluster
* manage `policies-as-code` using familiar tools like Git and Kustomize

Kyverno allows cluster administrators to manage environment specific configurations independently of workload configurations and enforce configuration best practices for their clusters. Kyverno can be used to scan existing workloads for best practices, or can be used to enforce best practices by blocking or mutating API requests.

## How Kyverno works

Kyverno runs as a [dynamic admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) in a Kubernetes cluster. Kyverno receives validating and mutating admission webhook HTTP callbacks from the kube-apiserver and applies matching policies to return results that enforce admission policies or reject requests.

Kyverno policies can match resources using the resource kind, name, and label selectors. Wildcards are supported in names.

Mutating policies can be written as overlays (similar to [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#bases-and-overlays)) or as a [RFC 6902 JSON Patch](http://jsonpatch.com/). Validating policies also use an overlay style syntax, with support for pattern matching and conditional (if-then-else) processing.

Policy enforcement is captured using Kubernetes events. Kyverno also reports policy violations for existing resources.

## Quick Start

This section will help you install Kyverno and create your first policy:

{{% alert title="Note" color="info" %}}
Your Kubernetes cluster version must be above v1.14 which adds webhook timeouts.
To check the version, enter `kubectl version`.
{{% /alert %}}

Install Kyverno:

```console
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
```

You can also install Kyverno using a Helm chart:

```sh
# Add the Helm repository
helm repo add kyverno https://kyverno.github.io/kyverno/

# Create a namespace
kubectl create ns kyverno

# Install the kyverno helm chart
helm install kyverno --namespace kyverno kyverno/kyverno
```

Add the policy below to your cluster. It contains a single validation rule that requires that all pods have a `app.kubernetes.io/name` label. Kyverno supports different rule types to validate, mutate, and generate configurations. The policy attribute `validationFailureAction` is set to `enforce` to block API requests that are non-compliant (using the default value `audit` will report violations but not block requests.)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: enforce
  rules:
  - name: check-for-labels
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "label `app.kubernetes.io/name` is required"
      pattern:
        metadata:
          labels:
            app.kubernetes.io/name: "?*"
```

Try creating a deployment without the required label:

```console
kubectl create deployment nginx --image=nginx
```

You should see an error:

```console
Error from server: admission webhook "nirmata.kyverno.resource.validating-webhook" denied the request:

resource Deployment/default/nginx was blocked due to the following policies

require-labels:
  autogen-check-for-labels: 'Validation error: label `app.kubernetes.io/name` is required;
    Validation rule autogen-check-for-labels failed at path /spec/template/metadata/labels/app.kubernetes.io/name/'
```

Create a pod with the required label. For example, using this command:

```sh
kubectl run nginx --image nginx --labels app.kubernetes.io/name=nginx
```

This pod configuration is compliant with the policy rules, and is not blocked.

Clean up by deleting all cluster policies:

```console
kubectl delete cpol --all
```
