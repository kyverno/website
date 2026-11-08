---
title: 'Disallow SELinux in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Pod Security Standards (Baseline) in ValidatingPolicy
version: 1.19.1
description: 'SELinux options can be used to escalate privileges and should not be allowed. This policy ensures that the `seLinuxOptions` field is undefined.'
createdAt: "2025-06-26T07:48:12.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-vpol/baseline/disallow-selinux/disallow-selinux.yaml" target="_blank" rel="noopener noreferrer">/pod-security-vpol/baseline/disallow-selinux/disallow-selinux.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-selinux
  annotations:
    policies.kyverno.io/title: Disallow SELinux in ValidatingPolicy
    policies.kyverno.io/category: Pod Security Standards (Baseline) in ValidatingPolicy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.19.1
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: 1.30+
    policies.kyverno.io/description: SELinux options can be used to escalate privileges and should not be allowed. This policy ensures that the `seLinuxOptions` field is undefined.
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
    - name: allContainerTypes
      expression: variables.podSpec.containers + variables.podSpec.?initContainers.orValue([]) + variables.podSpec.?ephemeralContainers.orValue([])
    - name: seLinuxTypes
      expression: "['container_t', 'container_init_t', 'container_kvm_t', 'container_engine_t']"
    - name: hasValidSELinuxType
      expression: variables.podSpec.?securityContext.?seLinuxOptions.?type.orValue('') == '' || variables.seLinuxTypes.exists(type, type == variables.podSpec.securityContext.seLinuxOptions.type)
    - name: hasValidSELinuxUserRole
      expression: variables.podSpec.?securityContext.?seLinuxOptions.?user.orValue('') == '' && variables.podSpec.?securityContext.?seLinuxOptions.?role.orValue('') == ''
  validations:
    - expression: |-
        variables.hasValidSELinuxType && variables.allContainerTypes.all(container,
          container.image in exceptions.allowedImages ||
          container.?securityContext.?seLinuxOptions.?type.orValue('') == '' ||
          variables.seLinuxTypes.exists(type, type == container.securityContext.seLinuxOptions.type) ||
          ('type:' + container.?securityContext.?seLinuxOptions.?type.orValue('')) in exceptions.allowedValues)
      message: Setting the SELinux type is restricted. The field securityContext.seLinuxOptions.type must be unset, empty, or set to one of the allowed values (container_t, container_init_t, container_kvm_t, or container_engine_t).
    - expression: |-
        variables.hasValidSELinuxUserRole && variables.allContainerTypes.all(container,
          container.image in exceptions.allowedImages ||
          (container.?securityContext.?seLinuxOptions.?user.orValue('') == '' ||
          ('user:' + container.?securityContext.?seLinuxOptions.?user.orValue('')) in exceptions.allowedValues) &&
          (container.?securityContext.?seLinuxOptions.?role.orValue('') == '' ||
          ('role:' + container.?securityContext.?seLinuxOptions.?role.orValue('')) in exceptions.allowedValues))
      message: Setting the SELinux user or role is forbidden. The fields seLinuxOptions.user and seLinuxOptions.role must be unset or empty.

```
