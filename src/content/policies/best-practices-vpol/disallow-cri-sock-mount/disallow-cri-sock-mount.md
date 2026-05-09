---
title: 'Disallow CRI socket mounts in VPOL'
category: validate
severity: medium
type: ValidatingPolicy
subjects:
  - Pod
tags:
  - Best Practices
  - EKS Best Practices in VPOl
version: 1.14.0
description: 'Container daemon socket bind mounts allows access to the container engine on the node. This access can be used for privilege escalation and to manage containers outside of Kubernetes, and hence should not be allowed. This policy validates that the sockets used for CRI engines Docker, Containerd, and CRI-O are not used. In addition to or replacement of this policy, preventing users from mounting the parent directories (/var/run and /var) may be necessary to completely prevent socket bind mounts.'
createdAt: "2026-02-23T00:26:12.000Z"
---

## Policy Definition

<a href="https://github.com/kyverno/policies/raw/main/best-practices-vpol/disallow-cri-sock-mount/disallow-cri-sock-mount.yaml" target="-blank">/best-practices-vpol/disallow-cri-sock-mount/disallow-cri-sock-mount.yaml</a>

```yaml
apiVersion: policies.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: disallow-container-sock-mounts
  annotations:
    policies.kyverno.io/title: Disallow CRI socket mounts in VPOL
    policies.kyverno.io/category: Best Practices, EKS Best Practices in VPOl
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/minversion: 1.14.0
    kyverno.io/kubernetes-version: "1.30"
    policies.kyverno.io/description: Container daemon socket bind mounts allows access to the container engine on the node. This access can be used for privilege escalation and to manage containers outside of Kubernetes, and hence should not be allowed. This policy validates that the sockets used for CRI engines Docker, Containerd, and CRI-O are not used. In addition to or replacement of this policy, preventing users from mounting the parent directories (/var/run and /var) may be necessary to completely prevent socket bind mounts.
spec:
  validationActions:
    - Audit
  evaluation:
    background:
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
  variables:
    - name: hasVolumes
      expression: "!has(object.spec.volumes)"
    - name: volumes
      expression: object.spec.volumes
    - name: volumesWithHostPath
      expression: variables.volumes.filter(volume, has(volume.hostPath))
  validations:
    - expression: variables.hasVolumes ||  variables.volumesWithHostPath.all(volume, !volume.hostPath.path.matches('/var/run/docker.sock'))
      message: Use of the Docker Unix socket is not allowed.
    - expression: variables.hasVolumes ||  variables.volumesWithHostPath.all(volume, !volume.hostPath.path.matches('/var/run/containerd/containerd.sock'))
      message: Use of the Containerd Unix socket is not allowed.
    - expression: variables.hasVolumes ||  variables.volumesWithHostPath.all(volume, !volume.hostPath.path.matches('/var/run/crio/crio.sock'))
      message: Use of the CRI-O Unix socket is not allowed.
    - expression: variables.hasVolumes ||  variables.volumesWithHostPath.all(volume, !volume.hostPath.path.matches('/var/run/cri-dockerd.sock'))
      message: Use of the Docker CRI socket is not allowed.

```
