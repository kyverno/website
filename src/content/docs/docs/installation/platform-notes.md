---
title: Platform Notes
excerpt: Special considerations for certain Kubernetes platforms.
sidebar:
  order: 25
---

## Platform-Specific Notes

Depending on the application used to either install and manage Kyverno or the Kubernetes platform on which the cluster is built, there are some specific considerations of which to be aware. These notes are provided assuming the Helm chart is the installation artifact used.

### Notes for ArgoCD users

ArgoCD v2.10 introduced support for `ServerSideDiff`, leveraging Kubernetes' Server Side Apply feature to resolve OutOfSync issues. This strategy ensures comparisons are handled on the server side, respecting fields like `skipBackgroundRequests` that Kubernetes sets by default, and fields set by mutating admission controllers like Kyverno, thereby preventing unnecessary `OutOfSync` errors caused by local manifest discrepancies.

#### Configuration Best Practices

1. **Server-Side Configuration**
   - Enable `ServerSideDiff` in one of two ways:
     - Per Application: Add the `argocd.argoproj.io/compare-options` annotation
     - Globally: Configure it in the `argocd-cmd-params-cm` ConfigMap

   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     annotations:
       argocd.argoproj.io/compare-options: ServerSideDiff=true,IncludeMutationWebhook=true
       #...
   ```

2. **RBAC and CRD Management**
   - [Enable ServerSideApply](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#server-side-apply) in the `syncOptions` to handle metadata properly
   - Configure ArgoCD to [ignore differences in aggregated ClusterRoles](https://argo-cd.readthedocs.io/en/stable/user-guide/diffing/#ignoring-rbac-changes-made-by-aggregateroles)
   - Ensure proper RBAC permissions for ArgoCD to manage Kyverno CRDs

3. **Sync Options Configuration**
   - Avoid using `Replace=true` as it may cause issues with existing resources
   - Use `ServerSideApply=true` for smooth resource updates
   - Enable `CreateNamespace=true` if deploying to a new namespace

4. **Config Preservation**
   - By default, `config.preserve=true` is set in the Helm chart. This adds the `helm.sh/resource-policy: keep` annotation to the Kyverno ConfigMap so that it is kept when the Helm release is uninstalled.
   - Argo CD honors this annotation too, so deleting the Kyverno application leaves the ConfigMap behind.
   - **Recommendation:** Set `config.preserve=false` when deploying Kyverno via Argo CD so that the ConfigMap is removed together with the application.

#### Complete Application Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kyverno
  namespace: argocd
  annotations:
    argocd.argoproj.io/compare-options: ServerSideDiff=true,IncludeMutationWebhook=true
spec:
  destination:
    namespace: kyverno
    server: https://kubernetes.default.svc
  project: default
  source:
    chart: kyverno
    repoURL: https://kyverno.github.io/kyverno
    targetRevision: <my.target.version>
    helm:
      values: |
        config:
          preserve: false
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
```

#### Troubleshooting Guide

1. **CRD Check Failures**
   - **Symptom**: Deployment fails during CRD validation
   - **Common Causes**:
     - Insufficient RBAC permissions
     - CRDs not properly registered
   - **Resolution**:
     - Verify RBAC permissions for ArgoCD service account
     - Ensure CRDs are installed before policies
     - Check ArgoCD logs for specific permission errors

2. **Sync Failures**
   - **Symptom**: Resources show as OutOfSync
   - **Common Causes**:
     - Missing ServerSideDiff configuration
     - Aggregated ClusterRole differences
   - **Resolution**:
     - Enable ServerSideDiff as shown above
     - Configure resource exclusions for aggregated roles
     - Check resource health status in ArgoCD UI

3. **Resource Management Issues**
   - **Symptom**: Resources not properly created or updated
   - **Common Causes**:
     - Incorrect sync options
     - Resource ownership conflicts
   - **Resolution**:
     - Use ServerSideApply instead of Replace
     - Configure resource tracking method
     - Verify resource ownership labels

4. **Performance and Scaling**
   - **Symptom**: Slow syncs or resource processing
   - **Common Causes**:
     - Large number of resources
     - Resource intensive operations
   - **Resolution**:
     - Use selective sync for large deployments
     - Configure appropriate resource limits
     - Enable background processing where applicable

For considerations when using Argo CD along with Kyverno mutating policies, see [GitOps Considerations](/docs/policy-types/mutating-policy#argocd).

#### Resource Tracking and Ownership

Starting with Argo CD v3.0, Argo CD [tracks resources with an annotation by default](https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/2.14-3.0/#use-annotation-based-tracking-by-default). It records which application owns a resource in the `argocd.argoproj.io/tracking-id` annotation and no longer uses the `app.kubernetes.io/instance` label, so the label set by the Kyverno Helm chart does not get in the way. No extra configuration is needed.

Label-based tracking is the default in Argo CD v2 and can still be enabled in v3. With it, Argo CD uses the `app.kubernetes.io/instance` label to determine which resources form the app, and the Kyverno Helm chart also sets this label. To avoid this conflict, switch to annotation-based tracking in the `argocd-cm` ConfigMap, as described in the Argo CD [resource tracking documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/resource_tracking/):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  application.resourceTrackingMethod: annotation
```

If you need to keep label-based tracking, you can instead set `application.instanceLabelKey` in `argocd-cm` to a different label, such as `argocd.argoproj.io/instance`.

##### Webhook Configurations

Kyverno creates its webhook configurations at runtime, so they are not part of the rendered Helm chart. With annotation-based tracking, Argo CD does not track them: they are not shown in the Kyverno application, and Argo CD does not modify or prune them. You do not need to set `config.webhookLabels`.

With label-based tracking, you can show the webhook configurations in the Kyverno application by adding your tracking label to them with the `config.webhookLabels` Helm value, which sets the `webhookLabels` key in the [Kyverno ConfigMap](/docs/installation/customization#configmap-keys). Argo CD then treats them as extraneous resources, because they are not in the rendered chart. The application shows as `OutOfSync`, and with `prune: true` Argo CD deletes the webhook configurations on every sync, after which Kyverno recreates them. To prevent this, also add the [`IgnoreExtraneous`](https://argo-cd.readthedocs.io/en/stable/user-guide/compare-options/#ignoring-resources-that-are-extraneous) compare option and the [`Prune=false`](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#no-prune-resources) sync option with `config.webhookAnnotations`:

```yaml
config:
  webhookLabels:
    # <application.instanceLabelKey>: <Application name>
    argocd.argoproj.io/instance: kyverno
  webhookAnnotations:
    argocd.argoproj.io/compare-options: IgnoreExtraneous
    argocd.argoproj.io/sync-options: Prune=false
```

### Notes for OpenShift Users

Red Hat OpenShift contains a feature called [Security Context Constraints](https://docs.openshift.com/container-platform/4.11/authentication/managing-security-context-constraints.html) (SCC) which enforces certain security controls in a profile-driven manner. An OpenShift cluster contains several of these out of the box with OpenShift 4.11 preferring `restricted-v2` by default. The Kyverno Helm chart defines its own values for the Pod's `securityContext` object which, although it conforms to the upstream [Pod Security Standards' restricted profile](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted), may potentially be incompatible with your defined Security Context Constraints. Deploying the Kyverno Helm chart as-is on an OpenShift environment may result in an error similar to "unable to validate against any security context constraint". In order to get past this, deploy the Kyverno Helm chart with with the required securityContext flags/fields set to a value of `null`. OpenShift will apply the defined SCC upon deployment. If on OpenShift 4.11+, the `restricted-v2` profile is known to allow for successful deployment of the chart without modifying the Helm chart installation process.

### Notes for EKS Users

For EKS clusters built with the VPC CNI plug-in, if you wish to opt for the operability strategy as defined in the [Security vs Operability section](/docs/installation/installation#security-vs-operability), during the installation of Kyverno you should exclude the `kube-system` Namespace from webhooks as this is the Namespace where the plug-in runs. In situations where all the cluster Nodes are "deleted" (ex., only one node group in the cluster which is scaled to zero), which also impacts where the Kyverno replicas run, if `kube-system` is not excluded and where at least one policy in `Fail` mode matches on Pods, the VPC CNI plug-in's DaemonSet Pods may not be able to come online to finish the Node bootstrapping process. If this situation occurs, because the underlying cluster network cannot return to a healthy state, Kyverno will be unable to service webhook requests. As of Kyverno 1.12, `kube-system` is excluded by default in webhooks.

### Notes for AKS Users

AKS uses an Admission Enforcer control the webhooks in an AKS cluster and will remove those that may impact system Namespaces. Since Kyverno registers as a webhook, this Admission Enforcer may remove Kyverno's webhook causing the two to fight over webhook reconciliation. See [this Microsoft Azure FAQ](https://learn.microsoft.com/en-us/azure/aks/faq#can-admission-controller-webhooks-impact-kube-system-and-internal-aks-namespaces) for further information. When deploying Kyverno on an AKS cluster, set the Helm option `config.webhookAnnotations` to include the necessary annotation to disable the Admission Enforcer. Kyverno will configure its webhooks with this annotation to prevent their removal by AKS. The annotation that should be used is `"admissions.enforcer/disabled": true`. See the chart [README](https://github.com/kyverno/kyverno/blob/release-1.12/charts/kyverno/README.md) for more information. As of Kyverno 1.12, this annotation has already been set for you.

#### Cluster Stop/Start Operations

Azure AKS strictly inspects admission webhooks prior to cluster stop and start operations. If any admission webhook configuration has `failurePolicy: Fail` combined with wildcards (`*`) across both `apiGroups` and `resources`, AKS blocks the stop/start operation to prevent potential cluster bootstrap deadlocks during restart.

Kyverno includes a validating webhook named `protect-generation-labels.kyverno.svc` to prevent non-controller accounts from modifying Kyverno generation metadata (`generate.kyverno.io/policy-name`). Because this webhook targets universal wildcards with `failurePolicy: Fail` by default, stopping an AKS cluster running Kyverno Helm chart 3.9.2+ may fail with the following error:

```text
Failed to stop the Kubernetes service '<cluster_name>'. Error: The managed cluster has the following webhooks, that might prevent stop/start cluster operations, Please remove them before the operation. 1. Webhook configuration 'kyverno-resource-validating-webhook-cfg': 'protect-generation-labels.kyverno.svc' Rule 1 has wildcard in both APIGroups and Resources.
```

##### Workaround and Configuration

To unblock AKS cluster stop/start operations, disable the generation label protection webhook in your Helm values:

```yaml
features:
  protectGenerationLabels:
    enabled: false
```

Alternatively, pass the flag `--protectGenerationLabels=false` (or set environment variable `FLAG_PROTECT_GENERATION_LABELS=false`) to the Kyverno admission controller. When disabled, the webhook is automatically omitted and pruned from `kyverno-resource-validating-webhook-cfg` during reconciliation.

:::caution[Important]
Disabling `protectGenerationLabels` removes admission-time protection against unauthorized tampering with Kyverno's generation tracking labels. If this toggle is disabled temporarily to permit AKS cluster stop or start operations, remember to re-enable it post-maintenance (`features.protectGenerationLabels.enabled=true`) to restore protection.
:::

##### Verifying Webhook Registration

To confirm after cluster startup (or post-maintenance) that `protect-generation-labels.kyverno.svc` is registered again with `failurePolicy: Fail`:

```bash
kubectl get validatingwebhookconfigurations kyverno-resource-validating-webhook-cfg \
  -o jsonpath='{range .webhooks[?(@.name=="protect-generation-labels.kyverno.svc")]}{.name}{": failurePolicy="}{.failurePolicy}{"\n"}{end}'
```

- **Active (protected):** Returns `protect-generation-labels.kyverno.svc: failurePolicy=Fail`.
- **Disabled or pruned:** Returns empty output.

Alternatively, using `jq`:

```bash
kubectl get validatingwebhookconfigurations kyverno-resource-validating-webhook-cfg -o json \
  | jq -e '.webhooks[] | select(.name=="protect-generation-labels.kyverno.svc" and .failurePolicy=="Fail")' >/dev/null \
  || echo "protect-generation-labels is missing or not Fail" >&2
```
