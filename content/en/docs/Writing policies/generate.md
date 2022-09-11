---
title: Generate Resources
description: Create additional resources based on resource creation or updates. 
weight: 5
---

A `generate` rule can be used to create additional resources when a new resource is created or when the source is updated. This is useful to create supporting resources, such as new RoleBindings or NetworkPolicies for a Namespace.

The `generate` rule supports `match` and `exclude` blocks, like other rules. Hence, the trigger for applying this rule can be the creation of any resource. It is also possible to match or exclude API requests based on subjects, roles, etc.

The `generate` rule is triggered during the API CREATE operation. To keep resources synchronized across changes, you can use the `synchronize` property. When `synchronize` is set to `true`, the generated resource is kept in-sync with the source resource (which can be defined as part of the policy or may be an existing resource), and generated resources cannot be modified by users. If  `synchronize` is set to  `false` then users can update or delete the generated resource directly.

{{% alert title="Note" color="info" %}}
As of Kyverno 1.3.0, resources generated with `synchronize=true` may be modified or deleted by other Kubernetes controllers and users with appropriate access permissions, and Kyverno will recreate or update the resource to comply with configured policies.
{{% /alert %}}

When using a `generate` rule, the origin resource can be either an existing resource defined within Kubernetes, or a new resource defined in the rule itself. When the origin resource is a pre-existing resource such as a ConfigMap or Secret, for example, the `clone` object is used. When the origin resource is a new resource defined within the manifest of the rule, the `data` object is used. These are mutually exclusive, and only one may be specified in a rule.

{{% alert title="Caution" color="warning" %}}
Deleting the policy containing a `generate` rule with a `data` object and `synchronize=true` will cause immediate deletion of the downstream generated resources. Policies containing a `clone` object are not subject to this behavior.
{{% /alert %}}

Kubernetes has many default resource types even before considering CustomResources defined in CustomResourceDefinitions (CRDs). While Kyverno can generate these CustomResources as well, both these as well as certain default Kubernetes resources may require granting additional privileges to the ClusterRole responsible for the `generate` behavior. To enable Kyverno to generate these other types, see the section on [customizing permissions](/docs/installation/#customizing-permissions).

{{% alert title="Note" color="info" %}}
When generating a custom resource, it is necessary to set the apiVersion (ex., `spec.generate.apiVersion` and kind (ex., `spec.generate.kind`).
{{% /alert %}}

Kyverno will create an intermediate object called a `UpdateRequest` which is used to queue work items for the final resource generation. To get the details and status of a generated resource, check the details of the `UpdateRequest`. The following will give the list of `UpdateRequests`.

```sh
kubectl get updaterequests -A
```

A `UpdateRequest` status can have one of four values:

`Completed`: the `UpdateRequest` controller created resources defined in the policy
`Failed`: the `UpdateRequest` controller failed to process the rules
`Pending`: the request is yet to be processed or the resource has not been created
`Skip`: marked when triggering the generate policy by adding a label/annotation to the existing resource, while the selector is not defined in the policy itself.

## Generate a ConfigMap using inline data

This policy sets the Zookeeper and Kafka connection strings for all namespaces based upon a ConfigMap defined within the rule itself. Notice that this rule has the `generate.data` object defined in which case the rule will create a new ConfigMap called `zk-kafka-address` using the data specified in the rule's manifest.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: zk-kafka-address
spec:
  rules:
  - name: k-kafka-address
    match:
      any:
      - resources:
          kinds:
          - Namespace
    exclude:
      any:
      - resources:
          namespaces:
          - kube-system
          - default
          - kube-public
          - kyverno
    generate:
      synchronize: true
      apiVersion: v1
      kind: ConfigMap
      name: zk-kafka-address
      # generate the resource in the new namespace
      namespace: "{{request.object.metadata.name}}"
      data:
        kind: ConfigMap
        metadata:
          labels:
            somekey: somevalue
        data:
          ZK_ADDRESS: "192.168.10.10:2181,192.168.10.11:2181,192.168.10.12:2181"
          KAFKA_ADDRESS: "192.168.10.13:9092,192.168.10.14:9092,192.168.10.15:9092"
```

## Clone a ConfigMap and propagate changes

In this policy, the source of the data is an existing ConfigMap resource named `config-template` which is stored in the `default` Namespace. Notice how the `generate` rule here instead uses the `generate.clone` object when the origin data exists within Kubernetes.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: basic-policy
spec:
  rules:
  - name: Clone ConfigMap
    match:
      any:
      - resources:
          kinds:
          - Namespace
    exclude:
      any:
      - resources:
          namespaces:
          - kube-system
          - default
          - kube-public
          - kyverno
    generate:
      # Kind of generated resource
      kind: ConfigMap
      # apiVersion of the generated resource
      apiVersion: v1
      # Name of the generated resource
      name: default-config
      # namespace for the generated resource
      namespace: "{{request.object.metadata.name}}"
      # propagate changes from the upstream resource
      synchronize: true
      clone:
        namespace: default
        name: config-template
```

## Generating Bindings

In order for Kyverno to generate a new RoleBinding or ClusterRoleBinding resource, its ServiceAccount must first be bound to the same Role or ClusterRole which you're attempting to generate. If this is not done, Kubernetes blocks the request because it sees a possible privilege escalation attempt from the Kyverno ServiceAccount. This is not a Kyverno function but rather how Kubernetes RBAC is designed to work.

For example, if you wish to write a `generate` rule which creates a new RoleBinding resource granting some user the `admin` role over a new Namespace, the Kyverno ServiceAccount must have a ClusterRoleBinding in place for that same `admin` role.

Create a new ClusterRoleBinding for the Kyverno ServiceAccount by default called `kyverno`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kyverno:generate-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: ServiceAccount
  name: kyverno
  namespace: kyverno
```

Now, create a `generate` rule as you normally would which assigns a test user named `steven` to the `admin` ClusterRole for a new Namespace. The built-in ClusterRole named `admin` in this rule must match the ClusterRole granted to the Kyverno ServiceAccount in the previous ClusterRoleBinding.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: steven-rolebinding
spec:
  rules:
  - name: steven-rolebinding
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      kind: RoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      name: steven-rolebinding
      namespace: "{{request.object.metadata.name}}"
      data:  
        subjects:
        - kind: User
          name: steven
          apiGroup: rbac.authorization.k8s.io
        roleRef:
          kind: ClusterRole
          name: admin
          apiGroup: rbac.authorization.k8s.io
```

When a new Namespace is created, Kyverno will generate a new RoleBinding called `steven-rolebinding` which grants the user `steven` the `admin` ClusterRole over said new Namespace.

## Generate a NetworkPolicy

In this example, new namespaces will receive a NetworkPolicy that denies all inbound and outbound traffic. Similar to the first example, the `generate.data` object is used to define, as an overlay pattern, the `spec` for the NetworkPolicy resource.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: default
spec:
  rules:
  - name: deny-all-traffic
    match:
      any:
      - resources:
          kinds:
          - Namespace
    exclude:
      any:
      - resources:
          namespaces:
          - kube-system
          - default
          - kube-public
          - kyverno
    generate:
      kind: NetworkPolicy
      apiVersion: networking.k8s.io/v1
      name: deny-all-traffic
      namespace: "{{request.object.metadata.name}}"
      data:  
        spec:
          # select all pods in the namespace
          podSelector: {}
          policyTypes:
          - Ingress
          - Egress
```

## Linking resources with ownerReferences

In some cases, a triggering (source) resource and generated (downstream) resource need to share the same lifecycle. That is, when the triggering resource is deleted so too should the generated resource. This is valuable because some resources are only needed in the presence of another, for example a Service of type `LoadBalancer` necessitating the need for a specific network policy in some CNI plug-ins. While Kyverno will not take care of this task internally, Kubernetes can by setting the `ownerReferences` field in the generated resource. With the below example, when the generated ConfigMap specifies the `metadata.ownerReferences[]` object and defines the following fields including `uid`, which references the triggering Service resource, an owner-dependent relationship is formed. Later, if the Service is deleted, the ConfigMap will be as well. See the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/#owner-references-in-object-specifications) for more details including an important caveat around the scoping of these references. Specifically, Namespaced resources cannot be the owners of cluster-scoped resources, and cross-namespace references are also disallowed.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: demo-ownerref
spec:
  background: false
  rules:
  - name: demo-ownerref-svc-cm
    match:
      any:
      - resources:
          kinds:
          - Service
    generate:
      kind: ConfigMap
      apiVersion: v1
      name: "{{request.object.metadata.name}}-gen-cm"
      namespace: "{{request.namespace}}"
      synchronize: false
      data:
        metadata:
          ownerReferences:
          - apiVersion: v1
            kind: Service
            name: "{{request.object.metadata.name}}"
            uid: "{{request.object.metadata.uid}}"
        data:
          foo: bar
```

## Generate for Existing resources

With Kyverno 1.7.0+, Kyverno supports the generate for existing resources. Generate existing policies are applied in the background which creates target resources based on the match statement within the policy. They may also optionally be configured to apply upon updates to the policy itself.

### Generate NetworkPolicy in Existing Namespaces

By default, policy will not be applied on existing trigger resource when it is installed. This behavior can be configured via `generateExistingOnPolicyUpdate` attribute. Only if you set `generateExistingOnPolicyUpdate` to `true`, Kyverno will generate the target resource in existing triggers on policy CREATE and UPDATE events.

In this example policy, which triggers based on the resource kind `Namespace` a new NetworkPolicy will be generated in all new or existing Namespaces.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-resources
spec:
  generateExistingOnPolicyUpdate: true
  rules:
  - name: generate-existing-networkpolicy
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      kind: NetworkPolicy
      apiVersion: networking.k8s.io/v1
      name: default-deny
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      data:
        metadata:
          labels:
            created-by: kyverno
        spec:
          podSelector: {}
          policyTypes:
          - Ingress
          - Egress
```

### Generate PodDisruptionBudget for Existing Deployments

Similarly, this Cluster Policy will create a `PodDisruptionBudget` resource for existing or new deployments.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: create-default-pdb
spec:
  generateExistingOnPolicyUpdate: true
  rules:
  - name: create-default-pdb
    match:
      any:
      - resources:
          kinds:
          - Deployment
    exclude:
      resources:
        namespaces:
        - local-path-storage
    generate:
      apiVersion: policy/v1
      kind: PodDisruptionBudget
      name: "{{request.object.metadata.name}}-default-pdb"
      namespace: "{{request.object.metadata.namespace}}"
      synchronize: true
      data:
        spec:
          minAvailable: 1
          selector:
            matchLabels:
              "{{request.object.metadata.labels}}"
```

### Troubleshooting

To troubleshoot policy application failures, inspect the `UpdateRequest` Custom Resource to get details.

For example, if the corresponding permission is not granted to Kyverno, you should see this error in the `updaterequest.status`:

```sh
$ kubectl get ur -n kyverno
NAME       POLICY               RULETYPE   RESOURCEKIND   RESOURCENAME           RESOURCENAMESPACE   STATUS   AGE
ur-7gtbx   create-default-pdb   generate   Deployment     nginx-deployment       test                Failed   2s

$ kubectl describe ur ur-7gtbx -n kyverno
Name:         ur-7gtbx
Namespace:    kyverno
...

status:
  message: 'poddisruptionbudgets.policy is forbidden: User "system:serviceaccount:kyverno:kyverno-service-account"
            cannot create resource "poddisruptionbudgets" in API group "policy" in the namespace "test"'
 state: Failed
```

## Generating resources into existing namespaces

This feature has been deprecated in Kyverno 1.7.0+, refer to [this](#generate-for-existing-resources) section to generate for existing resources.

Use of a `generate` rule is common when creating net new resources from the point after which the policy was created. For example, a Kyverno `generate` policy is created so that all future namespaces can receive a standard set of Kubernetes resources. However, it is also possible to generate resources into **existing** resources, namely the Namespace construct. This can be extremely useful when deploying Kyverno to an existing cluster in use where you wish policy to apply retroactively.

Normally, Kyverno does not alter existing objects in any way as a central tenet of its design. However, using this method of controlled roll-out, you may use `generate` rules to create new objects into existing Namespaces. To do so, follow these steps:

1. Identify some Kubernetes label or annotation which is not yet defined on any Namespace but can be used to add to existing ones signaling to Kyverno that these Namespaces should be targets for `generate` rules. The metadata can be anything, but it should be descriptive for this purpose and not in use anywhere else nor use reserved keys such as `kubernetes.io` or `kyverno.io`.

2. Create a ClusterPolicy with a rule containing a `match` statement which matches on kind `Namespace` as well as the label or annotation you have set aside. In the `sync-secret` policy below, it matches on not only Namespaces but a label of `mycorp-rollout=true` and copies into these Namespaces a Secret called `corp-secret` stored in the `default` Namespace.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-secret
spec:
  rules:
  - name: sync-secret
    match:
      any:
      - resources:
          kinds:
          - Namespace
          selector:
            matchLabels:
              mycorp-rollout: "true"
    generate:
      kind: Secret
      apiVersion: v1
      name: corp-secret
      namespace: "{{request.object.metadata.name}}"
      synchronize : true
      clone:
        namespace: default
        name: corp-secret
```

3. Create the policy as usual.

4. On an existing Namespace where you wish to have the Secret `corp-secret` copied into it, label it with `mycorp-rollout=true`. This step must be completed after the ClusterPolicy exists. If it is labeled before, Kyverno will not see the request.

```sh
$ kubectl label ns prod-bus-app1 mycorp-rollout=true

namespace/prod-bus-app1 labeled
```

5. Check the Namespace you just labeled to see if the Secret exists.

```sh
$ kubectl -n prod-bus-app1 get secret

NAME                                               TYPE                                  DATA   AGE
corp-secret                                        Opaque                                2      10s
```

6. Repeat these steps as needed on any additional Namespaces where you wish this ClusterPolicy to apply its `generate` rule.

If you would like Kyverno to remove the resource it generated into these existing Namespaces, you may unlabel the Namespace.

```sh
$ kubectl label ns prod-bus-app1 mycorp-rollout-
```

The Secret from the previous example should be removed.
