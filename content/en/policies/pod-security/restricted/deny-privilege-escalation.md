---
type: "docs"
title: Deny Privilege Escalation
linkTitle: Deny Privilege Escalation
weight: 51
description: >
    Privilege escalation, such as via set-user-ID or set-group-ID file mode, should not be allowed.
---

## Category
Pod Security Standards (Restricted)

## Definition
[/pod-security/restricted/deny-privilege-escalation.yaml](https://github.com/kyverno/policies/raw/main//pod-security/restricted/deny-privilege-escalation.yaml)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: deny-privilege-escalation
  annotations:
    policies.kyverno.io/category: Pod Security Standards (Restricted)
    policies.kyverno.io/description: >-
      Privilege escalation, such as via set-user-ID or set-group-ID file mode, should not be allowed.
spec:
  background: true
  validationFailureAction: audit
  rules:
  - name: deny-privilege-escalation
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: >-
        Privilege escalation is disallowed. The fields
        spec.containers[*].securityContext.allowPrivilegeEscalation, and
        spec.initContainers[*].securityContext.allowPrivilegeEscalation must
        be undefined or set to `false`.
      pattern:
        spec:
          =(initContainers):
          - =(securityContext):
              =(allowPrivilegeEscalation): "false"
          containers:
          - =(securityContext):
              =(allowPrivilegeEscalation): "false"

```
