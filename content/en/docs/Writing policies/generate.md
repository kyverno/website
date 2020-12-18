---
title: Generate Resources
description: Create additional resources based on resource creation or updates. 
weight: 5
---

A ```generate``` rule can used to create additional resources when a new resource is created, when labels are created, or when metadata is updated for a resource. This policy type is useful to create supporting resources, such as new role bindings, or network policies, for a namespace.

The `generate` rule supports `match` and `exclude` blocks, like other rules. Hence, the trigger for applying this rule can be the creation of any resource. It is also possible to match or exclude API requests based on subjects, roles, etc.

Cenerate rules are triggered during API CREATE operations, or API UPDATE operations, that satisfy the match condition of a generate rule.

{{% alert title="Note" color="info" %}}
As of Kyverno v1.3.0, resources generated with `synchronize=true` may be deleted.
{{% /alert %}}

When using a `generate` rule, the source resource can be either an existing resource defined within Kubernetes, or a new resource defined in the rule itself. When the origin resource is a pre-existing resource such as a `ConfigMap` or `Secret`, for example, the `clone` object is used. When the origin resource is a new resource defined within the manifest of the rule, the `data` object is used. These are mutually exclusive, and only one may be specified in a rule.

## Updating existing resources

Generate requests are not automatically applied to existing resources, to prevent inadvertent changes to existing resources. However, you can use labels or annotations to manage a rollout of generate rules to existing resources.

To trigger a generate request for existing resources, you can write the generate rule to match based on a label or annotation, and then modify the label or annotation for resources you want to have the generate rule apply to. 

For example, you can write a generate rule that adds a network policy to all namespaces with the annotation `kyverno.io/netpol: true` and a mutate rule to add that annotation to all new namespaces.With these rules in place, you can then modify any existing namespace to add the annotation, and Kyverno will then execute the generate rule for that namespace.

## Synchronizing Changes

To keep resources synchronized across changes you can use the `synchronize` setting. When `synchronize`  is set to `true` generated resources are kept in-sync with the source resource (which can be defined as part of the policy or may be an existing resource), and generated resources cannot be modified by users. If  `synchronize` is set to `false` then users can update or delete the generated resource directly.

## Examples

### Generate a ConfigMap using inline data

This policy sets the Zookeeper and Kafka connection strings for all namespaces based upon a `ConfigMap` defined within the rule itself. Notice that this rule has the `generate.data` object defined in which case the rule will create a new `ConfigMap` called `zk-kafka-address` using the data specified in the rule's manifest.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: zk-kafka-address
spec:
  rules:
  - name: k-kafka-address
    match:
      resources:
        kinds:
        - Namespace
    exclude:
      resources:
        namespaces:
        - kube-system
        - default
        - kube-public
        - kyverno
    generate:
      synchronize: true
      kind: ConfigMap
      name: zk-kafka-address
      # generate the resource in the new namespace
      namespace: "{{request.object.metadata.name}}"
      data:
        kind: ConfigMap
        data:
          ZK_ADDRESS: "192.168.10.10:2181,192.168.10.11:2181,192.168.10.12:2181"
          KAFKA_ADDRESS: "192.168.10.13:9092,192.168.10.14:9092,192.168.10.15:9092"
```

### Clone a ConfigMap and propagate changes

This policy clones an existing config map and synchronizes changes across namespaces.

In this policy, the source of the data is an existing `ConfigMap` resource named `config-template` which is stored in the `default` namespace. Notice how the `generate` rule here instead uses the `generate.clone` object when the origin data exists within Kubernetes.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: basic-policy
spec:
  rules:
  - name: Clone ConfigMap
    match:
      resources:
        kinds:
        - Namespace
    exclude:
      resources:
        namespaces:
        - kube-system
        - default
        - kube-public
        - kyverno
    generate:
      # Kind of generated resource
      kind: ConfigMap
      # Name of the generated resource
      name: default-config
      # namespace for the generated resource
      namespace: "{{request.object.metadata.name}}"
      # propagate changes from the upstream resource
      synchronize : true
      clone:
        namespace: default
        name: config-template
```

### Generate a NetworkPolicy

In this example new namespaces will receive a `NetworkPolicy` that denies all inbound and outbound traffic.

In this example, new namespaces will receive a `NetworkPolicy` that denies all inbound and outbound traffic. Similar to the first example, the `generate.data` object is used to define, as an overlay pattern, the `spec` for the `NetworkPolicy` resource.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: default
spec:
  rules:
  - name: deny-all-traffic
    match:
      resources:
        kinds:
        - Namespace
    exclude:
      resources:
        namespaces:
        - kube-system
        - default
        - kube-public
        - kyverno
    generate:
      kind: NetworkPolicy
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

## Generating resources into existing namespaces

Use of a `generate` rule is common when creating net new resources from the point after which the policy was created. For example, a Kyverno `generate` policy is created so that all future namespaces can receive a standard set of Kubernetes resources. However, it is also possible to generate resources into **existing** resources, namely the namespace construct. This can be extremely useful when deploying Kyverno to an existing cluster in use where you wish policy to apply retroactively.

Normally, Kyverno does not alter existing objects in any way as a central tenet of its design. However, using this method of controlled roll-out, you may use `generate` rules to create new objects into existing namespaces. To do so, follow these steps:

1. Identify some Kubernetes label or annotation which is not yet defined on any namespace but can be used to add to existing ones signaling to Kyverno that these namespaces should be targets for `generate` rules. The metadata can be anything, but it should be descriptive for this purpose and not in use anywhere else nor use reserved key names such as `kubernetes.io` or `kyverno.io`.

2. Create a ClusterPolicy with a rule containing a `match` statement which matches on kind `namespace` as well as the label or annotation you have set aside. In the `sync-secret` policy below, it matches on not only namespaces but a label of `mycorp-rollout=true` and copies into these namespaces a Secret called `corp-secret` stored in the `default` namespace.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-secret
spec:
  rules:
  - name: sync-secret
    match:
      resources:
        kinds:
        - Namespace
        selector:
          matchLabels:
            mycorp-rollout: "true"
    generate:
      kind: Secret
      name: corp-secret
      namespace: "{{request.object.metadata.name}}"
      synchronize : true
      clone:
        namespace: default
        name: corp-secret
```

3. Create the policy as usual.

4. On an existing namespace where you wish to have the Secret `corp-secret` copied into it, label it with `mycorp-rollout=true`. This step must be completed after the ClusterPolicy exists. If it is labeled before, Kyverno will not see the request.

```sh
$ kubectl label ns prod-bus-app1 mycorp-rollout=true

namespace/prod-bus-app1 labeled
```

5. Check the namespace you just labeled to see if the Secret exists.

```sh
$ kubectl -n prod-bus-app1 get secret

NAME                                               TYPE                                  DATA   AGE
corp-secret                                        Opaque                                2      10s
```

6. Repeat these steps as needed on any additional namespaces where you wish this ClusterPolicy to apply its `generate` rule.

If you would like Kyverno to remove the resource it generated into these existing namespaces, you may unlabel the namespace.

```sh
$ kubectl label ns prod-bus-app1 mycorp-rollout-
```

The Secret from the previous example should be removed.
