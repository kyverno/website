---
title: API Server Blocked
description: >
  Learn how to resolve API server blockages due to Kyverno webhook timeouts and misconfigurations
weight: 10
---

**Symptom**: Kyverno Pods are not running and the API server is timing out due to webhook timeouts. My cluster appears "broken".

**Cause**: This can happen if all Kyverno Pods are down, due typically to a cluster outage or improper scaling/killing of full node groups, and policies were configure to [fail-closed](../writing-policies/policy-settings.md) while matching on Pods. This is usually only the case when the Kyverno Namespace has not been excluded (not the default behavior) or potentially system Namespaces which have cluster-critical components such as `kube-system`.

**Solution**: Delete the Kyverno validating and mutating webhook configurations. When Kyverno recovers, check your Namespace exclusions. Follow the steps below. Also consider running the admission controller component with 3 replicas.

1. Delete the validating and mutating webhook configurations that instruct the API server to forward requests to Kyverno:

```sh
kubectl delete validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg
kubectl delete  mutatingwebhookconfiguration kyverno-resource-mutating-webhook-cfg
```

Note that these two webhook configurations are used for resources. Other Kyverno webhooks are for internal operations and typically do not need to be deleted. When Kyverno recovers, its webhooks will be recreated based on the currently-installed policies.

2. Restart Kyverno

This step is typically not necessary. In case it is, either delete the Kyverno Pods or scale the Deployment down to zero and then up. For example, for an installation with three replicas in the default Namespace use:

```sh
kubectl scale deploy kyverno-admission-controller -n kyverno --replicas 0
kubectl scale deploy kyverno-admission-controller -n kyverno --replicas 3
```

3. Consider excluding namespaces

Use [Namespace selectors](../installation/customization.md#namespace-selectors) to filter requests to system Namespaces. Note that this configuration bypasses all policy checks on select Namespaces and may violate security best practices. When excluding Namespaces, it is your responsibility to ensure other controls such as Kubernetes RBAC are configured since Kyverno cannot apply any policies to objects therein. For more information, see the [Security vs Operability](../installation/_index.md#security-vs-operability) section. The Kyverno Namespace is excluded by default. And if running Kyverno on certain PaaS platforms, additional Namespaces may need to be excluded as well, for example `kube-system`.

