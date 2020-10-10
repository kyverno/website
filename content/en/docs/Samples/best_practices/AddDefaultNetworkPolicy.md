
---
title: "Default deny all ingress traffic"
linkTitle: "Default deny all ingress traffic"
weight: 1
description: >
---

By default, Kubernetes allows communications across all pods within a cluster. Network policies and, a CNI that supports network policies, must be used to restrict communinications. 

A default `NetworkPolicy` should be configured for each namespace to default deny all ingress traffic to the pods in the namespace. Application teams can then configure additional `NetworkPolicy` resources to allow desired traffic to application pods from select sources.

## Additional Information


## Policy YAML 

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-networkpolicy
spec:
  rules:
  - name: default-deny-ingress
    match:
      resources: 
        kinds:
        - Namespace
        name: "*"
    exclude:
      namespaces:
        - "kube-system"
        - "default"
        - "kube-public"
        - "kyverno"
    generate: 
      kind: NetworkPolicy
      name: default-deny-ingress
      namespace: "{{request.object.metadata.name}}"
      data:
        spec:
          # select all pods in the namespace
          podSelector: {}
          policyTypes: 
          - Ingress

````

## Install Policy

```bash
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/samples/best_practices/add_network_policy.yaml
```

## Test Policy

Create a pod with root user permission

```bash
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/test/resources/require_default_network_policy.yaml
```