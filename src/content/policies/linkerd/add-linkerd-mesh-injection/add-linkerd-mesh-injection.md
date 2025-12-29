---
title: 'Add Linkerd Mesh Injection'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Namespace
  - Annotation
tags: []
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/linkerd/add-linkerd-mesh-injection/add-linkerd-mesh-injection.yaml" target="-blank">/linkerd/add-linkerd-mesh-injection/add-linkerd-mesh-injection.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-linkerd-mesh-injection
  annotations:
    policies.kyverno.io/title: Add Linkerd Mesh Injection
    policies.kyverno.io/category: Linkerd
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Namespace, Annotation
    policies.kyverno.io/description: Sidecar proxy injection in Linkerd may be handled at the Namespace level by setting the annotation `linkerd.io/inject` to `enabled`. In addition, a second annotation may be applied which controls the Pod startup behavior. This policy sets the annotations, if not present, `linkerd.io/inject` and `config.linkerd.io/proxy-await` to `enabled` on all new Namespaces.
spec:
  rules:
    - name: add-mesh-annotations
      match:
        any:
          - resources:
              kinds:
                - Namespace
      mutate:
        patchStrategicMerge:
          metadata:
            annotations:
              +(linkerd.io/inject): enabled
              +(config.linkerd.io/proxy-await): enabled
```
