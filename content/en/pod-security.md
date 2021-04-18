+++
description = "Policies to secure Kubernetes Pods."
title = "Pod Security"
type = "policies"
url = "/policies/pod-security/"
+++

Policies based on [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). To apply all pod security policies (recommended) [install Kyverno](/docs/installation/) and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/), then run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

{{% alert title="Note" color="info" %}}
The upstream `kustomize` should be used to apply customizations in these policies, available [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/). In many cases the version of `kustomize` built-in to `kubectl` will not work.
{{% /alert %}}

Pod Security Standard policies are broken down into two groups, Baseline and Restricted. To locate and inspect policies individually in these groups, use the filter at the left.

## Baseline

Minimally restrictive policies to prevent known privilege escalations.

## Restricted

Heavily restricted policies following current Pod hardening best practices.
