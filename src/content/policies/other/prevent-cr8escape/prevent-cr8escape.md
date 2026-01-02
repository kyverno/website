---
title: 'Prevent cr8escape (CVE-2022-0811)'
category: validate
severity: high
type: ClusterPolicy
subjects:
  - Pod
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other/prevent-cr8escape/prevent-cr8escape.yaml" target="-blank">/other/prevent-cr8escape/prevent-cr8escape.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: prevent-cr8escape
  annotations:
    policies.kyverno.io/title: Prevent cr8escape (CVE-2022-0811)
    policies.kyverno.io/category: Other
    policies.kyverno.io/severity: high
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: A vulnerability "cr8escape" (CVE-2022-0811) in CRI-O the container runtime engine underpinning Kubernetes allows attackers to escape from a Kubernetes container and gain root access to the host. The recommended remediation is to disallow sysctl settings with + or = in their value.
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: restrict-sysctls-cr8escape
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        message: characters '+' or '=' are not allowed in sysctls values
        pattern:
          spec:
            "=(securityContext)":
              "=(sysctls)":
                - "=(value)": "!*+* & !*=*"

```
