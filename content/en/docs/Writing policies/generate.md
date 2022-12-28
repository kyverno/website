---
title: Generate Resources
description: Create additional resources based on resource creation or updates. 
weight: 60
---

A `generate` rule can be used to create additional resources when a new resource is created or when the source is updated. This is useful to create supporting resources, such as new RoleBindings or NetworkPolicies for a Namespace.

The `generate` rule supports `match` and `exclude` blocks, like other rules. Hence, the trigger for applying this rule can be the creation of any resource. It is also possible to match or exclude API requests based on subjects, roles, etc.

The `generate` rule is triggered during the API CREATE operation. To keep resources synchronized across changes, you can use the `synchronize` property. When `synchronize` is set to `true`, the generated resource is kept in-sync with the source resource (which can be defined as part of the policy or may be an existing resource), and generated resources cannot be modified by users. If  `synchronize` is set to  `false` then users can update or delete the generated resource directly.

When using a `generate` rule, the origin resource can be either an existing resource in the cluster, or a new resource defined in the rule itself. When the origin resource is a pre-existing resource such as a ConfigMap or Secret, for example, the `clone` object is used. See the [Clone Source](#clone-source) section for more details. When the origin resource is a new resource defined within the manifest of the rule, the `data` object is used. See the [Data Source](#clone-source) section for more details. These are mutually exclusive and only one may be specified per rule.

{{% alert title="Caution" color="warning" %}}
Deleting the policy containing a `generate` rule with a `data` object and `synchronize=true` will cause immediate deletion of the downstream generated resources. Policies containing a `clone` object are not subject to this behavior.
{{% /alert %}}

Kubernetes has many default resource types even before considering CustomResources defined in CustomResourceDefinitions (CRDs). While Kyverno can generate these CustomResources as well, both these as well as certain default Kubernetes resources may require granting additional privileges to the ClusterRole responsible for the `generate` behavior. To enable Kyverno to generate these other types, see the section on [customizing permissions](/docs/installation/#customizing-permissions).

{{% alert title="Note" color="info" %}}
When generating a custom resource, it is necessary to set the apiVersion (ex., `spec.generate.apiVersion`) and kind (ex., `spec.generate.kind`).
{{% /alert %}}

Kyverno will create an intermediate object called a `UpdateRequest` which is used to queue work items for the final resource generation. To get the details and status of a generated resource, check the details of the `UpdateRequest`. The following will give the list of `UpdateRequests`.

```sh
kubectl get updaterequests -A
```

A `UpdateRequest` status can have one of four values:

* `Completed`: the `UpdateRequest` controller created resources defined in the policy
* `Failed`: the `UpdateRequest` controller failed to process the rules
* `Pending`: the request is yet to be processed or the resource has not been created
* `Skip`: marked when triggering the generate policy by adding a label/annotation to the existing resource, while the selector is not defined in the policy itself.

## Data Source

The resource definition of a generated resource may be defined in the Kyverno policy/rule directly. To do this, define the `generate.data` object to store the contents of the resource to be created. Variable templating is supported for all fields in the `data` object. With synchronization enabled, later modification of the contents of that `data` object will cause Kyverno to update all downstream (generated) resources with the changes. Define the field `spec.generateExistingOnPolicyUpdate` with a value of `true` as shown below in an example. This field is also required when invoking [generation for existing resources](#generate-for-existing-resources).

The following table shows the behavior of deletion and modification events on components of a generate rule with a data source declaration. "Downstream" refers to the generated resource(s). "Trigger" refers to the resource responsible for triggering the generate rule as defined in a combination of `match` and `exclude` blocks. Note that when using a data source with sync enabled, deletion of the rule/policy responsible for a resource's generation will cause immediate deletion of any/all downstream resources.

| Action             | Sync Effect          | NoSync Effect         |
|--------------------|----------------------|-----------------------|
| Delete Downstream  | Downstream recreated | Downstream deleted    |
| Delete Rule/Policy | Downstream deleted   | Downstream retained   |
| Delete Trigger     | None                 | None                  |
| Modify Downstream  | Downstream reverted  | Downstream modified   |
| Modify Rule/Policy | Downstream synced    | Downstream unmodified |
| Modify Trigger     | None                 | None                  |

### Examples

This policy sets the Zookeeper and Kafka connection strings for all Namespaces based upon a ConfigMap defined within the rule itself.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: zk-kafka-address
spec:
  generateExistingOnPolicyUpdate: true
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

In this example, new Namespaces will receive a NetworkPolicy that denies all inbound and outbound traffic. Similar to the first example, the `generate.data` object is used to define, as an overlay pattern, the `spec` for the NetworkPolicy resource.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: default
spec:
  generateExistingOnPolicyUpdate: true
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

For other examples of generate rules, see the [policy library](/policies/?policytypes=generate).

## Clone Source

When a generate policy should take the source from a resource which already exists in the cluster, a `clone` object is used instead of a `data` object. When triggered, the generate policy will clone from the resource name and location defined in the rule to create the new resource. Use of the `clone` object implies no modification during the path from source to destination and Kyverno is not able to modify its contents (aside from metadata used for processing and tracking).

The following table shows the behavior of deletion and modification events on components of a generate rule with a clone source declaration. "Downstream" refers to the generated resource(s). "Trigger" refers to the resource responsible for triggering the generate rule as defined in a combination of `match` and `exclude` blocks and "Source" refers to the clone source. Note that when using a clone source with sync enabled, deletion of the rule/policy responsible for a resource's generation or deletion of the clone source will NOT cause deletion of any downstream resources. This behavior differs when compared to [data declarations](#data-source).

| Action             | Sync Effect           | NoSync Effect         |
|--------------------|-----------------------|-----------------------|
| Delete Downstream  | Downstream recreated  | Downstream deleted    |
| Delete Rule/Policy | Downstream retained   | Downstream retained   |
| Delete Source      | Downstream retained   | Downstream retained   |
| Delete Trigger     | None                  | None                  |
| Modify Downstream  | Downstream reverted   | Downstream modified   |
| Modify Rule/Policy | Downstream unmodified | Downstream unmodified |
| Modify Source      | Downstream synced     | Downstream unmodified |
| Modify Trigger     | None                  | None                  |

### Examples

In this policy, designed to clone and keep downstream Secrets in-sync with the source, the source of the data is an existing Secret resource named `regcred` which is stored in the `default` Namespace. Notice how the `generate` rule here instead uses the `generate.clone` object when the origin data exists within Kubernetes. With synchronization enabled, any modifications to the `regcred` source Secret in the `default` Namespace will cause all downstream generated resources to be updated.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-secrets
spec:
  rules:
  - name: sync-image-pull-secret
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      apiVersion: v1
      kind: Secret
      name: regcred
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      clone:
        namespace: default
        name: regcred
```

For other examples of generate rules, see the [policy library](/policies/?policytypes=generate).

### Cloning Multiple Resources

Kyverno, as of 1.8, has the ability to clone multiple resources in a single rule definition for use cases where several resources must be cloned from a source Namespace to a destination Namespace. By using the `generate.cloneList` object, multiple kinds from the same Namespace may be specified. Use of an optional `selector` can scope down the source of the clones to only those having the matching label(s). The below policy clones Secrets and ConfigMaps from the `staging` Namespace which carry the label `allowedToBeCloned="true"`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-secret-with-multi-clone
spec:
  rules:
  - name: sync-secret
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
      namespace: "{{request.object.metadata.name}}"
      synchronize: true
      cloneList:
        namespace: staging
        kinds:
          - v1/Secret
          - v1/ConfigMap
        selector:
          matchLabels:
            allowedToBeCloned: "true"
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

Use of a `generate` rule is common when creating net new resources from the point after which the policy was created. For example, a Kyverno `generate` policy is created so that all future namespaces can receive a standard set of Kubernetes resources. However, it is also possible to generate resources into **existing** resources, namely the Namespace construct. This can be extremely useful when deploying Kyverno to an existing cluster in use where you wish policy to apply retroactively.

With Kyverno 1.7, Kyverno supports the generate for existing resources. Generate existing policies are applied in the background which creates target resources based on the match statement within the policy. They may also optionally be configured to apply upon updates to the policy itself.

### Examples

By default, policy will not be applied on existing trigger resources when it is installed. This behavior can be configured via `generateExistingOnPolicyUpdate` attribute. Only if you set `generateExistingOnPolicyUpdate` to `true` will Kyverno generate the target resource in existing triggers on policy CREATE and UPDATE events.

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

Similarly, this ClusterPolicy will create a `PodDisruptionBudget` resource for existing or new Deployments.

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
