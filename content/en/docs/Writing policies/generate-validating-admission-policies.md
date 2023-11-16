---
title: Generate ValidatingAdmissionPolicies
description: >
  Generate Kubernetes ValidatingAdmissionPolicies based on `validate.cel` subrules.
weight: 50
---
While Kubernetes [ValidatingAdmissionPolicies](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/) provides a declarative, in-process option for validating admission webhooks and uses the [Common Expression Language](https://github.com/google/cel-spec) (CEL) to perform resource validation checks directly in the API server, it falls short of the features that can be provided by Kyverno policies. Kyverno policies are capable of performing complex validation, mutation, generation, image verification, reporting, and off-cluster validation, whereas ValidatingAdmissionPolicies cannot. Since it is important to unify the policy management used in clusters, Kyverno policies can be used to generate Kubernetes ValidatingAdmissionPolicies. This feature allows the process of resource validation to take place in the API server instead.

{{% alert title="Warning" color="warning" %}}
Generating Kubernetes ValidatingAdmissionPolicies requires setting certain [container flags](/docs/installation/customization/#container-flags) to enable.
{{% /alert %}}

To generate ValidatingAdmissionPolicies, make sure to:
1. enable `ValidatingAdmissionPolicy` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/).
2. enable either `admissionregistration.k8s.io/v1alpha1` or `admissionregistration.k8s.io/v1beta1` API.
3. grant the necessary permissions to the Kyverno admission controller’s ServiceAccount.

The `ValidatingAdmissionPolicies` can only be generated from the `validate.cel` subrules in Kyverno policies. Refer to the [CEL subrule](/docs/writing-policies/validate/#common-expression-language-cel) section on the validate page for more information.

Below is an example of a Kyverno policy that can be used to generate a `ValidatingAdmissionPolicy` and its binding:
```yaml
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
```
Once the policy is created, it is possible to check whether there is a corresponding `ValidatingAdmissionPolicy` was generated under the `status` object.
```yaml
status:
  validatingadmissionpolicy:
    generated: true
    message: ""
```

The generated ValidatingAdmissionPolicy:
```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicy
metadata:
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path
  ownerReferences:
  - apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    name: disallow-host-path
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
```

The generated ValidatingAdmissionPolicyBinding:
```yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingAdmissionPolicyBinding
metadata:
  labels:
    app.kubernetes.io/managed-by: kyverno
  name: disallow-host-path-binding
  ownerReferences:
  - apiVersion: kyverno.io/v1
    kind: ClusterPolicy
    name: disallow-host-path
spec:
  policyName: disallow-host-path
  validationActions:
  - Deny
```

Both the `ValidatingAdmissionPolicy` and its binding have the same naming convention as the Kyverno policy they originate from, with the binding having a "-binding" suffix.

If there is a request to create the following deployment given the generated `ValidatingAdmissionPolicy` above, it will be denied by the API server.
```yaml
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
```
The response returned from the API server.
```sh
The deployments "nginx" is invalid:  ValidatingAdmissionPolicy 'disallow-host-path' with binding 'disallow-host-path-binding' denied request: HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset.
```

{{% alert title="Warning" color="warning" %}}
Since Kubernetes ValidatingAdmissionPolicies are cluster-scoped resources, ClusterPolicies can only be used to generate them.
{{% /alert %}}

The generated `ValidatingAdmissionPolicy` with its binding is totally managed by the Kyverno admission controller which means deleting/modifying these generated resources will be reverted. Any updates to Kyverno policy triggers synchronization in the corresponding `ValidatingAdmissionPolicy`.
