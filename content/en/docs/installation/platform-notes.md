---
title: Platform Notes
description: Special considerations for certain Kubernetes platforms.
weight: 25
---

## Platform-Specific Notes

Depending on the application used to either install and manage Kyverno or the Kubernetes platform on which the cluster is built, there are some specific considerations of which to be aware. These notes are provided assuming the Helm chart is the installation artifact used.

### Notes for ArgoCD users

ArgoCD v2.10 introduced support for `ServerSideDiff`, leveraging Kubernetes’ Server Side Apply feature to resolve OutOfSync issues. This strategy ensures comparisons are handled on the server side, respecting fields like `skipBackgroundRequests` that Kubernetes sets by default, and fields set by mutating admission controllers like Kyverno, thereby preventing unnecessary `OutOfSync` errors caused by local manifest discrepancies.

You can enable `ServerSideDiff` in two ways:  
* Per Application: Add the `argocd.argoproj.io/compare-options` annotation.
* Globally: Configure it in the `argocd-cmd-params-cm` ConfigMap.

Here is a YAML fragment that shows the annotation in an ArgoCD Application resource:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/compare-options: ServerSideDiff=true,IncludeMutationWebhook=true 

    ...

```

When deploying the Kyverno Helm chart with ArgoCD, it is recommended to use `ServerSideApply` in the `syncOptions`. This approach helps handle metadata issues that may arise when applying the chart.

Additionally, you may want to ignore differences in aggregated ClusterRoles, which Kyverno uses by default. Aggregated ClusterRoles are dynamic and built by combining other ClusterRoles in the cluster, leading to discrepancies between desired and observed states.

You can do so by following these instructions in the ArgoCD documentation:

* [Enable ServerSideApply](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#server-side-apply)
* [Ignore diff in aggregated cluster roles](https://argo-cd.readthedocs.io/en/stable/user-guide/diffing/#ignoring-rbac-changes-made-by-aggregateroles)

**Note:** You may want to avoid using `Replace=true` in the `syncOptions` as it can cause issues with existing resources. It is generally recommended to rely on `ServerSideApply` for handling resource updates smoothly.


Here’s an example of an ArgoCD Application manifest that should work with the Kyverno Helm chart:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kyverno
  namespace: argocd
spec:
  destination:
    namespace: kyverno
    server: https://kubernetes.default.svc
  project: default
  source:
    chart: kyverno
    repoURL: https://kyverno.github.io/kyverno
    targetRevision: <my.target.version>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true

```

For considerations when using Argo CD along with Kyverno mutate policies, see the documentation [here](/docs/policy_types/cluster_policy/mutate.md#argocd).

Argo CD users may also have Kyverno add labels to webhooks via the `webhookLabels` key in the [Kyverno ConfigMap](customization.md#configmap-keys), helpful when viewing the Kyverno application in Argo CD.

#### Ownership Clashes

ArgoCD automatically sets the `app.kubernetes.io/instance` label and uses it to determine which resources form the app. The Kyverno Helm chart also sets this label for the same purposes. In order to resolve this conflict, configure ArgoCD to use a different tracking mechanism as described in the ArgoCD [documentation](https://argo-cd.readthedocs.io/en/latest/user-guide/resource_tracking/#additional-tracking-methods-via-an-annotation).

### Notes for OpenShift Users

Red Hat OpenShift contains a feature called [Security Context Constraints](https://docs.openshift.com/container-platform/4.11/authentication/managing-security-context-constraints.html) (SCC) which enforces certain security controls in a profile-driven manner. An OpenShift cluster contains several of these out of the box with OpenShift 4.11 preferring `restricted-v2` by default. The Kyverno Helm chart defines its own values for the Pod's `securityContext` object which, although it conforms to the upstream [Pod Security Standards' restricted profile](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted), may potentially be incompatible with your defined Security Context Constraints. Deploying the Kyverno Helm chart as-is on an OpenShift environment may result in an error similar to "unable to validate against any security context constraint". In order to get past this, deploy the Kyverno Helm chart with with the required securityContext flags/fields set to a value of `null`. OpenShift will apply the defined SCC upon deployment. If on OpenShift 4.11+, the `restricted-v2` profile is known to allow for successful deployment of the chart without modifying the Helm chart installation process.

### Notes for EKS Users

For EKS clusters built with the VPC CNI plug-in, if you wish to opt for the operability strategy as defined in the [Security vs Operability section](_index.md#security-vs-operability), during the installation of Kyverno you should exclude the `kube-system` Namespace from webhooks as this is the Namespace where the plug-in runs. In situations where all the cluster Nodes are "deleted" (ex., only one node group in the cluster which is scaled to zero), which also impacts where the Kyverno replicas run, if `kube-system` is not excluded and where at least one policy in `Fail` mode matches on Pods, the VPC CNI plug-in's DaemonSet Pods may not be able to come online to finish the Node bootstrapping process. If this situation occurs, because the underlying cluster network cannot return to a healthy state, Kyverno will be unable to service webhook requests. As of Kyverno 1.12, `kube-system` is excluded by default in webhooks.

### Notes for AKS Users

AKS uses an Admission Enforcer control the webhooks in an AKS cluster and will remove those that may impact system Namespaces. Since Kyverno registers as a webhook, this Admission Enforcer may remove Kyverno's webhook causing the two to fight over webhook reconciliation. See [this Microsoft Azure FAQ](https://learn.microsoft.com/en-us/azure/aks/faq#can-admission-controller-webhooks-impact-kube-system-and-internal-aks-namespaces) for further information. When deploying Kyverno on an AKS cluster, set the Helm option `config.webhookAnnotations` to include the necessary annotation to disable the Admission Enforcer. Kyverno will configure its webhooks with this annotation to prevent their removal by AKS. The annotation that should be used is `"admissions.enforcer/disabled": true`. See the chart [README](https://github.com/kyverno/kyverno/blob/release-1.12/charts/kyverno/README.md) for more information. As of Kyverno 1.12, this annotation has already been set for you.
