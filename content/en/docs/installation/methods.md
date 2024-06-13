---
title: Installation Methods
description: Methods for installing Kyverno
weight: 15
---

## Install Kyverno using Helm

Kyverno can be deployed via a Helm chart--the recommended and preferred method for a production install--which is accessible either through the Kyverno repository or on [Artifact Hub](https://artifacthub.io/). Both generally available and pre-releases are available with Helm.

In order to install Kyverno with Helm, first add the Kyverno Helm repository.

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
```

Scan the new repository for charts.

```sh
helm repo update
```

Optionally, show all available chart versions for Kyverno.

```sh
helm search repo kyverno -l
```

Choose one of the installation configuration options based upon your environment type and availability needs. For a production installation, see the [High Availability](#high-availability) section. For a non-production installation, see the [Standalone](#standalone) section below for additional details.

When deploying Kyverno to certain Kubernetes platforms such as EKS, AKS, or OpenShift; or when using certain GitOps tools such as ArgoCD, additional configuration options may be needed or recommended. See the [Platform-Specific Notes](platform-notes.md) section for additional details.

After Kyverno is installed, you may choose to also install the Kyverno [Pod Security Standard policies](../../pod-security.md), an optional chart containing the full set of Kyverno policies which implement the Kubernetes [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

```sh
helm install kyverno-policies kyverno/kyverno-policies -n kyverno
```

### High Availability

The Helm chart is the recommended method of installing Kyverno in a production-grade, highly-available fashion as it provides all the necessary Kubernetes resources and configuration options to meet most production needs including platform-specific controls.

Since Kyverno is comprised of different controllers where each is contained in separate Kubernetes Deployments, high availability is achieved on a per-controller basis. A default installation of Kyverno provides four separate Deployments each with a single replica. Configure high availability on the controllers where you need the additional availability. Be aware that multiple replicas do not necessarily equate to higher scale or performance across all controllers. Please see the [high availability page](../high-availability/_index.md) for more complete details.

The Helm chart offers parameters to configure multiple replicas for each controller. For example, a highly-available, complete deployment of Kyverno would consist of the following values.

```yaml
admissionController.replicas: 3
backgroundController.replicas: 2
cleanupController.replicas: 2
reportsController.replicas: 2
```

For all of the available values and their defaults, please see the Helm chart [README](https://github.com/kyverno/kyverno/tree/release-1.10/charts/kyverno). You should carefully inspect all available chart values and their defaults to determine what overrides, if any, are necessary to meet the particular needs of your production environment.

{{% alert title="Note" color="warning" %}}
All Kyverno installations require the admission controller be among the controllers deployed. For a highly-available installation, at least 2 or more replicas are required. Based on scalability requirements, and cluster topology, additional replicas can be configured for each controller.
{{% /alert %}}

By default, the Kyverno Namespace will be excluded using a namespaceSelector configured with the [immutable label](https://kubernetes.io/docs/concepts/overview/working-with-objects/_print/#automatic-labelling) `kubernetes.io/metadata.name`. Additional Namespaces may be excluded by configuring chart values. Both namespaceSelector and objectSelector may be used for exclusions.

See also the [Namespace selectors](customization.md#namespace-selectors) section and especially the [Security vs Operability](_index.md#security-vs-operability) section.

Use Helm to create a Namespace and install Kyverno in a highly-available configuration.

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
--set admissionController.replicas=3 \
--set backgroundController.replicas=2 \
--set cleanupController.replicas=2 \
--set reportsController.replicas=2
```

### Standalone

A standalone installation of Kyverno is suitable for lab, test/dev, or small environments typically associated with non-production. It configures a single replica for each Kyverno Deployment and omits many of the production-grade components.

Use Helm to create a Namespace and install Kyverno.

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

To install pre-releases, add the `--devel` switch to Helm.

```sh
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --devel
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
