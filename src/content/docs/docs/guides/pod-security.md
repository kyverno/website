---
excerpt: Pod Security Standards implemented as Kyverno policies.
title: Pod Security Standards
type: policies
url: /policies/pod-security/
---

Kubernetes Pod Security Standards provide guidelines and best practices to ensure that pods are deployed securely and follow the principle of least privilege. These standards are categorized into different levels—**Privileged**, **Baseline**, and **Restricted**—to help administrators choose the appropriate level of security for their workloads. You can learn more about these standards in the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

Kyverno supports policies for all controls defined in the Kubernetes Pod Security Standards.

## Installation

To apply all Pod Security Standard policies (recommended) [install Kyverno](/docs/installation/installation) and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/), then run:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

:::note[Note]
The upstream `kustomize` should be used to apply customizations in these policies, available [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/). In many cases the version of `kustomize` built-in to `kubectl` will not work.
:::

Installation is also available via [Helm](/docs/installation/installation#high-availability-installation) by using the chart `kyverno-policies`:

To install the Kyverno Pod Security Standards (PSS) policies via [Helm](https://helm.sh/), you can use the `kyverno/kyverno-policies` chart:

First, add the Kyverno Helm repository:

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

Then install the PSS policies chart:

```sh
helm install kyverno-pss kyverno/kyverno-policies \
  --namespace kyverno-policies --create-namespace \
  --set policyGroups=pod-security
```

This command will install all Pod Security policies into the `kyverno-policies` namespace.  
_You can adjust the namespace as needed for your environment._

For more options and advanced configuration, refer to the [Kyverno Policy Helm chart documentation](https://kyverno.github.io/kyverno/policy-repository/).

## PSP Migration

Kyverno has a number of policies which replicate the same PodSecurityPolicy (PSP) functionality designed to assist in migrating from PSP to Kyverno. See the PSP Migration policy category for these policies.

For a blog post covering a comparison of PodSecurityPolicy to Pod Security Admission and how to migrate from PSP to Kyverno, see [here](/blog/general/psp-migration/index.md).
