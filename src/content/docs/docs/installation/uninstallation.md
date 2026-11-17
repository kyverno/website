---
title: Uninstalling Kyverno
excerpt: Uninstalling Kyverno.
sidebar:
  order: 65
---

## Uninstalling Kyverno

To uninstall Kyverno, use either the raw YAML manifest or Helm. The Kyverno Deployments and all supporting resources will be removed in addition to policy reports.

### Uninstall Kyverno with YAML

Use the tagged release manifest corresponding to the version you installed to fully uninstall Kyverno. Set `KYVERNO_VERSION` to that exact release tag (including the `v` prefix); the v1.20.0 installation example uses `v1.20.0`. After removal, verify that all webhooks have been removed as shown [below](#clean-up-webhooks).

```sh
KYVERNO_VERSION=v1.20.0
kubectl delete -f "https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/install.yaml"
```

### Uninstall Kyverno with Helm

Locate the Namespace and name of the release used to install Kyverno. Assuming you used default settings, the uninstallation command is shown below.

```sh
helm uninstall kyverno -n kyverno
```

### Clean up Webhooks

Kyverno by default will try to clean up all its webhooks when terminated for helm based installations. But in other cases where Kyverno's RBAC resources are removed first, it will lose the permission to do so properly. Kyverno supports deletion using finalizers to ensure resource deletion in right order. Use `--autoDeleteWebhooks` in admission-controller and cleanup-controller deployment to enable this feature, this feature will be enabled by default in future releases.

If manual webhook removal is necessary, use the below commands. The names shown are from the `v1.20.0` installation example; for another release, list the webhook configurations in your cluster and use the names created by that release.

```sh
kubectl delete mutatingwebhookconfigurations kyverno-policy-mutating-webhook-cfg kyverno-resource-mutating-webhook-cfg kyverno-verify-mutating-webhook-cfg

kubectl delete validatingwebhookconfigurations kyverno-cel-exception-validating-webhook-cfg kyverno-cleanup-validating-webhook-cfg kyverno-exception-validating-webhook-cfg kyverno-global-context-validating-webhook-cfg kyverno-policy-validating-webhook-cfg kyverno-resource-validating-webhook-cfg kyverno-ttl-validating-webhook-cfg
```
