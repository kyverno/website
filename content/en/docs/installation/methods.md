---
title: Installation Methods
description: Methods for installing Kyverno
weight: 15
---

## Install Kyverno using Helm

The Helm chart is the recommended method of installing Kyverno in a production-grade, highly-available fashion as it provides all the necessary Kubernetes resources and configuration options to meet most production needs including platform-specific controls.

Kyverno can be deployed via a Helm chart--the recommended and preferred method for a production install--which is accessible either through the Kyverno repository or on [Artifact Hub](https://artifacthub.io/). Both generally available and pre-releases are available with Helm.

Choose one of the installation configuration options based upon your environment type and availability needs.
- For a production installation, see below [High Availability](#high-availability-installation) section.
- For a non-production installation, see below [Standalone Installation](#standalone-installation) section..

### Standalone Installation

To install Kyverno using Helm in a non-production environment use:

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```
### Optional: Configure Reports Server Usage
If you are using the [reports-server](https://github.com/kyverno/reports-server) as an alternative storage backend for policy reports, set `crds.reportsServer.enabled` to `true`. This configuration prevents the installation of CRDs that are served by the reports-server and disables related validation checks, avoiding conflicts with the kubernetes API server. 

To enable it with default settings:
```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set reportsServer.enabled=true
```
### High Availability Installation

Use Helm to create a Namespace and install Kyverno in a highly-available configuration.

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
--set admissionController.replicas=3 \
--set backgroundController.replicas=2 \
--set cleanupController.replicas=2 \
--set reportsController.replicas=2
```

Since Kyverno is comprised of different controllers where each is contained in separate Kubernetes Deployments, high availability is achieved on a per-controller basis. A default installation of Kyverno provides four separate Deployments each with a single replica. Configure high availability on the controllers where you need the additional availability. Be aware that multiple replicas do not necessarily equate to higher scale or performance across all controllers. Please see the [high availability page](../high-availability/_index.md) for more complete details.

The Helm chart offers parameters to configure multiple replicas for each controller. For example, a highly-available, complete deployment of Kyverno would consist of the following values.

```yaml
admissionController:
  replicas: 3
backgroundController:
  replicas: 3
cleanupController:
  replicas: 3
reportsController:
  replicas: 3
```

For all of the available values and their defaults, please see the Helm chart [README](https://github.com/kyverno/kyverno/tree/release-1.13/charts/kyverno). You should carefully inspect all available chart values and their defaults to determine what overrides, if any, are necessary to meet the particular needs of your production environment.

{{% alert title="Note" color="warning" %}}
All Kyverno installations require the admission controller be among the controllers deployed. For a highly-available installation, at least 2 or more replicas are required. Based on scalability requirements, and cluster topology, additional replicas can be configured for each controller.
{{% /alert %}}

By default, the Kyverno Namespace will be excluded using a namespaceSelector configured with the [immutable label](https://kubernetes.io/docs/concepts/overview/working-with-objects/_print/#automatic-labelling) `kubernetes.io/metadata.name`. Additional Namespaces may be excluded by configuring chart values. Both namespaceSelector and objectSelector may be used for exclusions.

See also the [Namespace selectors](customization.md#namespace-selectors) section and especially the [Security vs Operability](_index.md#security-vs-operability) section.

## Platform Specific Settings

When deploying Kyverno to certain Kubernetes platforms such as EKS, AKS, or OpenShift; or when using certain GitOps tools such as ArgoCD, additional configuration options may be needed or recommended. See the [Platform-Specific Notes](platform-notes.md) section for additional details.

### Pre-Release Installations (RC)

To install pre-release versions, such as `alpha`, `beta`, and `rc` (release candidates) versions, add the `--devel` switch to Helm:

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --devel
```

## Install Pod Security Policies via Helm

After Kyverno is installed, you may choose to also install the Kyverno [Pod Security Standard policies](../../pod-security.md), an optional chart containing the full set of Kyverno policies which implement the Kubernetes [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

```sh
helm install kyverno-policies kyverno/kyverno-policies -n kyverno
```

## Install Kyverno using YAMLs

Kyverno can also be installed using a single installation manifest, however for production installations the Helm chart is the preferred and recommended method.

Although Kyverno uses release branches, only YAML manifests from a tagged release are supported. Pull from a tagged release to install Kyverno using the YAML manifest.

```sh
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.11.1/install.yaml
```

### Testing unreleased code

In some cases, you may wish to trial yet unreleased Kyverno code in a quick way. Kyverno provides an experimental installation manifest for these purposes which reflects the current state of the codebase as it is known on the `main` development branch.

{{% alert title="Warning" color="warning" %}}
DO NOT use this manifest for anything other than testing or experimental purposes!
{{% /alert %}}

```sh
kubectl create -f https://github.com/kyverno/kyverno/raw/main/config/install-latest-testing.yaml
```
