---
title: "Add Network Policy"
linkTitle: "Add Network Policy"
weight: 1
repo: "https://github.com/kyverno/policies/blob/main/best-practices/add_network_policy.yaml"
description: >
    By default, Kubernetes allows communications across all pods within a cluster.  Network policies and, a CNI that supports network policies, must be used to restrict  communications. A default NetworkPolicy should be configured for each namespace to  default deny all ingress and egress traffic to the pods in the namespace. Application  teams can then configure additional NetworkPolicy resources to allow desired traffic  to application pods from select sources.
category: Multi-Tenancy
policyType: "generate"
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/add_network_policy.yaml" target="-blank">/best-practices/add_network_policy.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-networkpolicy
  annotations:
    policies.kyverno.io/title: Add Network Policy
    policies.kyverno.io/category: Multi-Tenancy
    policies.kyverno.io/description: >-
      By default, Kubernetes allows communications across all pods within a cluster. 
      Network policies and, a CNI that supports network policies, must be used to restrict 
      communications. A default NetworkPolicy should be configured for each namespace to 
      default deny all ingress and egress traffic to the pods in the namespace. Application 
      teams can then configure additional NetworkPolicy resources to allow desired traffic 
      to application pods from select sources.
spec:
  validationFailureAction: audit
  rules:
  - name: default-deny
    match:
      resources: 
        kinds:
        - Namespace
    generate:
      kind: NetworkPolicy
      name: default-deny
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      data:
        spec:
          # select all pods in the namespace
          podSelector: {}
          # deny all traffic
          policyTypes: 
          - Ingress
          - Egress
```
