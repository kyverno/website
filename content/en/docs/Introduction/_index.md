---
title: "Introduction"
linkTitle: "Introduction"
weight: 10
description: >
  Learn about Kyverno and create your first policy.
---

## About Kyverno

Kyverno (Greek for "govern") is a policy engine designed specifically for Kubernetes. Some of its many features include:

* policies as Kubernetes resources (no new language to learn!)
* validate, mutate, or generate any resource
* verify container images for software supply chain security
* inspect image metadata
* match resources using label selectors and wildcards
* validate and mutate using overlays (like Kustomize!)
* synchronize configurations across Namespaces
* block non-conformant resources using admission controls, or report policy violations
* test policies and validate resources using the Kyverno CLI, in your CI/CD pipeline, before applying to your cluster
* manage policies as code using familiar tools like `git` and `kustomize`

Kyverno allows cluster administrators to manage environment specific configurations independently of workload configurations and enforce configuration best practices for their clusters. Kyverno can be used to scan existing workloads for best practices, or can be used to enforce best practices by blocking or mutating API requests.

## How Kyverno works

Kyverno runs as a [dynamic admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) in a Kubernetes cluster. Kyverno receives validating and mutating admission webhook HTTP callbacks from the kube-apiserver and applies matching policies to return results that enforce admission policies or reject requests.

Kyverno policies can match resources using the resource kind, name, and label selectors. Wildcards are supported in names.

Mutating policies can be written as overlays (similar to [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#bases-and-overlays)) or as a [RFC 6902 JSON Patch](http://jsonpatch.com/). Validating policies also use an overlay style syntax, with support for pattern matching and conditional (if-then-else) processing.

Policy enforcement is captured using Kubernetes events. Kyverno also reports policy violations for existing resources.

The picture below shows the high-level architecture for Kyverno:

<img src="/images/kyverno-architecture.png" alt="Kyverno Architecture" width="80%"/>
<br/><br/>

An high availability installation of Kyverno can run multiple replicas, and each replica of Kyverno will have multiple controllers that perform different functions. The `Webhook` handles `AdmissionReview` requests from the Kubernetes API server, and its `Monitor` component creates and manages required configurations. The `PolicyController` watches policy resources and initiates background scans based on the configured scan interval. The `GenerateController` manages the lifecycle of generated resources.

## Quick Start

This section will help you install Kyverno and create your first policy.

{{% alert title="Note" color="info" %}}
Your Kubernetes cluster version must be above v1.14 which adds webhook timeouts. Check the [compatibility matrix](/docs/installation/#compatibility-matrix) to ensure your version of Kubernetes is supported.
To check the version, enter `kubectl version`.
{{% /alert %}}

You have the option of installing Kyverno directly from the latest release manifest or using Helm.

To install Kyverno using the latest release manifest (which may be a pre-release):

```sh
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/install.yaml
```

You can also install Kyverno using a Helm chart:

```sh
# Add the Helm repository
helm repo add kyverno https://kyverno.github.io/kyverno/

# Scan your Helm repositories to fetch the latest available charts.
helm repo update

# Install the Kyverno Helm chart into a new namespace called "kyverno"
helm install kyverno --namespace kyverno kyverno/kyverno --create-namespace
```

Add the policy below to your cluster. It contains a single validation rule that requires that all Pods have a `app.kubernetes.io/name` label. Kyverno supports different rule types to validate, mutate, generate, and verify image configurations. The policy attribute `validationFailureAction` is set to `enforce` to block API requests that are non-compliant (using the default value `audit` will report violations but not block requests.)

```yaml
kubectl create -f- << EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: enforce
  rules:
  - name: check-for-labels
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      message: "label 'app.kubernetes.io/name' is required"
      pattern:
        metadata:
          labels:
            app.kubernetes.io/name: "?*"
EOF
```

Try creating a Deployment without the required label:

```sh
kubectl create deployment nginx --image=nginx
```

You should see an error:

```sh
error: failed to create deployment: admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Deployment/default/nginx was blocked due to the following policies

require-labels:
  autogen-check-for-labels: 'validation error: label ''app.kubernetes.io/name'' is
    required. Rule autogen-check-for-labels failed at path /spec/template/metadata/labels/app.kubernetes.io/name/'
```

{{% alert title="Note" color="info" %}}
Kyverno may be configured to exclude system Namespaces like `kube-system` and `kyverno`. Make sure you create the Deployment in a user-defined Namespace or the `default` Namespace.
{{% /alert %}}

Although the ClusterPolicy matches on Pods, Kyverno intelligently applies this to all sources capable of generating Pods by default, including the Deployment above.

Create a Pod with the required label. For example, using this command:

```sh
kubectl run nginx --image nginx --labels app.kubernetes.io/name=nginx
```

This Pod configuration is compliant with the policy and is not blocked.

Congratulations, you've just implemented a policy in your Kubernetes cluster!

Clean up by deleting all cluster policies:

```sh
kubectl delete cpol --all
```
