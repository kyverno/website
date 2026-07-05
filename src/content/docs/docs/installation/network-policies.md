---
title: NetworkPolicy Samples
excerpt: Sample NetworkPolicies to restrict traffic to and from Kyverno.
sidebar:
  order: 30
---

## Overview

The Kyverno [Helm chart](https://artifacthub.io/packages/helm/kyverno/kyverno) can enable ingress-only NetworkPolicies via `networkPolicy.enabled`, but does not configure egress. This page provides more complete manifests to apply alongside the chart.

See [Security § Networking](/docs/guides/security#networking) for the required flows and [Risk of not configuring a NetworkPolicy](/docs/guides/security#risk-of-not-configuring-a-networkpolicy) for the risks of running without one.

:::note[CNI enforcement]
NetworkPolicies are only enforced if your cluster's CNI plugin supports them. Verify support before relying on these manifests as a security control.
:::

## What each controller needs

The samples below assume Kyverno is installed in the `kyverno` namespace. Each controller uses these ports:

| Controller              | Webhook | Metrics |
| ----------------------- | ------- | ------- |
| `admission-controller`  | 9443    | 8000    |
| `cleanup-controller`    | 9443    | 8000    |
| `background-controller` | —       | 8000    |
| `reports-controller`    | —       | 8000    |

Egress requirements are shared across all four controllers:

- **Kubernetes API server** for list/watch and the [`apiCall` context variable](/docs/policy-types/cluster-policy/external-data-sources#variables-from-kubernetes-api-server-calls)
- **DNS**
- **OCI registries** for [image verification](/docs/policy-types/cluster-policy/verify-images/overview) and [image registry context variables](/docs/policy-types/cluster-policy/external-data-sources#variables-from-image-registries)
- **External HTTPS endpoints** for [external service calls](/docs/policy-types/cluster-policy/external-data-sources#variables-from-service-calls) and the [CEL HTTP library](/docs/policy-types/cel-libraries#http-library). If you use plain HTTP for either, add a port 80 rule to the egress policy below.

## Sample manifests

The samples use `app.kubernetes.io/instance: kyverno` and `app.kubernetes.io/part-of: kyverno`, matching the default Helm release name. For a different release name (e.g. `helm install my-kyverno ...`), replace both values in every manifest, including the egress policy.

### Ingress: admission and cleanup controllers

Port 9443 receives both the API server's webhook traffic and the kubelet's health probes. The API server's source IP depends on the CNI, and kubelet probes come from the node IP, so neither reliably matches pod or namespace selectors. The rule below allows any source on port 9443 to cover both; the `podSelector` on each policy already restricts the scope to the specific controller.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: kyverno-admission-controller
  namespace: kyverno
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/part-of: kyverno
      app.kubernetes.io/instance: kyverno
      app.kubernetes.io/component: admission-controller
  policyTypes:
    - Ingress
  ingress:
    - ports:
        - protocol: TCP
          port: 9443
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
      ports:
        - protocol: TCP
          port: 8000
```

Apply the same manifest for the cleanup controller: change `metadata.name` to `kyverno-cleanup-controller` and change `app.kubernetes.io/component` in `spec.podSelector.matchLabels` to `cleanup-controller`.

### Ingress: background and reports controllers

These controllers do not run a webhook, so only the metrics port needs ingress.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: kyverno-background-controller
  namespace: kyverno
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/part-of: kyverno
      app.kubernetes.io/instance: kyverno
      app.kubernetes.io/component: background-controller
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
      ports:
        - protocol: TCP
          port: 8000
```

Apply the same manifest for the reports controller: change `metadata.name` to `kyverno-reports-controller` and change `app.kubernetes.io/component` in `spec.podSelector.matchLabels` to `reports-controller`.

### Egress: all Kyverno controllers

One egress policy covers all four controllers. It allows DNS, the Kubernetes API server, and outbound HTTPS to public endpoints, and blocks the cloud metadata range (`169.254.0.0/16`) and RFC1918 private ranges (which typically include your cluster's own pod and service CIDRs).

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: kyverno-egress
  namespace: kyverno
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/part-of: kyverno
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
    - to:
        - ipBlock:
            cidr: 203.0.113.10/32
      ports:
        - protocol: TCP
          port: 443
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - 169.254.0.0/16
              - 10.0.0.0/8
              - 172.16.0.0/12
              - 192.168.0.0/16
      ports:
        - protocol: TCP
          port: 443
```

:::caution[Replace before applying]

- These samples use the same object names as the chart-generated NetworkPolicies. If you have `networkPolicy.enabled: true` in the chart, do not also apply the ingress samples on this page, or `kubectl apply` will conflict with the chart and the next `helm upgrade` will overwrite your changes.
- `203.0.113.10/32` is a documentation placeholder from the [RFC 5737](https://datatracker.ietf.org/doc/html/rfc5737) TEST-NET-3 range. Replace it with your API server endpoint or control-plane subnet CIDR. This rule is only necessary when the API server sits inside an RFC1918 range (typical for private EKS/GKE/AKS control planes); on clusters with a public API endpoint the `0.0.0.0/0` rule already covers it.
- `monitoring` is a placeholder for the namespace hosting Prometheus. Replace it with your metrics-scrape namespace.
- The DNS rule assumes `k8s-app: kube-dns` pods in `kube-system`. This matches kubeadm, GKE, EKS, and AKS. On OpenShift, replace the podSelector with `dns.operator.openshift.io/daemonset-dns: default` and the namespaceSelector with `kubernetes.io/metadata.name: openshift-dns`.
- The `0.0.0.0/0` block excludes RFC1918 by default (per [defense-in-depth guidance in `security.md`](/docs/guides/security#networking)). RFC1918 typically covers your pod and service CIDRs. Add an explicit allow rule above it for in-cluster destinations such as a mirror registry or an [external service call](/docs/policy-types/cluster-policy/external-data-sources#variables-from-service-calls).
  :::

## Verification

Confirm the policies are applied and that admission still works. `--dry-run=server` exercises the full admission path without scheduling a pod, so it does not depend on PodSecurity or other cluster-level admission plugins:

```sh
kubectl get networkpolicy -n kyverno
kubectl run netpol-test --image=nginx --restart=Never --namespace=default --dry-run=server
```

If the dry run fails with a webhook error (`failed calling webhook ... connection refused` or a timeout), the webhook ingress rule or the API server egress rule is likely mismatched. Check your CNI logs for policy-drop events, and verify the API server CIDR placeholder was replaced.

## Using the Helm chart

The Helm chart can generate the four ingress policies via `networkPolicy.enabled` per controller (see [chart `values.yaml`](https://github.com/kyverno/kyverno/blob/main/charts/kyverno/values.yaml)). The chart does not emit egress rules, so apply the `kyverno-egress` policy above alongside the chart and skip the ingress samples on this page to avoid the conflict noted in the caution above.
