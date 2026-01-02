---
title: 'Validate Team Namespace Schema'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - Namespace
tags:
  - OpenShift
version: 1.6.0
description: 'Naming patterns are commonplace in clusters where creation activities are granted to other users. In order to maintain organization, it is often such that patterns should be established for organizational consistency. This policy denies the creation of a Namespace if the name of the Namespace does not follow a specific naming defined by the cluster admins.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/openshift/team-validate-ns-name/team-validate-ns-name.yaml" target="-blank">/openshift/team-validate-ns-name/team-validate-ns-name.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: team-validate-ns-name
  annotations:
    policies.kyverno.io/title: Validate Team Namespace Schema
    policies.kyverno.io/category: OpenShift
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: '1.23'
    policies.kyverno.io/subject: Namespace
    policies.kyverno.io/description: Naming patterns are commonplace in clusters where creation activities are granted to other users. In order to maintain organization, it is often such that patterns should be established for organizational consistency. This policy denies the creation of a Namespace if the name of the Namespace does not follow a specific naming defined by the cluster admins.
spec:
  validationFailureAction: Audit
  background: false
  rules:
    - name: team-validate-ns-name
      match:
        any:
          - resources:
              kinds:
                - Namespace
                - ProjectRequest
                - Project
      validate:
        message: The only names approved for your Namespaces are the ones starting by {{request.userInfo.groups[?contains(@,':') == `false`]}}-*
        deny:
          conditions:
            any:
              - key: '{{request.object.metadata.name}}'
                operator: AnyNotIn
                value: "{{ request.userInfo.groups[?contains(@,':') == `false`][].join('-', [@, '*']) }}"
```
