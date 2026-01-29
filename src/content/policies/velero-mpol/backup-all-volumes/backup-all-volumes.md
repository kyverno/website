---
title: 'Backup All Volumes'
category: mutate
severity: medium
type: MutatingPolicy
subjects:
  - Pod
  - Deployment
  - CronJob
  - Annotation
tags:
  - Velero
description: 'In order for Velero to backup volumes in a Pod using an opt-in approach, it requires an annotation on the Pod called `backup.velero.io/backup-volumes` with the value being a comma-separated list of the volumes mounted to that Pod. This policy automatically annotates Pods (and Pod controllers) which refer to a PVC so that all volumes are listed in the aforementioned annotation if a Namespace with the label `velero-backup-pvc=true`.'
isNew: true
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/velero-mpol/backup-all-volumes/backup-all-volumes.yaml" target="-blank">/velero-mpol/backup-all-volumes/backup-all-volumes.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: backup-all-volumes
  annotations:
    policies.kyverno.io/title: Backup All Volumes
    policies.kyverno.io/category: Velero
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod, Deployment, CronJob, Annotation
    policies.kyverno.io/description: In order for Velero to backup volumes in a Pod using an opt-in approach, it requires an annotation on the Pod called `backup.velero.io/backup-volumes` with the value being a comma-separated list of the volumes mounted to that Pod. This policy automatically annotates Pods (and Pod controllers) which refer to a PVC so that all volumes are listed in the aforementioned annotation if a Namespace with the label `velero-backup-pvc=true`.
spec:
  evaluation:
    admission:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups:
          - ""
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - pods
      - apiGroups:
          - apps
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - deployments
          - daemonsets
          - statefulsets
      - apiGroups:
          - batch
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - jobs
          - cronjobs
    namespaceSelector:
      matchLabels:
        velero-backup-pvc: "true"
  variables:
    - name: podPvcVolumes
      expression: "object.kind == \"Pod\" && has(object.spec.volumes) ?  object.spec.volumes.filter(v, has(v.persistentVolumeClaim)).map(v, v.name) :  []"
    - name: podVolumesList
      expression: "variables.podPvcVolumes.size() > 0 ? variables.podPvcVolumes.join(',') : ''"
    - name: deploymentPvcVolumes
      expression: "(object.kind == \"Deployment\" || object.kind == \"DaemonSet\" || object.kind == \"StatefulSet\") &&  has(object.spec.template.spec.volumes) ?  object.spec.template.spec.volumes.filter(v, has(v.persistentVolumeClaim)).map(v, v.name) :  []"
    - name: deploymentVolumesList
      expression: "variables.deploymentPvcVolumes.size() > 0 ? variables.deploymentPvcVolumes.join(',') : ''"
    - name: jobPvcVolumes
      expression: "object.kind == \"Job\" && has(object.spec.template.spec.volumes) ?  object.spec.template.spec.volumes.filter(v, has(v.persistentVolumeClaim)).map(v, v.name) :  []"
    - name: jobVolumesList
      expression: "variables.jobPvcVolumes.size() > 0 ? variables.jobPvcVolumes.join(',') : ''"
    - name: cronjobPvcVolumes
      expression: "object.kind == \"CronJob\" && has(object.spec.jobTemplate.spec.template.spec.volumes) ?  object.spec.jobTemplate.spec.template.spec.volumes.filter(v, has(v.persistentVolumeClaim)).map(v, v.name) :  []"
    - name: cronjobVolumesList
      expression: "variables.cronjobPvcVolumes.size() > 0 ? variables.cronjobPvcVolumes.join(',') : ''"
  mutations:
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "Pod" && variables.podVolumesList != '' ?
          (
            !has(object.metadata.annotations) ?
            [
              JSONPatch{
                op: "add",
                path: "/metadata/annotations",
                value: {"backup.velero.io/backup-volumes": variables.podVolumesList}
              }
            ] :
            [
              JSONPatch{
                op: "add",
                path: "/metadata/annotations/" + jsonpatch.escapeKey("backup.velero.io/backup-volumes"),
                value: variables.podVolumesList
              }
            ]
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          (object.kind == "Deployment" || object.kind == "DaemonSet" || object.kind == "StatefulSet") && 
          variables.deploymentVolumesList != '' ?
          (
            !has(object.spec.template.metadata.annotations) ?
            [
              JSONPatch{
                op: "add",
                path: "/spec/template/metadata/annotations",
                value: {"backup.velero.io/backup-volumes": variables.deploymentVolumesList}
              }
            ] :
            [
              JSONPatch{
                op: "add",
                path: "/spec/template/metadata/annotations/" + jsonpatch.escapeKey("backup.velero.io/backup-volumes"),
                value: variables.deploymentVolumesList
              }
            ]
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "Job" && variables.jobVolumesList != '' ?
          (
            !has(object.spec.template.metadata.annotations) ?
            [
              JSONPatch{
                op: "add",
                path: "/spec/template/metadata/annotations",
                value: {"backup.velero.io/backup-volumes": variables.jobVolumesList}
              }
            ] :
            [
              JSONPatch{
                op: "add",
                path: "/spec/template/metadata/annotations/" + jsonpatch.escapeKey("backup.velero.io/backup-volumes"),
                value: variables.jobVolumesList
              }
            ]
          ) : []
    - patchType: JSONPatch
      jsonPatch:
        expression: |
          object.kind == "CronJob" && variables.cronjobVolumesList != '' ?
          (
            !has(object.spec.jobTemplate.spec.template.metadata.annotations) ?
            [
              JSONPatch{
                op: "add",
                path: "/spec/jobTemplate/spec/template/metadata/annotations",
                value: {"backup.velero.io/backup-volumes": variables.cronjobVolumesList}
              }
            ] :
            [
              JSONPatch{
                op: "add",
                path: "/spec/jobTemplate/spec/template/metadata/annotations/" + jsonpatch.escapeKey("backup.velero.io/backup-volumes"),
                value: variables.cronjobVolumesList
              }
            ]
          ) : []

```
