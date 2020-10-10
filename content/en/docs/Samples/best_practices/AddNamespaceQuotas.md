
---
title: "Configure namespace limits and quotas"
linkTitle: "Configure namespace limits and quotas"
weight: 2
description: >
---

By default, Kubernetes allows communications across all pods within a cluster. Network policies and, a CNI that supports network policies, must be used to restrict communinications. 

A default `NetworkPolicy` should be configured for each namespace to default deny all ingress traffic to the pods in the namespace. Application teams can then configure additional `NetworkPolicy` resources to allow desired traffic to application pods from select sources.

## Additional Information
[Resource Quota](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

## Policy YAML 

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-ns-quota
spec:
  rules:
  - name: generate-resourcequota
    match:
      resources:
        kinds:
        - Namespace
    exclude:
      namespaces:
        - "kube-system"
        - "default"
        - "kube-public"
        - "kyverno"
    generate:
      kind: ResourceQuota
      name: default-resourcequota
      namespace: "{{request.object.metadata.name}}"
      data:
        spec:
          hard:
            requests.cpu: '4'
            requests.memory: '16Gi'
            limits.cpu: '4'
            limits.memory: '16Gi'
  - name: generate-limitrange
    match:
      resources:
        kinds:
        - Namespace
    generate:
      kind: LimitRange
      name: default-limitrange
      namespace: "{{request.object.metadata.name}}"
      data:
        spec:
          limits:
          - default:
              cpu: 500m
              memory: 1Gi
            defaultRequest:
              cpu: 200m
              memory: 256Mi
            type: Container
````

## Install Policy

```bash
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/samples/best_practices/add_ns_quota.yaml
```

## Test Policy

```bash
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/test/resources/require_namespace_quota.yaml
```