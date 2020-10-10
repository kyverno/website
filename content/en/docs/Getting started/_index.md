---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 1
description: >
  What does your user need to know to try your project?
---

Kyverno is a policy engine built for Kubernetes:
* policies as Kubernetes resources (no new language to learn!)
* validate, mutate, or generate any resource
* match resources using label selectors and wildcards
* validate and mutate using overlays (like Kustomize!)
* generate and synchronize defaults across namespaces
* block or report violations 
* test using kubectl 

## Quick Start

**NOTE** : Your Kubernetes cluster version must be above v1.14 which adds webhook timeouts. 
To check the version, enter `kubectl version`.

Install Kyverno:
```console
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/master/definitions/release/install.yaml
```

You can also install Kyverno using a [Helm chart](#install-kyverno-using-helm).

Add the policy below. It contains a single validation rule that requires that all pods have 
a `app.kubernetes.io/name` label. Kyverno supports different rule types to validate, 
mutate, and generate configurations. The policy attribute `validationFailureAction` is set 
to `enforce` to block API requests that are non-compliant (using the default value `audit` 
will report violations but not block requests.)

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

Create a pod with the required label. For example from this YAML:
```yaml
kind: "Pod"
apiVersion: "v1"
metadata:
  name: nginx
  labels:
    app.kubernetes.io/name: nginx
spec:
  containers:
  - name: "nginx"
    image: "nginx:latest"
```

This pod configuration complies with the policy rules, and is not blocked. 

Clean up by deleting all cluster policies:

```console
kubectl delete cpol --all
```

As a next step, browse the [sample policies](https://github.com/kyverno/kyverno/blob/master/samples/README.md) 
and learn about [writing policies](https://kyverno.io/docs/writing-policies/). 
You can test policies using the [Kyverno cli](https://kyverno.io/docs/kyverno-cli/). 
See [docs](https://kyverno.io/docs) for complete details.