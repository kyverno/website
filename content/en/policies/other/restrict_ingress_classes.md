---
type: "docs"
title: Restrict Ingress Classes
linkTitle: Restrict Ingress Classes
weight: 25
description: >
    It can be useful to restrict Ingress resources to a set of known ingress classes that are allowed in the cluster. You can customize this policy to allow ingress classes that are configured in the cluster.
---

## Category
Workload Management

## Definition
[/other/restrict_ingress_classes.yaml](https://github.com/kyverno/policies/raw/main//other/restrict_ingress_classes.yaml)

```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-ingress-classes
  annotations:
    policies.kyverno.io/category: Workload Management
    policies.kyverno.io/description: It can be useful to restrict Ingress resources to a set of 
      known ingress classes that are allowed in the cluster. You can customize this policy to 
      allow ingress classes that are configured in the cluster.
spec:
  rules:
  - name: validate-ingress
    match:
      resources:
        kinds:
        - Ingress
    validate:
      message: "Unknown ingress class"
      pattern:
        metadata:
          annotations:
            kubernetes.io/ingress.class: "F5 | nginx"

```
