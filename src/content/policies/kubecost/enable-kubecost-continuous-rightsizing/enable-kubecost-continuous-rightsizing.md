---
title: 'Enable Kubecost Continuous Rightsizing'
category: mutate
severity: medium
type: ClusterPolicy
subjects:
  - Deployment
  - Annotation
tags:
  - Kubecost
description: 'Kubecost is able to modify container resource requests and limits dynamically based upon observed utilization patterns and recommendations. This provides an easy way to automatically improve allocation of cluster resources by increasing efficiency. This policy will annotate all Deployments which have the label `env=test` with `request.autoscaling.kubecost.com/enabled="true"` if the annotation is not already present. Other annotations may be added according to need and users should see the documentation for a complete list.'
createdAt: "2023-05-07T14:18:26.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/kubecost/enable-kubecost-continuous-rightsizing/enable-kubecost-continuous-rightsizing.yaml" target="-blank">/kubecost/enable-kubecost-continuous-rightsizing/enable-kubecost-continuous-rightsizing.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: enable-kubecost-continuous-rightsizing
  annotations:
    policies.kyverno.io/title: Enable Kubecost Continuous Rightsizing
    policies.kyverno.io/category: Kubecost
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Deployment, Annotation
    kyverno.io/kyverno-version: 1.10.0
    kyverno.io/kubernetes-version: "1.25"
    policies.kyverno.io/description: Kubecost is able to modify container resource requests and limits dynamically based upon observed utilization patterns and recommendations. This provides an easy way to automatically improve allocation of cluster resources by increasing efficiency. This policy will annotate all Deployments which have the label `env=test` with `request.autoscaling.kubecost.com/enabled="true"` if the annotation is not already present. Other annotations may be added according to need and users should see the documentation for a complete list.
spec:
  rules:
    - name: enable-kubecost-autoscaling
      match:
        any:
          - resources:
              kinds:
                - Deployment
              selector:
                matchLabels:
                  env: test
      mutate:
        patchStrategicMerge:
          metadata:
            annotations:
              +(request.autoscaling.kubecost.com/enabled): "true"

```
