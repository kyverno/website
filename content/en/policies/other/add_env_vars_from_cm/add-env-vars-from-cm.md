---
title: "Add Environment Variables from ConfigMap"
category: Other
version: 
subject: Pod
policyType: "mutate"
description: >
    Instead of defining a common set of environment variables multiple times either in manifests or separate policies, Pods can reference entire collections stored in a ConfigMap. This policy mutates all initContainers (if present) and containers in a Pod with environment variables defined in a ConfigMap named `nsenvvars` that must exist in the destination Namespace.     
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/release-1.6//other/add_env_vars_from_cm/add-env-vars-from-cm.yaml" target="-blank">/other/add_env_vars_from_cm/add-env-vars-from-cm.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-env-vars-from-cm
  annotations:
    policies.kyverno.io/title: Add Environment Variables from ConfigMap
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/category: Other
    policies.kyverno.io/description: >-
      Instead of defining a common set of environment variables multiple
      times either in manifests or separate policies, Pods can reference
      entire collections stored in a ConfigMap. This policy mutates all
      initContainers (if present) and containers in a Pod with environment
      variables defined in a ConfigMap named `nsenvvars` that must exist
      in the destination Namespace.     
spec:
  rules:
  - name: add-env-vars-from-cm
    match:
      resources:
        kinds:
        - Pod
    mutate:
      patchStrategicMerge:
        spec:
          initContainers:
            - (name): "*"
              envFrom:
              - configMapRef:
                  name: nsenvvars
          containers:
            - (name): "*"
              envFrom:
              - configMapRef:
                  name: nsenvvars

```
