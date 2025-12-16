---
date: 2024-02-26
title: Generating Kubernetes ValidatingAdmissionPolicies from Kyverno Policies
linkTitle: Generating Kubernetes ValidatingAdmissionPolicies from Kyverno Policies
author: Mariam Fahmy
description: Generating Kubernetes ValidatingAdmissionPolicies from Kyverno Policies
category: General
---

In the [previous blog post](../using-cel-expressions-in-kyverno-policies/index.md), we discussed writing [Common Expression Language (CEL)](https://github.com/google/cel-spec) expressions in Kyverno policies for resource validation. CEL was first introduced to Kubernetes for the Validation rules for CustomResourceDefinitions, and then it was used by Kubernetes ValidatingAdmissionPolicies in 1.26.

ValidatingAdmissionPolicies offer a declarative, in-process alternative to validating admission webhooks.

ValidatingAdmissionPolicies use the Common Expression Language (CEL) to declare the validation rules of a policy. Validation admission policies are highly configurable, enabling policy authors to define policies that can be parameterized and scoped to resources as needed by cluster administrators.

This post will show you how to generate Kubernetes ValidatingAdmissionPolicies and their bindings from Kyverno policies.

## Prerequisite

Generating Kubernetes ValidatingAdmissionPolicies require the following:

1. A cluster with Kubernetes 1.26 or higher.
2. Enable the `ValidatingAdmissionPolicy` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/).
3. Enable the `admissionregistration.k8s.io/v1beta1` API for v1.28 and v1.29.
   OR
   Enable the `admissionregistration.k8s.io/v1alpha1` API for v1.26 and v1.27.
4. Set the `--generateValidatingAdmissionPolicy` flag in the Kyverno admission controller.
5. Grant the admission controller service account the required permissions to generate ValidatingAdmissionPolicies and their bindings.

In this post, we will use the beta version of Kubernetes 1.29.

## Installation & Setup

1. Create a local cluster

```bash
kind create cluster --image "kindest/node:v1.28.0" --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
  ValidatingAdmissionPolicy: true
runtimeConfig:
  admissionregistration.k8s.io/v1beta1: true
  admissionregistration.k8s.io/v1alpha1: true
nodes:
  - role: control-plane
  - role: worker
EOF
```

2. Add the Kyverno Helm repository.

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

3. Create a new file that overrides the values in the chart.

```bash
cat << EOF > new-values.yaml
features:
  generateValidatingAdmissionPolicy:
    enabled: true

admissionController:
  rbac:
    clusterRole:
      extraResources:
      - apiGroups:
          - admissionregistration.k8s.io
        resources:
          - validatingadmissionpolicies
          - validatingadmissionpolicybindings
        verbs:
          - create
          - update
          - delete
          - list
EOF
```

4. Deploy Kyverno

```bash
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --version v3.1.4 --values new-values.yaml
```

We are now ready to generate Kubernetes ValidatingAdmissionPolicies from Kyverno policies.

## Generating Kubernetes ValidatingAdmissionPolicies

In this section, we will create a Kyverno policy that ensures no hostPath volumes are in use for Deployments, and then we will have a look at the generated ValidatingAdmissionPolicy and its binding. Finally, we will create a Deployment that violates the policy.

Let’s start with creating the Kyverno policy.

```bash
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-path
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: host-path
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        cel:
          expressions:
            - expression: "!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))"
              message: "HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset."
EOF
```

You can check whether a ValidatingAdmissionPolicy is generated or not from the Kyverno policy status.

```bash
$ kubectl get cpol disallow-host-path -o jsonpath='{.status}'

{
   "autogen":{

   },
   "conditions":[
      {
         "lastTransitionTime":"2023-09-12T11:42:13Z",
         "message":"Ready",
         "reason":"Succeeded",
         "status":"True",
         "type":"Ready"
      }
   ],
   "ready":true,
   "rulecount":{
      "generate":0,
      "mutate":0,
      "validate":1,
      "verifyimages":0
   },
   "validatingadmissionpolicy":{
      "generated":true,
      "message":""
   }
}
```

Let’s try getting the ValidatingAdmissionPolicy and its binding.

```bash
$ kubectl get validatingadmissionpolicy
NAME                                 VALIDATIONS   PARAMKIND   AGE
disallow-host-path   1                        <unset>        8m12s

$ kubectl get validatingadmissionpolicybindings
NAME                                                   POLICYNAME                    PARAMREF   AGE
disallow-host-path-binding   disallow-host-path   <unset>      8m30s
```

You may notice that the ValidatingAdmissionPolicy and the ValidatingAdmissionPolicyBinding share the same name as the Kyverno policy they originate from, with the binding having a "-binding" suffix.

Let’s have a look at the ValidatingAdmissionPolicy and its binding in detail.

```bash
$ kubectl get validatingadmissionpolicy disallow-host-path -o yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicy
metadata:
  creationTimestamp: "2023-09-12T11:42:13Z"
  generation: 1
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path
  ownerReferences:
  - apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    name: disallow-host-path
    uid: e540d96b-c683-4380-a84f-13411384241a
  resourceVersion: "11294"
  uid: 9f3e0161-d010-4a6f-bd28-bf9c87151795
spec:
  failurePolicy: Fail
  matchConstraints:
    matchPolicy: Equivalent
    namespaceSelector: {}
    objectSelector: {}
    resourceRules:
    - apiGroups:
      - apps
      apiVersions:
      - v1
      operations:
      - CREATE
      - UPDATE
      resources:
      - deployments
      scope: '*'
  validations:
  - expression: '!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume,
      !has(volume.hostPath))'
    message: HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath
      must be unset.
  variables: null
status:
  observedGeneration: 1
  typeChecking: {}
```

```bash
$ kubectl get validatingadmissionpolicybindings disallow-host-path-binding -o yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicyBinding
metadata:
  creationTimestamp: "2023-09-12T11:42:13Z"
  generation: 1
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path-binding
  ownerReferences:
  - apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    name: disallow-host-path
    uid: e540d96b-c683-4380-a84f-13411384241a
  resourceVersion: "11292"
  uid: 2fec35c3-8a8c-42a7-8a02-a75e8882a01e
spec:
  policyName: disallow-host-path
  validationActions:
  - Deny
```

Now, let’s try deploying an app that uses a hostPath:

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
        volumeMounts:
          - name: udev
            mountPath: /data
      volumes:
      - name: udev
        hostPath:
          path: /etc/udev
EOF
```

As expected, the deployment creation is rejected by the API server and not by the Kyverno admission controller.

```bash
The deployments "nginx" is invalid:  ValidatingAdmissionPolicy 'disallow-host-path' with binding 'disallow-host-path-binding' denied request: HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset.
```

If either the ValidatingAdmissionPolicy or the binding is deleted/updated for some reason, the controller is responsible for reverting it.

Let’s try deleting the ValidatingAdmissionPolicy.

```bash
$ kubectl delete validatingadmissionpolicy disallow-host-path
validatingadmissionpolicy.admissionregistration.k8s.io "disallow-host-path" deleted

$ kubectl get validatingadmissionpolicy
NAME                                  VALIDATIONS   PARAMKIND   AGE
disallow-host-path    1                        <unset>        11s
```

In addition, you can update the Kyverno policy, and the controller will re-generate the ValidatingAdmissionPolicy accordingly. For example, you can change the Kyverno policy to match statefulsets too.

patch.yaml:

```yaml
spec:
  rules:
    - name: host-path
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - StatefulSet
      validate:
        cel:
          expressions:
            - expression: '!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))'
              message: 'HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset.'
```

```bash
kubectl patch cpol disallow-host-path --type merge --patch-file patch.yaml
```

The ValidatingAdmissionPolicy will be updated to match StatefulSets too.

```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicy
metadata:
  creationTimestamp: '2023-09-12T12:54:48Z'
  generation: 2
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path
  ownerReferences:
    - apiVersion: kyverno.io/v1
      kind: ClusterPolicy
      name: disallow-host-path
      uid: e540d96b-c683-4380-a84f-13411384241a
  resourceVersion: '29208'
  uid: 9325e2b7-9131-4ff4-9e56-244129cb625e
spec:
  failurePolicy: Fail
  matchConstraints:
    matchPolicy: Equivalent
    namespaceSelector: {}
    objectSelector: {}
    resourceRules:
      - apiGroups:
          - apps
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - deployments
          - statefulsets
        scope: '*'
  validations:
    - expression:
        '!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume,
        !has(volume.hostPath))'
      message:
        HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath
        must be unset.
  variables: null
status:
  observedGeneration: 2
  typeChecking: {}
```

## Conclusion

In this blog, we discussed how to generate Kubernetes ValidatingAdmissionPolicies from Kyverno policies. You can use CEL expressions in Kyverno policies to validate resources through either the Kyverno engine or the API server. In the next blog, we will discuss how to generate BackgroundScan reports for ValidatingAdmissionPolicies.
