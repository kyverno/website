---
title: 'Disallow Privileged Containers in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Pod Security Standards (Baseline) in ValidatingPolicy
version: 1.19.1
description: 'Privileged mode disables most security mechanisms and must not be allowed. This policy ensures Pods do not call for privileged mode.'
createdAt: "2025-06-26T07:48:12.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-vpol/baseline/disallow-privileged-containers/disallow-privileged-containers.yaml" target="-blank">/pod-security-vpol/baseline/disallow-privileged-containers/disallow-privileged-containers.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-privileged-containers
  annotations:
    policies.kyverno.io/title: Disallow Privileged Containers in ValidatingPolicy
    policies.kyverno.io/category: Pod Security Standards (Baseline) in ValidatingPolicy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.19.1
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: 1.30+
    policies.kyverno.io/description: Privileged mode disables most security mechanisms and must not be allowed. This policy ensures Pods do not call for privileged mode.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
          - replicationcontrollers
      - apiGroups:
          - apps
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - deployments
          - daemonsets
          - statefulsets
          - replicasets
      - apiGroups:
          - batch
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - jobs
          - cronjobs
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - UPDATE
        resources:
          - pods/ephemeralcontainers
  variables:
    - name: podSpec
      expression: object.spec.?jobTemplate.?spec.?template.?spec.orValue( object.spec.?template.?spec.orValue(object.spec))
    - name: allContainers
      expression: variables.podSpec.containers + variables.podSpec.?initContainers.orValue([]) + variables.podSpec.?ephemeralContainers.orValue([])
  validations:
    - expression: variables.allContainers.all(container, container.image in exceptions.allowedImages || container.?securityContext.?privileged.orValue(false) == false)
      message: Privileged mode is disallowed. All containers must set the securityContext.privileged field to `false` or unset the field.

```
