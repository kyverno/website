---
title: "Restart Deployment On Secret Change"
category: other
version: 1.7.0
subject: Deployment
policyType: "mutate"
description: >
    If Secrets are mounted in ways which do not naturally allow updates to be live refreshed it may be necessary to modify a Deployment. This policy watches a Secret and if it changes will write an annotation to one or more target Deployments thus triggering a new rollout and thereby refreshing the referred Secret. It may be necessary to grant additional privileges to the Kyverno ServiceAccount, via one of the existing ClusterRoleBindings or a new one, so it can modify Deployments.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/restart_deployment_on_secret_change/restart_deployment_on_secret_change.yaml" target="-blank">/other/restart_deployment_on_secret_change/restart_deployment_on_secret_change.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restart-deployment-on-secret-change
  annotations:
    policies.kyverno.io/title: Restart Deployment On Secret Change
    policies.kyverno.io/category: other
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Deployment
    kyverno.io/kyverno-version: 1.7.0
    policies.kyverno.io/minversion: 1.7.0
    kyverno.io/kubernetes-version: "1.23"
    policies.kyverno.io/description: >-
      If Secrets are mounted in ways which do not naturally allow updates to
      be live refreshed it may be necessary to modify a Deployment. This policy
      watches a Secret and if it changes will write an annotation
      to one or more target Deployments thus triggering a new rollout and thereby
      refreshing the referred Secret. It may be necessary to grant additional privileges
      to the Kyverno ServiceAccount, via one of the existing ClusterRoleBindings or a new
      one, so it can modify Deployments.
spec:
  mutateExistingOnPolicyUpdate: false
  rules:
  - name: update-secret
    match:
      any:
      - resources:
          kinds:
          - Secret
          names:
          - mysecret
          namespaces:
          - default
    preconditions:
      all:
      - key: "{{request.operation || 'BACKGROUND'}}"
        operator: Equals
        value: UPDATE
    mutate:
      targets:
        - apiVersion: apps/v1
          kind: Deployment
          name: busybox
          namespace: default
      patchStrategicMerge:
        spec:
          template:
            metadata:
              annotations:
                ops.corp.com/triggerrestart: "{{request.object.metadata.resourceVersion}}"

```
