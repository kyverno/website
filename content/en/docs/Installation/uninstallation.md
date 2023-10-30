---
title: Uninstalling Kyverno
description: Uninstalling Kyverno.
weight: 65
---

## Uninstalling Kyverno

To uninstall Kyverno, use either the raw YAML manifest or Helm. The Kyverno Deployments and all supporting resources will be removed in addition to policy reports.

### Uninstall Kyverno with YAML

Use the tagged release manifest corresponding to your version to fully uninstall Kyverno. After removal, verify that all webhooks have been removed as shown [below](#clean-up-webhooks).

```sh
kubectl delete -f https://github.com/kyverno/kyverno/releases/download/v1.10.0/install.yaml
```

### Uninstall Kyverno with Helm

Locate the Namespace and name of the release used to install Kyverno. Assuming you used default settings, the uninstallation command is shown below.

```sh
helm uninstall kyverno kyverno/kyverno -n kyverno
```

Note, you need to uninstall the kyverno-policies chart to avoid getting errors from the API-server.

```sh
helm uninstall kyverno-policies kyverno/kyverno-policies -n kyverno 
```

### Clean up Webhooks

Kyverno by default will try to clean up all its webhooks when terminated. But in cases where its RBAC resources are removed first, it will lose the permission to do so properly.

If manual webhook removal is necessary, use the below commands.

```sh
kubectl delete mutatingwebhookconfigurations kyverno-policy-mutating-webhook-cfg kyverno-resource-mutating-webhook-cfg kyverno-verify-mutating-webhook-cfg

kubectl delete validatingwebhookconfigurations kyverno-policy-validating-webhook-cfg kyverno-resource-validating-webhook-cfg kyverno-cleanup-validating-webhook-cfg kyverno-exception-validating-webhook-cfg
```
