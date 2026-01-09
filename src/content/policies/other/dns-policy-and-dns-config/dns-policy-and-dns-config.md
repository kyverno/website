---
title: 'Change DNS Config and Policy'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags:
  - Other
description: 'The Default DNS policy in Kubernetes gives the flexibility of service  access; however, it costs some latency on a high scale, and it needs to  be optimized. This policy helps us to optimize the performance of DNS  queries by setting DNS Options, nodelocalDNS IP, and search Domains. This policy can be applied for the clusters provisioned by kubeadm.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/dns-policy-and-dns-config/dns-policy-and-dns-config.yaml" target="-blank">/other/dns-policy-and-dns-config/dns-policy-and-dns-config.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: change-dns-config-policy
  annotations:
    policies.kyverno.io/title: Change DNS Config and Policy
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.8.1
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: The Default DNS policy in Kubernetes gives the flexibility of service  access; however, it costs some latency on a high scale, and it needs to  be optimized. This policy helps us to optimize the performance of DNS  queries by setting DNS Options, nodelocalDNS IP, and search Domains. This policy can be applied for the clusters provisioned by kubeadm.
spec:
  rules:
    - name: dns-policy
      context:
        - name: dictionary
          configMap:
            name: kubeadm-config
            namespace: kube-system
      match:
        any:
          - resources:
              kinds:
                - Pod
      preconditions:
        any:
          - key: "{{ request.object.spec.dnsPolicy || '' }}"
            operator: AnyIn
            value:
              - ClusterFirst
              - ClusterFirstWithHostNet
              - None
      mutate:
        patchStrategicMerge:
          spec:
            dnsConfig:
              nameservers:
                - 169.254.25.10
              options:
                - name: timeout
                  value: "1"
                - name: ndots
                  value: "2"
                - name: attempts
                  value: "1"
              searches:
                - svc.{{dictionary.data.ClusterConfiguration | parse_yaml(@).clusterName}}
                - "{{ request.namespace }}.svc.{{ dictionary.data.ClusterConfiguration | parse_yaml(@).clusterName }}"
            dnsPolicy: None

```
