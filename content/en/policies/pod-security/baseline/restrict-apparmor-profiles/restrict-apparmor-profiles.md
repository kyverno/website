---
title: "Restrict AppArmor"
category: Pod Security Standards (Baseline)
version: 1.3.0
subject: Pod, Annotation
policyType: "validate"
description: >
    On supported hosts, the 'runtime/default' AppArmor profile is applied by default. The default policy should prevent overriding or disabling the policy, or restrict overrides to an allowed set of profiles. This policy ensures Pods do not specify any other AppArmor profiles than `runtime/default` or `localhost/*`.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/release-1.6//pod-security/baseline/restrict-apparmor-profiles/restrict-apparmor-profiles.yaml" target="-blank">/pod-security/baseline/restrict-apparmor-profiles/restrict-apparmor-profiles.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-apparmor-profiles
  annotations:
    policies.kyverno.io/title: Restrict AppArmor
    policies.kyverno.io/category: Pod Security Standards (Baseline)
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod, Annotation
    policies.kyverno.io/minversion: 1.3.0
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    policies.kyverno.io/description: >-
      On supported hosts, the 'runtime/default' AppArmor profile is applied by default.
      The default policy should prevent overriding or disabling the policy, or restrict
      overrides to an allowed set of profiles. This policy ensures Pods do not
      specify any other AppArmor profiles than `runtime/default` or `localhost/*`.
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: app-armor
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: >-
          Specifying other AppArmor profiles is disallowed. The annotation
          `container.apparmor.security.beta.kubernetes.io` if defined
          must not be set to anything other than `runtime/default` or `localhost/*`.
        pattern:
          =(metadata):
            =(annotations):
              =(container.apparmor.security.beta.kubernetes.io/*): "runtime/default | localhost/*"

```
