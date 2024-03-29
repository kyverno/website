---
title: "Add scheduled Node's labels to a Pod"
category: Other
version: 1.10.0
subject: Pod
policyType: "mutate"
description: >
    Containers running in Pods may sometimes need access to node-specific information on  which the Pod has been scheduled. A common use case is node topology labels to ensure  pods are spread across failure zones in racks or in the cloud. The mutate-pod-binding policy already does this for annotations, but it does not handle labels. A useful use case is for passing metric label information to ServiceMonitors and then into Prometheus. This policy watches for Pod binding events when the pod is scheduled and then  asynchronously mutates the existing Pod to add the labels. This policy requires the following changes to common default configurations: - The kyverno resourceFilter should not filter Pod/binding resources. - The kyverno backgroundController service account requires Update permission on pods.  It is recommended to use https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles 
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//other/add-node-labels-pod/add-node-labels-pod.yaml" target="-blank">/other/add-node-labels-pod/add-node-labels-pod.yaml</a>

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: add-node-labels-pod
  annotations:
    pod-policies.kyverno.io/autogen-controllers: none
    policies.kyverno.io/title: Add scheduled Node's labels to a Pod
    policies.kyverno.io/category: Other
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.10.0
    policies.kyverno.io/minversion: 1.10.0
    kyverno.io/kubernetes-version: "1.26"
    policies.kyverno.io/description: >-
      Containers running in Pods may sometimes need access to node-specific information on 
      which the Pod has been scheduled. A common use case is node topology labels to ensure 
      pods are spread across failure zones in racks or in the cloud. The mutate-pod-binding
      policy already does this for annotations, but it does not handle labels. A useful use
      case is for passing metric label information to ServiceMonitors and then into Prometheus.
      This policy watches for Pod binding events when the pod is scheduled and then 
      asynchronously mutates the existing Pod to add the labels.
      This policy requires the following changes to common default configurations:
      - The kyverno resourceFilter should not filter Pod/binding resources.
      - The kyverno backgroundController service account requires Update permission on pods. 
      It is recommended to use https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles 
spec:
  rules:
    - name: project-foo
      match:
        any:
        - resources:
            kinds:
            - Pod/binding
      context:
      - name: node
        variable:
          jmesPath: request.object.target.name
          default: ''
      - name: foolabel
        apiCall:
          urlPath: "/api/v1/nodes/{{node}}"
          jmesPath: "metadata.labels.foo || 'empty'"
      mutate:
        targets:
        - apiVersion: v1
          kind: Pod
          name: "{{ request.object.metadata.name }}"
          namespace: "{{ request.object.metadata.namespace }}"
        patchStrategicMerge:
          metadata:
            labels: 
              foo: "{{ foolabel }}"

```
