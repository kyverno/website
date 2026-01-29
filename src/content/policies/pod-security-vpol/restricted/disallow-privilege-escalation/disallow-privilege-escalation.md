---
title: 'Disallow Privilege Escalation in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Pod Security Standards (Restricted) in ValidatingPolicy
version: 1.14.0
description: 'Privilege escalation, such as via set-user-ID or set-group-ID file mode, should not be allowed. This policy ensures the `allowPrivilegeEscalation` field is set to `false`.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/pod-security-vpol/restricted/disallow-privilege-escalation/disallow-privilege-escalation.yaml" target="-blank">/pod-security-vpol/restricted/disallow-privilege-escalation/disallow-privilege-escalation.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-privilege-escalation
  annotations:
    policies.kyverno.io/title: Disallow Privilege Escalation in ValidatingPolicy
    policies.kyverno.io/category: Pod Security Standards (Restricted) in ValidatingPolicy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: 1.30+
    policies.kyverno.io/description: Privilege escalation, such as via set-user-ID or set-group-ID file mode, should not be allowed. This policy ensures the `allowPrivilegeEscalation` field is set to `false`.
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
  variables:
    - name: allContainers
      expression: object.spec.containers +  object.spec.?initContainers.orValue([]) +  object.spec.?ephemeralContainers.orValue([])
  validations:
    - expression: variables.allContainers.all(container,  container.?securityContext.allowPrivilegeEscalation.orValue(true) == false)
      message: Privilege escalation is disallowed.  All containers must set the securityContext.allowPrivilegeEscalation field to `false`.

```
