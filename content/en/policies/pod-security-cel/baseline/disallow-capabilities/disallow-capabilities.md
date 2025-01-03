---
title: "Disallow Capabilities in CEL expressions"
category: Pod Security Standards (Baseline) in CEL
version: 1.11.0
subject: Pod
policyType: "validate"
description: >
    Adding capabilities beyond those listed in the policy must be disallowed.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security-cel/baseline/disallow-capabilities/disallow-capabilities.yaml" target="-blank">/pod-security-cel/baseline/disallow-capabilities/disallow-capabilities.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-capabilities
  annotations:
    policies.kyverno.io/title: Disallow Capabilities in CEL expressions
    policies.kyverno.io/category: Pod Security Standards (Baseline) in CEL
    policies.kyverno.io/severity: medium
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: "1.26-1.27"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Adding capabilities beyond those listed in the policy must be disallowed.
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: adding-capabilities
      match:
        any:
        - resources:
            kinds:
              - Pod
            operations:
            - CREATE
            - UPDATE
      validate:
        cel:
          variables:
            - name: allowedCapabilities
              expression: "['AUDIT_WRITE','CHOWN','DAC_OVERRIDE','FOWNER','FSETID','KILL','MKNOD','NET_BIND_SERVICE','SETFCAP','SETGID','SETPCAP','SETUID','SYS_CHROOT']"
            - name: allContainers
              expression: "(object.spec.containers + (has(object.spec.initContainers) ? object.spec.initContainers : []) + (has(object.spec.ephemeralContainers) ? object.spec.ephemeralContainers : []))"
          expressions:
            - expression: >-
                variables.allContainers.all(container, 
                container.?securityContext.?capabilities.?add.orValue([]).all(capability, capability == '' ||
                capability in variables.allowedCapabilities))
              message: >-
                Any capabilities added beyond the allowed list (AUDIT_WRITE, CHOWN, DAC_OVERRIDE, FOWNER,
                FSETID, KILL, MKNOD, NET_BIND_SERVICE, SETFCAP, SETGID, SETPCAP, SETUID, SYS_CHROOT)
                are disallowed.

```
