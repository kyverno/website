---
title: Generate Resources
description: Create additional resources based on resource creation, or label/metadata changes. 
weight: 5
---

A ```generate``` rule can used to create additional resources when a new resource is created, when labels are created, or when metadata is updated for a resource. This policy type is useful to create supporting resources, such as new role bindings, or network policies, for a namespace.

The `generate` rule supports `match` and `exclude` blocks, like other rules. Hence, the trigger for applying this rule can be the creation of any resource and its possible to match or exclude API requests based on subjects, roles, etc. 

## Updating existing resources

Cenerate rules are triggered during API CREATE operations, or API UPDATE operations that satisfy the match condition of a generate rule. By default, generate requests are not applied to existing resources. This prevents inadvertent changes to existing resources.

To trigger a generate request for existing resources, you can write the generate rule to match based on a label or annotation, and then apply the label or annotation to resources you want to have the generate apply to. 

For example, you can write a generate rule that adds a network policy to all namespaces with the annotation `kyverno.io/netpol: true` and a mutate rule to add that annotation to all new namespaces. With these rules in place, you can then modify any other namespace to add the annotation, and Kyverno will then execute the generate rule for that namespace.

## Synchronizing Changes

To keep resources synchronized across changes you can use the `synchronize` setting. When `synchronize`  is set to `true` generated resources are kept in-sync with the source resource (which can be defined as part of the policy or may be an existing resource), and generated resources cannot be modified by users. If  `synchronize` is set to `false` then users can update or delete the generated resource directly.


## Examples

### Generate a ConfigMap using inline data

This policy sets the Zookeeper and Kafka connection strings for all namespaces.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: "zk-kafka-address"
spec:
  rules:
    - name: "zk-kafka-address"
      match:
        resources:
          kinds:
            - Namespace
      exclude:
        resources:
          namespaces:
            - "kube-system"
            - "default"
            - "kube-public"
            - "kyverno"
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

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: basic-policy
spec:
  rules:
    - name: "Clone ConfigMap"
      match:
        resources:
          kinds: 
          - Namespace
      exclude:
        resources:
          namespaces:
            - "kube-system"
            - "default"
            - "kube-public"
            - "kyverno"
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
````

### Generate a NetworkPolicy

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: "default"
spec:
  rules:
  - name: "deny-all-traffic"
    match:
      resources: 
        kinds:
        - Namespace
        name: "*"
    exclude:
      resources:
        namespaces:
          - "kube-system"
          - "default"
          - "kube-public"
          - "kyverno"
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
````

In this example new namespaces will receive a `NetworkPolicy` that denies all inbound and outbound traffic.


