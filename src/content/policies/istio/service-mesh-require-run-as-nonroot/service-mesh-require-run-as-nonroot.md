---
title: 'Service Mesh Require runAsNonRoot'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
tags: []
description: "This policy is a variation of the Require runAsNonRoot policy that is a part of the Pod Security Standards (Restricted) category. It enforces the same control but with provisions for Istio's initContainer. For more information and context, see the Kyverno blog post at https://kyverno.io/blog/2024/02/04/securing-services-meshes-easier-with-kyverno/."
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/istio/service-mesh-require-run-as-nonroot/service-mesh-require-run-as-nonroot.yaml" target="-blank">/istio/service-mesh-require-run-as-nonroot/service-mesh-require-run-as-nonroot.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: service-mesh-require-run-as-nonroot
  annotations:
    policies.kyverno.io/title: Service Mesh Require runAsNonRoot
    policies.kyverno.io/category: Istio, Pod Security Standards (Restricted)
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.12.3
    kyverno.io/kubernetes-version: '1.28'
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: This policy is a variation of the Require runAsNonRoot policy that is a part of the Pod Security Standards (Restricted) category. It enforces the same control but with provisions for Istio's initContainer. For more information and context, see the Kyverno blog post at https://kyverno.io/blog/2024/02/04/securing-services-meshes-easier-with-kyverno/.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: run-as-non-root-istio
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: 'Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`.          '
        anyPattern:
          - spec:
              securityContext:
                runAsNonRoot: true
              '=(ephemeralContainers)':
                - '=(securityContext)':
                    '=(runAsNonRoot)': true
              '=(initContainers)':
                - (image): '!*istio/proxyv2*'
                  '=(securityContext)':
                    '=(runAsNonRoot)': true
              containers:
                - '=(securityContext)':
                    '=(runAsNonRoot)': true
          - spec:
              '=(ephemeralContainers)':
                - securityContext:
                    runAsNonRoot: true
              '=(initContainers)':
                - (image): '!*istio/proxyv2*'
                  securityContext:
                    runAsNonRoot: true
              containers:
                - securityContext:
                    runAsNonRoot: true
```
