---
title: 'Require Linkerd Mesh Injection'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Namespace
  - Annotation
tags: []
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/linkerd/require-linkerd-mesh-injection/require-linkerd-mesh-injection.yaml" target="-blank">/linkerd/require-linkerd-mesh-injection/require-linkerd-mesh-injection.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-linkerd-mesh-injection
  annotations:
    policies.kyverno.io/title: Require Linkerd Mesh Injection
    policies.kyverno.io/category: Linkerd
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Namespace, Annotation
    policies.kyverno.io/description: Sidecar proxy injection in Linkerd may be handled at the Namespace level by setting the annotation `linkerd.io/inject` to `enabled`. This policy enforces that all Namespaces contain the annotation `linkerd.io/inject` set to `enabled`.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: require-mesh-annotation
      match:
        any:
          - resources:
              kinds:
                - Namespace
      validate:
        message: All Namespaces must set the annotation `linkerd.io/inject` to `enabled`.
        pattern:
          metadata:
            annotations:
              linkerd.io/inject: enabled

```
