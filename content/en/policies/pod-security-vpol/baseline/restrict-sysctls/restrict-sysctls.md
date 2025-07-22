---
title: "Restrict sysctls in ValidatingPolicy"
category: Pod Security Standards (Baseline) in ValidatingPolicy
version: 1.14.0
subject: Pod
policyType: "validate"
description: >
    Sysctls can disable security mechanisms or affect all containers on a host, and should be disallowed except for an allowed "safe" subset. A sysctl is considered safe if it is namespaced in the container or the Pod, and it is isolated from other Pods or processes on the same Node. This policy ensures that only those "safe" subsets can be specified in a Pod.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//pod-security-vpol/baseline/restrict-sysctls/restrict-sysctls.yaml" target="-blank">/pod-security-vpol/baseline/restrict-sysctls/restrict-sysctls.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: restrict-sysctls
  annotations:
    policies.kyverno.io/title: Restrict sysctls in ValidatingPolicy
    policies.kyverno.io/category: Pod Security Standards (Baseline) in ValidatingPolicy
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kyverno-version: 1.14.0
    kyverno.io/kubernetes-version: "1.30+"
    policies.kyverno.io/description: >-
      Sysctls can disable security mechanisms or affect all containers on a
      host, and should be disallowed except for an allowed "safe" subset. A
      sysctl is considered safe if it is namespaced in the container or the
      Pod, and it is isolated from other Pods or processes on the same Node.
      This policy ensures that only those "safe" subsets can be specified in
      a Pod.
spec:
  validationActions:
     - Audit
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:   [""]
        apiVersions: ["v1"]
        operations:  ["CREATE", "UPDATE"]
        resources:   ["pods"]
  variables:
    - name: allowedSysctls
      expression: "['kernel.shm_rmid_forced','net.ipv4.ip_local_port_range','net.ipv4.ip_unprivileged_port_start','net.ipv4.tcp_syncookies','net.ipv4.ping_group_range']"
  validations:
    - expression: >-
        object.spec.?securityContext.?sysctls.orValue([]).all(sysctl, 
          sysctl.?name.orValue('') in variables.allowedSysctls)
      message: >-
        Setting additional sysctls above the allowed type is disallowed.
        The field spec.securityContext.sysctls must be unset or not use any other names
        than kernel.shm_rmid_forced, net.ipv4.ip_local_port_range,
        net.ipv4.ip_unprivileged_port_start, net.ipv4.tcp_syncookies and
        net.ipv4.ping_group_range.
```
