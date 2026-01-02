---
title: 'Disallow OpenShift Jenkins Pipeline Build Strategy in CEL expressions'
category: validate
severity: medium
type: ClusterPolicy
subjects:
  - BuildConfig
tags: []
version: 1.11.0
description: 'The Jenkins Pipeline Build Strategy has been deprecated. This policy prevents its use. Use OpenShift Pipelines instead.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/openshift-cel/disallow-jenkins-pipeline-strategy/disallow-jenkins-pipeline-strategy.yaml" target="-blank">/openshift-cel/disallow-jenkins-pipeline-strategy/disallow-jenkins-pipeline-strategy.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-jenkins-pipeline-strategy
  annotations:
    policies.kyverno.io/title: Disallow OpenShift Jenkins Pipeline Build Strategy in CEL expressions
    policies.kyverno.io/category: OpenShift in CEL
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.11.0
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kubernetes-version: 1.26-1.27
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
              operations:
                - CREATE
                - UPDATE
      validate:
        cel:
          expressions:
            - expression: '!has(object.spec.strategy.jenkinsPipelineStrategy)'
              message: Jenkins Pipeline Build Strategy has been deprecated and is not allowed
```
