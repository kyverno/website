---
title: 'Prevent cr8escape (CVE-2022-0811) in ValidatingPolicy'
category: validate
severity: high
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Other in Vpol
version: 1.14.0
description: 'A vulnerability "cr8escape" (CVE-2022-0811) in CRI-O the container runtime engine underpinning Kubernetes allows attackers to escape from a Kubernetes container and gain root access to the host. The recommended remediation is to disallow sysctl settings with + or = in their value.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/prevent-cr8escape/prevent-cr8escape.yaml" target="-blank">/other-vpol/prevent-cr8escape/prevent-cr8escape.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: prevent-cr8escape
  annotations:
    policies.kyverno.io/title: Prevent cr8escape (CVE-2022-0811) in ValidatingPolicy
    policies.kyverno.io/category: Other in Vpol
    policies.kyverno.io/severity: high
    kyverno.io/kyverno-version: 1.14.0
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: A vulnerability "cr8escape" (CVE-2022-0811) in CRI-O the container runtime engine underpinning Kubernetes allows attackers to escape from a Kubernetes container and gain root access to the host. The recommended remediation is to disallow sysctl settings with + or = in their value.
spec:
  validationActions:
    - Deny
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
  validations:
    - expression: "object.spec.?securityContext.?sysctls.orValue([]).all(sysctl,  !has(sysctl.value) || (!sysctl.value.contains('+') && !sysctl.value.contains('='))) "
      message: characters '+' or '=' are not allowed in sysctls values

```
