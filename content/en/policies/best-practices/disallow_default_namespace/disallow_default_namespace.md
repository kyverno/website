---
title: "Disallow Default Namespace"
category: Multi-Tenancy
version: 
subject: Pod
policyType: "validate"
description: >
    Kubernetes Namespaces are an optional feature that provide a way to segment and isolate cluster resources across multiple applications and users. As a best practice, workloads should be isolated with Namespaces. Namespaces should be required and the default (empty) Namespace should not be used. This policy validates that Pods specify a Namespace name other than `default`.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//best-practices/disallow_default_namespace/disallow_default_namespace.yaml" target="-blank">/best-practices/disallow_default_namespace/disallow_default_namespace.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-default-namespace
  annotations:
    pod-policies.kyverno.io/autogen-controllers: none
    policies.kyverno.io/title: Disallow Default Namespace
    policies.kyverno.io/category: Multi-Tenancy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Kubernetes Namespaces are an optional feature that provide a way to segment and
      isolate cluster resources across multiple applications and users. As a best
      practice, workloads should be isolated with Namespaces. Namespaces should be required
      and the default (empty) Namespace should not be used. This policy validates that Pods
      specify a Namespace name other than `default`.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: validate-namespace
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Using 'default' namespace is not allowed."
      pattern:
        metadata:
          namespace: "!default"
  - name: validate-podcontroller-namespace
    match:
      resources:
        kinds:
        - DaemonSet
        - Deployment
        - Job
        - StatefulSet
    validate:
      message: "Using 'default' namespace is not allowed for pod controllers."
      pattern:
        metadata:
          namespace: "!default"
```
