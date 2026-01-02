---
title: 'Disallow OpenShift Jenkins Pipeline Build Strategy'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - BuildConfig
tags: []
version: 1.6.0
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/openshift/disallow-jenkins-pipeline-strategy/disallow-jenkins-pipeline-strategy.yaml" target="-blank">/openshift/disallow-jenkins-pipeline-strategy/disallow-jenkins-pipeline-strategy.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-jenkins-pipeline-strategy
  annotations:
    policies.kyverno.io/title: Disallow OpenShift Jenkins Pipeline Build Strategy
    policies.kyverno.io/category: OpenShift
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.20"
    policies.kyverno.io/subject: BuildConfig
    policies.kyverno.io/description: The Jenkins Pipeline Build Strategy has been deprecated. This policy prevents its use. Use OpenShift Pipelines instead.
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: check-build-strategy
      match:
        any:
          - resources:
              kinds:
                - v1/BuildConfig
                - build.openshift.io/v1/BuildConfig
      validate:
        message: Jenkins Pipeline Build Strategy has been deprecated and is not allowed
        deny:
          conditions:
            all:
              - key: "{{ keys(request.object.spec.strategy) | contains(@, 'jenkinsPipelineStrategy') }}"
                operator: Equals
                value: true

```
