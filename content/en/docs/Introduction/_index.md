---
title: "Introduction"
linkTitle: "Introduction"
weight: 10
description: >
  Learn about Kyverno and create your first policy through a Quick Start guide.
---

## About Kyverno

Kyverno (Greek for "govern") is a policy engine designed specifically for Kubernetes. Some of its many features include:

* policies as Kubernetes resources (no new language to learn!)
* validate, mutate, generate, or cleanup (remove) any resource
* verify container images for software supply chain security
* inspect image metadata
* match resources using label selectors and wildcards
* validate and mutate using overlays (like Kustomize!)
* synchronize configurations across Namespaces
* block non-conformant resources using admission controls, or report policy violations
* self-service reports (no proprietary audit log!)
* self-service policy exceptions
* test policies and validate resources using the Kyverno CLI, in your CI/CD pipeline, before applying to your cluster
* manage policies as code using familiar tools like `git` and `kustomize`

Kyverno allows cluster administrators to manage environment specific configurations independently of workload configurations and enforce configuration best practices for their clusters. Kyverno can be used to scan existing workloads for best practices, or can be used to enforce best practices by blocking or mutating API requests.

## How Kyverno works

Kyverno runs as a [dynamic admission controller](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) in a Kubernetes cluster. Kyverno receives validating and mutating admission webhook HTTP callbacks from the Kubernetes API server and applies matching policies to return results that enforce admission policies or reject requests.

Kyverno policies can match resources using the resource kind, name, label selectors, and much more.

Mutating policies can be written as overlays (similar to [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#bases-and-overlays)) or as a [RFC 6902 JSON Patch](http://jsonpatch.com/). Validating policies also use an overlay style syntax, with support for pattern matching and conditional (if-then-else) processing.

Policy enforcement is captured using Kubernetes events. For requests that are either allowed or existed prior to introduction of a Kyverno policy, Kyverno creates Policy Reports in the cluster which contain a running list of resources matched by a policy, their status, and more.

The diagram below shows the high-level logical architecture of Kyverno.

<img src="/images/kyverno-architecture.png" alt="Kyverno Architecture" width="80%"/>
<br/><br/>

The **Webhook** is the server which handles incoming AdmissionReview requests from the Kubernetes API server and sends them to the **Engine** for processing. It is dynamically configured by the **Webhook Controller** which watches the installed policies and modifies the webhooks to request only the resources matched by those policies. The **Cert Renewer** is responsible for watching and renewing the certificates, stored as Kubernetes Secrets, needed by the webhook. The **Background Controller** handles all generate and mutate-existing policies by reconciling UpdateRequests, an intermediary resource. And the **Report Controllers** handle creation and reconciliation of Policy Reports from their intermediary resources, Admission Reports and Background Scan Reports.

Kyverno also supports high availability. A highly-available installation of Kyverno is one in which the controllers selected for installation are configured to run with multiple replicas. Depending on the controller, the additional replicas may also serve the purpose of increasing the scalability of Kyverno. See the [high availability page](/docs/high-availability/) for more details on the various Kyverno controllers, their components, and how availability is handled in each one.

## Quick Start

This guide will help you get up and running quickly with Kyverno and demonstrate how a basic validation policy works. It is intended for proof-of-concept or lab installations only and not recommended as a guide for production. Please see the [installation page](/docs/installation/) for more complete information on how to install Kyverno in production.

First, install Kyverno from the latest release manifest.

```sh
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.10.0/install.yaml
```

Add the policy below to your cluster. It contains a single validation rule that requires that all Pods have the `app.kubernetes.io/name` label. Kyverno supports different rule types to validate, mutate, generate, cleanup, and verify image configurations. The policy attribute `validationFailureAction` is set to `Enforce` to block Pods that are non-compliant (using the default value `Audit` will report violations but not block requests.)

```yaml
kubectl create -f- << EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: Enforce
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

Try creating a Deployment without the required label.

```sh
kubectl create deployment nginx --image=nginx
```

You should see an error.

```sh
error: failed to create deployment: admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Deployment/default/nginx was blocked due to the following policies

require-labels:
  autogen-check-for-labels: 'validation error: label ''app.kubernetes.io/name'' is
    required. Rule autogen-check-for-labels failed at path /spec/template/metadata/labels/app.kubernetes.io/name/'
```

{{% alert title="Note" color="info" %}}
Kyverno may be configured to exclude system Namespaces like `kube-system` and `kyverno`. Make sure you create the Deployment in a user-defined Namespace or the `default` Namespace (for testing only).
{{% /alert %}}

Note that how although the policy matches on Pods, Kyverno blocked the Deployment you just created. This is because Kyverno intelligently applies policies written exclusively for Pods, like this sample policy, to all standard Kubernetes Pod controllers automatically, including the Deployment above.

Now, create a Pod with the required label.

```sh
kubectl run nginx --image nginx --labels app.kubernetes.io/name=nginx
```

This Pod configuration is compliant with the policy and is allowed.

Congratulations, you've just implemented a policy in your Kubernetes cluster!

Clean up by deleting all cluster policies:

```sh
kubectl delete cpol --all
```
