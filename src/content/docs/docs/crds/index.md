---
title: Resource Definitions
sidebar:
  order: 120
excerpt: Custom Resource Definitions (CRDs) for Kyverno policies and supporting types.
---

Kyverno uses Kubernetes Custom Resource Definitions (CRDs) for [policies and supporting resources](/docs/policy-types/overview).

The complete [Kyverno CRD reference](https://htmlpreview.github.io/?https://github.com/kyverno/kyverno/blob/main/docs/user/crd/index.html) is generated from [API type definitions](https://github.com/kyverno/kyverno/tree/main/api). Use the documentation version selector when you need the schemas for an older release.

## kubectl explain

Inspect the schemas installed in your cluster using `kubectl explain`:

```sh
kubectl explain validatingpolicy.spec --api-version=policies.kyverno.io/v1
kubectl explain mutatingpolicy.spec --api-version=policies.kyverno.io/v1
kubectl explain generatingpolicy.spec --api-version=policies.kyverno.io/v1
kubectl explain deletingpolicy.spec --api-version=policies.kyverno.io/v1
kubectl explain imagevalidatingpolicy.spec --api-version=policies.kyverno.io/v1
kubectl explain policyexception.spec --api-version=policies.kyverno.io/v1
kubectl explain globalcontextentry.spec --api-version=kyverno.io/v2
```

To inspect an individual field, append its path, for example:

```sh
kubectl explain validatingpolicy.spec.validationActions --api-version=policies.kyverno.io/v1
```

Kyverno's structural schemas also enable integrated help in Kubernetes-enabled IDEs such as [VS Code](https://code.visualstudio.com/) with the [Kubernetes Extension](https://code.visualstudio.com/docs/azure/kubernetes#_install-the-kubernetes-extension).
