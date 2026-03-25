---
title: 'Restrict Annotations in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Pod
  - Annotation
tags:
  - Sample in CEL
version: 1.11.0
description: 'Some annotations control functionality driven by other cluster-wide tools and are not normally set by some class of users. This policy prevents the use of an annotation beginning with `fluxcd.io/`. This can be useful to ensure users either don''t set reserved annotations or to force them to use a newer version of an annotation.'
createdAt: "2024-06-03T12:50:55.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-cel/restrict-annotations/restrict-annotations.yaml" target="-blank">/other-cel/restrict-annotations/restrict-annotations.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-annotations
  annotations:
    policies.kyverno.io/title: Restrict Annotations in CEL expressions
    policies.kyverno.io/category: Sample in CEL
    policies.kyverno.io/minversion: 1.11.0
    policies.kyverno.io/subject: Pod, Annotation
    kyverno.io/kubernetes-version: 1.26-1.27
    policies.kyverno.io/description: Some annotations control functionality driven by other cluster-wide tools and are not normally set by some class of users. This policy prevents the use of an annotation beginning with `fluxcd.io/`. This can be useful to ensure users either don't set reserved annotations or to force them to use a newer version of an annotation.
    pod-policies.kyverno.io/autogen-controllers: none
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: block-flux-v1
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - CronJob
                - Job
                - StatefulSet
                - DaemonSet
                - Pod
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: "!object.metadata.?annotations.orValue([]).exists(annotation, annotation.startsWith('fluxcd.io/'))"
              message: Cannot use Flux v1 annotation.

```
