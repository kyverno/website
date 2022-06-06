---
title: "Enforce etcd encryption in OpenShift"
category: OpenShift
version: 1.6.0
subject: APIServer
policyType: "validate"
description: >
    Encrption at rest is a security best practice. This policy ensures encryption is enabled for etcd in OpenShift clusters.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//openshift/enforce-etcd-encryption/enforce-etcd-encryption.yaml" target="-blank">/openshift/enforce-etcd-encryption/enforce-etcd-encryption.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enforce-etcd-encryption
  annotations:
    policies.kyverno.io/title: Enforce etcd encryption in OpenShift
    policies.kyverno.io/category: OpenShift
    policies.kyverno.io/severity: high
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.20"
    policies.kyverno.io/subject: APIServer
    policies.kyverno.io/description: >-
      Encrption at rest is a security best practice. This policy ensures encryption is enabled for etcd in OpenShift clusters.
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: check-etcd-encryption
    match:
      any:
      - resources:
          kinds:
          - config.openshift.io/v1/APIServer
    validate:
      message: >-
        Encryption should be enabled for etcd
      deny: 
        conditions:
          all:
          - key: "{{ keys(request.object.spec) | contains(@, 'encryption') }}"
            operator: NotEquals
            value: true

```
