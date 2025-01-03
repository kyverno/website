---
title: "Enforce Istio Sidecar Injection"
category: Istio
version: 1.6.0
subject: Namespace
policyType: "validate"
description: >
    In order for Istio to inject sidecars to workloads deployed into Namespaces, the label `istio-injection` must be set to `enabled`. This policy ensures that all new Namespaces set `istio-inject` to `enabled`.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//istio/enforce-sidecar-injection-namespace/enforce-sidecar-injection-namespace.yaml" target="-blank">/istio/enforce-sidecar-injection-namespace/enforce-sidecar-injection-namespace.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-sidecar-injection-namespace
  annotations:
    policies.kyverno.io/title: Enforce Istio Sidecar Injection
    policies.kyverno.io/category: Istio
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.8.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.24"
    policies.kyverno.io/subject: Namespace
    policies.kyverno.io/description: >-
      In order for Istio to inject sidecars to workloads deployed into Namespaces, the label
      `istio-injection` must be set to `enabled`. This policy ensures that all new Namespaces
      set `istio-inject` to `enabled`.
spec:
  validationFailureAction: Audit
  background: true
  rules:
  - name: check-istio-injection-enabled
    match:
      any:
      - resources:
          kinds:
          - Namespace
    validate:
      message: "All new Namespaces must have Istio sidecar injection enabled."
      pattern:
        metadata:
          labels:
            istio-injection: enabled

```
