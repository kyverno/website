---
title: "Restrict control plane scheduling"
category: Sample
policyType: "validate"
description: >
    This policy prevents users from setting a toleration in a Pod spec which allows running on control plane nodes with the taint key "node-role.kubernetes.io/master".   
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restrict_controlplane_scheduling.yaml" target="-blank">/other/restrict_controlplane_scheduling.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-controlplane-scheduling
  annotations:
    policies.kyverno.io/title: Restrict control plane scheduling
    policies.kyverno.io/category: Sample
    policies.kyverno.io/description: >-
      This policy prevents users from setting a toleration
      in a Pod spec which allows running on control plane nodes
      with the taint key "node-role.kubernetes.io/master".   
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: restrict-controlplane-scheduling
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: Pods may not use tolerations which schedule on control plane nodes.
      pattern:
        spec:
          =(tolerations):
            - X(key): "node-role.kubernetes.io/master"
```
