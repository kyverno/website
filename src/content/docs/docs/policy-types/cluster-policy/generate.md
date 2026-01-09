---
title: Generate Rules
description: Create new Kubernetes resources based on a policy and optionally keep them in sync.
sidebar:
  order: 50
---

A generate rule can be used to create new Kubernetes resources in response to some other event including things like resource creation, update, or delete, or even by creating or updating a policy itself. This is useful to create supporting resources, such as new RoleBindings or NetworkPolicies for a Namespace or perform other automation tasks that may either require other tools or be scripted.

Some common use cases for generate rules include:

- Namespace provisioner / Namespace-as-a-Service
  - Create resources like a NetworkPolicy, ResourceQuota, and RoleBinding when a new Namespace is created
- Clone and synchronize Secrets and ConfigMaps
  - Copy and then synchronize changes from one or more Secrets or ConfigMaps to Namespaces across the cluster
- Retroactive creation of NetworkPolicies
  - In brownfield clusters, introduce a policy which will install a NetworkPolicy in all applicable Namespaces from a definition stored in a policy
- Custom eventing system
  - Create Kubernetes Events and associate them with any object and have any message based upon an eligible admission review

Generate rules come in two flavors. They can either apply to admission events that occur across the cluster (ex., creation of a new Namespace), or they can apply to preexisting resources in the cluster (ex., an existing Namespace). Those which apply to admission events are considered standard generate rules while those which apply to preexisting resources are known as "generate existing" rules and are covered [below](#generate-for-existing-resources).

Generate rules support `match` and `exclude` blocks and many of the other common Kyverno policy constructs such as [preconditions](/docs/policy-types/cluster-policy/preconditions), [context variables](/docs/policy-types/cluster-policy/external-data-sources), and more.

Kyverno can keep generated resources in sync to prevent tampering by use of a `synchronize` property. When `synchronize` is set to `true`, the generated resource is kept in-sync with the source resource. Synchronization is beneficial in that modifications to the generated resource may be reverted, and changes to the source resource will be propagated. In addition to these effects, synchronization will ensure that the matching resource responsible for the triggering of the generation behavior is watched for changes. Should those changes result in a false match (including deletion), then it will result in the generated resource being removed to ensure the desired state is always maintained. In cases where the generated resource being synchronized must be modified by other controllers in the cluster, Kyverno can optionally use [server-side apply](https://kubernetes.io/docs/reference/using-api/server-side-apply/) when generating the resource through the field `spec.useServerSideApply`.

When using a generate rule, the source resource can either be an existing resource in the cluster, or a new resource defined in the rule itself. When the source is an existing resource in the cluster such as a ConfigMap or Secret, for example, the `clone` object is used. See the [Clone Source](#clone-source) section for more details. When the source is defined directly in the rule, the `data` object is used. See the [Data Source](#data-source) section for more details. These are mutually exclusive and only one may be specified per rule.

Because Kyverno can generate any type of Kubernetes resource, including custom resources, in some cases it may be necessary to grant the Kyverno background controller's ServiceAccount additional permissions. To enable Kyverno to generate these other types, see the section on [customizing permissions](/docs/installation/customization#customizing-permissions). Kyverno will assist you in these situations by validating and informing you if the background controller does not have the level of permissions required at the time the rule or policy is installed.

## Data Source

The source of a generated resource may be defined in the Kyverno policy/rule directly. This is useful in that the full contents of the source can be templated making the resource Kyverno generates highly dynamic and variable depending on the circumstances. To do this, define the `generate.data` object to store the contents of the resource to be created. Variable templating is supported for all fields in the `data` object. With synchronization enabled, later modification of the contents of that `data` object will cause Kyverno to update all downstream (generated) resources with the changes.

The following table shows the behavior of deletion and modification events on components of a generate rule with a data source declaration. "Downstream" refers to the generated resource(s). "Trigger" refers to the resource responsible for triggering the generate rule as defined in a combination of `match` and `exclude` blocks. Note that when using a data source with sync enabled, deletion of the rule/policy responsible for a resource's generation will cause immediate deletion of any/all downstream resources.

| Action             | Sync Effect                                                             | NoSync Effect         |
| ------------------ | ----------------------------------------------------------------------- | --------------------- |
| Delete Downstream  | Downstream recreated                                                    | Downstream deleted    |
| Delete Rule/Policy | Downstream retained <br>`generate.orphanDownstreamOnPolicyDelete: true` | Downstream retained   |
| Delete Rule/Policy | Downstream deleted <br>`generate.orphanDownstreamOnPolicyDelete: false` | Downstream retained   |
| Delete Trigger     | Downstream deleted                                                      | None                  |
| Modify Downstream  | Downstream reverted                                                     | Downstream modified   |
| Modify Rule/Policy | Downstream synced                                                       | Downstream unmodified |
| Modify Trigger     | Downstream deleted                                                      | None                  |

The `orphanDownstreamOnPolicyDelete` property can be used to preserve generated resources on policy/rule deletion when synchronization is enabled. Default is set to `false`. When enabled, the generate resource will be retained in the cluster.

### Data Examples

This policy sets the Zookeeper and Kafka connection strings for all Namespaces based upon a ConfigMap defined within the rule itself.

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
        namespace: '{{request.object.metadata.name}}'
        data:
          kind: ConfigMap
          metadata:
            labels:
              somekey: somevalue
          data:
            ZK_ADDRESS: '192.168.10.10:2181,192.168.10.11:2181,192.168.10.12:2181'
            KAFKA_ADDRESS: '192.168.10.13:9092,192.168.10.14:9092,192.168.10.15:9092'
```

In this example, new Namespaces will receive a NetworkPolicy that denies all inbound and outbound traffic. Similar to the first example, the `generate.data` object is used to define, as an overlay pattern, the `spec` for the NetworkPolicy resource.

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
        namespace: '{{request.object.metadata.name}}'
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

:::note[Tip]
In situations where it may be required to slightly modify the cloned resource, for example to add labels or annotations, an additional mutate rule may be added to the policy so that Kyverno modifies the resource in flight.
:::

:::caution[Warning]
For clone-type generate rules, Kyverno must be able to add labels to the clone source in order to track changes. If another operator or controller owns the source, you must ensure it is configured in such a way that these Kyverno labels are not modified/removed.
:::

The following table shows the behavior of deletion and modification events on components of a generate rule with a clone source declaration. "Downstream" refers to the generated resource(s). "Trigger" refers to the resource responsible for triggering the generate rule as defined in a combination of `match` and `exclude` blocks. "Source" refers to the clone source. Note that when using a clone source with sync enabled, deletion of the rule/policy responsible for a resource's generation or deletion of the clone source will NOT cause deletion of any downstream resources. This behavior differs when compared to [data declarations](#data-source).

| Action             | Sync Effect           | NoSync Effect         |
| ------------------ | --------------------- | --------------------- |
| Delete Downstream  | Downstream recreated  | Downstream deleted    |
| Delete Rule/Policy | Downstream retained   | Downstream retained   |
| Delete Source      | Downstream deleted    | Downstream retained   |
| Delete Trigger     | Downstream deleted    | None                  |
| Modify Downstream  | Downstream reverted   | Downstream modified   |
| Modify Rule/Policy | Downstream unmodified | Downstream unmodified |
| Modify Source      | Downstream synced     | Downstream unmodified |
| Modify Trigger     | Downstream deleted    | None                  |

### Clone Examples

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
        namespace: '{{request.object.metadata.name}}'
        synchronize: true
        clone:
          namespace: default
          name: regcred
```

For other examples of generate rules, see the [policy library](/policies/?policytypes=generate).

### Cloning Multiple Resources

Kyverno has the ability to clone multiple resources in a single rule definition for use cases where several resources must be cloned from a source Namespace to a destination Namespace. By using the `generate.cloneList` object, multiple kinds from the same Namespace may be specified. Use of an optional `selector` can scope down the source of the clones to only those having the matching label(s). The below policy clones Secrets and ConfigMaps from the `staging` Namespace which carry the label `allowedToBeCloned="true"`.

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
        namespace: '{{request.object.metadata.name}}'
        synchronize: true
        cloneList:
          namespace: staging
          kinds:
            - v1/Secret
            - v1/ConfigMap
          selector:
            matchLabels:
              allowedToBeCloned: 'true'
```

## foreach

The `foreach` declaration allows generation of multiple target resources of sub-elements in resource declarations. Each `foreach` entry must contain a `list` attribute, written as a JMESPath expression without braces, that defines the sub-elements it processes. For example, creating networkpolicies for a list of Namespaces which is stored in a label:

```
list: request.object.metadata.labels.namespaces | split(@, ',')
```

When a `foreach` is processed, the Kyverno engine will evaluate `list` as a JMESPath expression to retrieve zero or more sub-elements for further processing. The value of the `list` field may also resolve to a simple array of strings, for example as defined in a context variable. The value of the `list` field should not be enclosed in braces even though it is a JMESPath expression.

A variable `element` is added to the processing context on each iteration. This allows referencing data in the element using `element.<name>` where name is the attribute name. For example, using the list `request.object.spec.containers` when the `request.object` is a Pod allows referencing the container image as `element.image` within a `foreach`. An additional variable called `elementIndex` is made available which allows the current index number to be referenced in a loop.

The following child declarations are permitted in a `foreach`:

- [Data Source](#data-source)
  - [Data Examples](#data-examples)
- [Clone Source](#clone-source)
  - [Clone Examples](#clone-examples)
  - [Cloning Multiple Resources](#cloning-multiple-resources)
- [foreach](#foreach)
- [Generating Bindings](#generating-bindings)
- [Linking trigger with downstream](#linking-trigger-with-downstream)
- [Generate for Existing resources](#generate-for-existing-resources)
  - [Generate Existing Examples](#generate-existing-examples)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)

In addition, each `foreach` declaration can contain the following declarations:

- [Context](/docs/policy-types/cluster-policy/external-data-sources): to add additional external data only available per loop iteration.
- [Preconditions](/docs/policy-types/cluster-policy/preconditions): to control when a loop iteration is skipped.

Here is a complete example of data source type of `foreach` declaration that creates a NetworkPolicy into a list of existing namespaces which is stored as a comma-separated string in a ConfigMap.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: foreach-generate-data
spec:
  rules:
    - match:
        any:
          - resources:
              kinds:
                - ConfigMap
      name: k-kafka-address
      generate:
        generateExisting: false
        synchronize: true
        orphanDownstreamOnPolicyDelete: false
        foreach:
          - list: request.object.data.namespaces | split(@, ',')
            context:
              - name: ns
                variable:
                  jmesPath: element
            preconditions:
              any:
                - key: '{{ ns }}'
                  operator: AnyIn
                  value:
                    - foreach-ns-1
            apiVersion: networking.k8s.io/v1
            kind: NetworkPolicy
            name: my-networkpolicy-{{element}}-{{ elementIndex }}
            namespace: '{{ element }}'
            data:
              metadata:
                labels:
                  request.namespace: '{{ request.object.metadata.name }}'
                  element: '{{ element }}'
                  elementIndex: '{{ elementIndex }}'
              spec:
                podSelector: {}
                policyTypes:
                  - Ingress
                  - Egress
```

For a complete example of clone source type of foreach declaration that clones the source Secret into a list of matching existing namespaces which is stored as a comma-separated string in a ConfigMap, see below.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: foreach-clone
spec:
  rules:
    - match:
        any:
          - resources:
              kinds:
                - ConfigMap
      name: k-kafka-address
      context:
        - name: configmapns
          variable:
            jmesPath: request.object.metadata.namespace
      preconditions:
        any:
          - key: '{{configmapns}}'
            operator: Equals
            value: 'default'
      generate:
        generateExisting: false
        synchronize: true
        foreach:
          - list: request.object.data.namespaces | split(@, ',')
            context:
              - name: ns
                variable:
                  jmesPath: element
            preconditions:
              any:
                - key: '{{ ns }}'
                  operator: AnyIn
                  value:
                    - foreach-ns-1
            apiVersion: v1
            kind: Secret
            name: cloned-secret-{{ elementIndex }}-{{ ns }}
            namespace: '{{ ns }}'
            clone:
              namespace: default
              name: source-secret
```

See the triggering ConfigMap below, the `data` contains a `namespaces` field defines multiple namespaces.

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: default-deny
  namespace: default
data:
  namespaces: foreach-ns-1,foreach-ns-2
```

Similarly as above, here is an example of clone list type of `foreach` declaration that clones a list of secrets based on the label selector.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: foreach-cpol-clone-list-sync-delete-source
spec:
  rules:
    - match:
        any:
          - resources:
              kinds:
                - ConfigMap
      name: k-kafka-address
      context:
        - name: configmapns
          variable:
            jmesPath: request.object.metadata.namespace
      preconditions:
        any:
          - key: '{{configmapns}}'
            operator: Equals
            value: '{{request.object.metadata.namespace}}'
      generate:
        generateExisting: false
        synchronize: true
        foreach:
          - list: request.object.data.namespaces | split(@, ',')
            context:
              - name: ns
                variable:
                  jmesPath: element
            preconditions:
              any:
                - key: '{{ ns }}'
                  operator: AnyIn
                  value:
                    - foreach-cpol-clone-list-sync-delete-source-target-ns-1
            namespace: '{{ ns }}'
            cloneList:
              kinds:
                - v1/Secret
              namespace: foreach-cpol-clone-list-sync-delete-source-existing-ns
              selector:
                matchLabels:
                  allowedToBeCloned: 'true'
```

## Generating Bindings

In order for Kyverno to generate a new RoleBinding or ClusterRoleBinding resource, its ServiceAccount must first be bound to the same Role or ClusterRole which you're attempting to generate. If this is not done, Kubernetes blocks the request because it sees a possible privilege escalation attempt from the Kyverno background controller's ServiceAccount. This particularity is not specific to Kyverno but rather how Kubernetes RBAC is designed to work.

For example, if you wish to write a `generate` rule which creates a new RoleBinding resource granting some user the `admin` role over a new Namespace, the Kyverno background controller's ServiceAccount must have a ClusterRoleBinding in place for that same `admin` role.

Create a new ClusterRoleBinding for the Kyverno background controller's ServiceAccount

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
    name: kyverno-background-controller
    namespace: kyverno
```

Now, create a `generate` rule as you normally would which assigns a test user named `steven` to the `admin` ClusterRole for a new Namespace. The built-in ClusterRole named `admin` in this rule must match the ClusterRole granted to the Kyverno background controller's ServiceAccount in the previous ClusterRoleBinding.

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
        namespace: '{{request.object.metadata.name}}'
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

## Linking trigger with downstream

In some cases, a triggering (source) resource and generated (downstream) resource need to share the same life cycle. That is, when the triggering resource is deleted so too should the generated resource. This is valuable because some resources are only needed in the presence of another, for example a Service of type `LoadBalancer` necessitating the need for a specific network policy in some CNI plug-ins.

When a generate rule has synchronization enabled (`synchronize: true`), deletion of the triggering resource will automatically cause deletion of the downstream (generated) resource. In addition to deletion, if the triggering resource is altered in a way such that it no longer matches the definition in the rule, that too will cause removal of the downstream resource. In cases where synchronization needs to be disabled, if the trigger and downstream are both Namespaced resources and in the same Namespace, the ownerReference technique can be used.

For a `generate.foreach` type of declaration, Kyverno does not prevent modifications to the rule definition. When the `synchronize` option is enabled for such a rule, Kyverno will not synchronize changes to existing target resources when updates are made to the target resource specification. For instance, if a `generate.foreach` declaration initially creates a NetworkPolicy named `staging/networkpolicy-default`, and is subsequently modified to create a new NetworkPolicy named `staging/networkpolicy-new`, any further changes will not be applied to the existing `staging/networkpolicy-default` NetworkPolicy resource.

:::note[Note]
Synchronization involving changes to trigger resources are confined to the `match` block and do not take into consideration preconditions.
:::

It is possible to set the `ownerReferences` field in the generated resource which, when pointed to the trigger, will cause deletion of the trigger to instruct Kubernetes to garbage collect the downstream. With the below example, when the generated ConfigMap specifies the `metadata.ownerReferences[]` object and defines the following fields including `uid`, which references the triggering Service resource, an owner-dependent relationship is formed. Later, if the Service is deleted, the ConfigMap will be as well. See the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/#owner-references-in-object-specifications) for more details including an important caveat around the scoping of these references. Specifically, Namespaced resources cannot be the owners of cluster-scoped resources, and cross-namespace references are also disallowed.

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
        name: '{{request.object.metadata.name}}-gen-cm'
        namespace: '{{request.namespace}}'
        synchronize: false
        data:
          metadata:
            ownerReferences:
              - apiVersion: v1
                kind: Service
                name: '{{request.object.metadata.name}}'
                uid: '{{request.object.metadata.uid}}'
          data:
            foo: bar
```

## Generate for Existing resources

Use of a `generate` rule is common when creating net new resources from the point after which the policy was created. For example, a Kyverno `generate` policy is created so that all future Namespaces can receive a standard set of Kubernetes resources. However, it is also possible to generate resources based on **existing** resources. This can be extremely useful especially for Namespaces when deploying Kyverno to an existing cluster where you wish policy to apply retroactively.

Kyverno supports generation for existing resources. Generate existing policies are applied when the policy is created and in the background which creates target resources based on the match statement within the policy. They may also optionally be configured to apply upon updates to the policy itself. By defining the `generate[*].generateExisting` set to `true`, a generate rule will take effect for existing resources which have the same match characteristics.

Note that the benefits of using a "generate existing" rule is only the moment the policy is installed. Once the initial generation effects have been produced, the rule functions like a "standard" generate rule from that point forward. Generate existing rules are therefore primarily useful for one-time use cases when retroactive policy should be applied.

### Generate Existing Examples

By default, policy will not be applied to existing trigger resources when it is installed. This behavior can be configured via `generateExisting` attribute. Only if you set `generateExisting` to `true` will Kyverno generate the target resource in existing triggers on policy CREATE and UPDATE events.

In this example policy, which triggers based on the resource kind `Namespace` a new NetworkPolicy will be generated in all new or existing Namespaces.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-resources
spec:
  rules:
    - name: generate-existing-networkpolicy
      match:
        any:
          - resources:
              kinds:
                - Namespace
      generate:
        generateExisting: true
        kind: NetworkPolicy
        apiVersion: networking.k8s.io/v1
        name: default-deny
        namespace: '{{request.object.metadata.name}}'
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

Similarly, this ClusterPolicy will create a `PodDisruptionBudget` resource for existing or new Deployments. Note that use of this policy may require granting of additional permissions as explained above. See the documentation [here](/docs/installation/customization#customizing-permissions).

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: create-default-pdb
spec:
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
        generateExisting: true
        apiVersion: policy/v1
        kind: PodDisruptionBudget
        name: '{{request.object.metadata.name}}-default-pdb'
        namespace: '{{request.object.metadata.namespace}}'
        synchronize: true
        data:
          spec:
            minAvailable: 1
            selector:
              matchLabels: '{{request.object.metadata.labels}}'
```

:::note[Note]
The field `spec.generateExisting` has been replaced by `spec.rules[*].generate[*].generateExisting`. The former is no longer required, is deprecated, and will be removed in an upcoming version.
:::

## How It Works

Kyverno will create an intermediate object called a `UpdateRequest` which is used to queue work items for the final resource generation. To get the details and status of a generated resource, check the details of the `UpdateRequest`. The following will give the list of `UpdateRequests`.

```sh
kubectl get updaterequests -A
```

A `UpdateRequest` status can have one of four values:

- `Completed`: the `UpdateRequest` controller created resources defined in the policy
- `Failed`: the `UpdateRequest` controller failed to process the rules
- `Pending`: the request is yet to be processed or the resource has not been created
- `Skip`: marked when triggering the generate policy by adding a label/annotation to the existing resource, while the selector is not defined in the policy itself.

Note that Kyverno will retry up to three times to reconcile an `UpdateRequest` in a `Failed` status. The `UpdateRequest` will be garbage collected if it exceeds the retry threshold.

Kyverno processes generate rules in a combination of the admission controller and the background controller. For further details of the internals of how these work and how high availability and scale are handled, refer to the [High Availability](/docs/high-availability/) page.

## UpdateRequest Cleanup

To help manage the accumulation of `UpdateRequest` resources in large clusters, Kyverno supports automatic cleanup through TTL (Time-to-Live) labels. This feature can be enabled through the Kyverno configuration.

### Configuring UpdateRequest Cleanup

The following ConfigMap keys can be used to configure UpdateRequest cleanup:

- `enableUpdateRequestCleanup`: Set to `true` to enable automatic cleanup labeling of UpdateRequest resources
- `updateRequestCleanupTTL`: Specifies the TTL duration for cleanup (e.g., "2m", "1h", "30s")

When enabled, Kyverno will automatically add the `cleanup.kyverno.io/ttl` label to newly created `UpdateRequest` resources with the specified TTL value.

### Helm Configuration

```yaml
config:
  enableUpdateRequestCleanup: true
  updateRequestCleanupTTL: '5m' # Clean up after 5 minutes
```

### Example

With cleanup enabled, UpdateRequest resources will have labels like:

```yaml
apiVersion: kyverno.io/v2
kind: UpdateRequest
metadata:
  labels:
    cleanup.kyverno.io/ttl: '5m'
  # ... other metadata
```

This relies on a cleanup controller (like the Kyverno cleanup controller) being present in the cluster to process the TTL labels and delete expired resources.

:::note[Note]
The cleanup feature requires a cleanup controller to be running in your cluster to process the TTL labels. Kyverno includes a cleanup controller by default.
:::

## Troubleshooting

Troubleshooting of problems with generate rules often comes down to only a few things:

1. Policies no longer work after an upgrade when using the scale to zero method. If possible, delete and attempt to reinstall all generate policies after an upgrade to 1.10 so they may be revalidated. Many fields allowed in previous versions of Kyverno are disallowed going forward.
2. An intermediary UpdateRequest failed to be applied. Although Kyverno checks that the necessary permissions are present at the time a policy is created, either this isn't happening or there is some other reason why the UpdateRequest cannot be reconciled. See the [How It Works](#how-it-works) section above.
3. The intended trigger did not cause a resource to be generated. Check that Kyverno is not excluding the username or group in its ConfigMap, and check that the resource filter is not discarding those requests. See the [Configuring Kyverno](/docs/installation/customization) guide for details on both.
