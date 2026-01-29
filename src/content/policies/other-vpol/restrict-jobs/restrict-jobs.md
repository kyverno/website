---
title: 'Restrict Jobs in ValidatingPolicy'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Job
tags:
  - Other in Vpol
description: 'Jobs can be created directly and indirectly via a CronJob controller. In some cases, users may want to only allow Jobs if they are created via a CronJob. This policy restricts Jobs so they may only be created by a CronJob.'
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/other-vpol/restrict-jobs/restrict-jobs.yaml" target="-blank">/other-vpol/restrict-jobs/restrict-jobs.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: restrict-jobs
  annotations:
    policies.kyverno.io/title: Restrict Jobs in ValidatingPolicy
    policies.kyverno.io/category: Other in Vpol
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Job
    kyverno.io/kyverno-version: 1.12.1
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: Jobs can be created directly and indirectly via a CronJob controller. In some cases, users may want to only allow Jobs if they are created via a CronJob. This policy restricts Jobs so they may only be created by a CronJob.
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups:
          - batch
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - jobs
  matchConditions:
    - name: not-created-by-cronjob
      expression: "!has(object.metadata.ownerReferences) || object.metadata.ownerReferences[0].kind != 'CronJob'"
  validations:
    - expression: "false"
      message: Jobs are only allowed if spawned from CronJobs.

```
