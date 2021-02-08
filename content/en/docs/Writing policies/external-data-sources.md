---
title: External Data Sources
description: >
    Use data from ConfigMaps and the Kubernetes API Server 
weight: 7
---

The [Variables](/docs/writing-policies/variables/) section discusses how variables help with create smarter and reusable policy definitions and introduced the concept of a rule [`context`](http://localhost:1313/docs/writing-policies/variables/#variables-from-external-data-sources) that stores all variables.

This section provides details on using ConfigMaps and API Calls to reference external data as variables in policies.

{{% alert title="Note" color="info" %}}
For improved security and performance, Kyverno is designed to not allow connections to systems other than the cluster Kubernetes API server. Use a separate controller or the [sidecar container pattern](https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers) to fetch data from any source and store it in a `ConfigMap` that can be efficiently used in a policy. This design enables separation of concerns and enforcement of security boundaries.
{{% /alert %}}


## Variables from ConfigMaps

A [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) resource in Kubernetes is commonly used as a source of configuration details which can be consumed by applications. This data can be written in multiple formats, stored in a Namespace, and accessed easily. Kyverno supports using a ConfigMap as a data source for variables, either as key/value pair data or multi-line strings. When a policy referencing a ConfigMap resource is evaluated, the ConfigMap data is checked at that time ensuring that references to the `ConfigMap` are always dynamic. Should the ConfigMap be updated later, subsequent policy lookups will pick up the data at that point.

In order to consume data from a ConfigMap in a `rule`, a `context` is required. For each `rule` you wish to consume data from a ConfigMap, you must define a `context`. The context data can then be referenced in the policy `rule` using JMESPath notation.


### Looking up ConfigMap values

A ConfigMap that is defined in a rule's `context` can be referred to using its unique name within the context. ConfigMap values can be referenced using a JMESPath style expression:

```
{{ <context-name>.data.<key-name> }}
```

Based on the example above, we can now refer to a ConfigMap value using `{{dictionary.data.env}}`. The variable will be substituted with the value `production` during policy execution.

Put into context of a full `ClusterPolicy`, referencing a ConfigMap as a variable looks like the following.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cm-variable-example
  annotations:
    pod-policies.kyverno.io/autogen-controllers: DaemonSet,Deployment,StatefulSet
spec:
    rules:
    - name: example-configmap-lookup
      context:
      - name: dictionary
        configMap:
          name: mycmap
          namespace: default
      match:
        resources:
          kinds:
          - Pod
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              my-environment-name: "{{dictionary.data.env}}"
```

In the above `ClusterPolicy`, a `mutate` rule matches all incoming Pod resources and adds a label to them with the name of `my-environment-name`. Because we have defined a `context` which points to our earlier ConfigMap named `mycmap`, we can reference the value with the expression `{{dictionary.data.env}}`. A new Pod will then receive the label `my-environment-name=production`.

{{% alert title="Note" color="info" %}}
ConfigMap names and keys can contain characters that are not supported by [JMESPath](http://jmespath.org/), such as "-" (minus or dash) or "/" (slash). To evaluate these characters as literals, add double quotes to that part of the JMESPath expression as follows:
```
{{ "<name>".data."<key>" }}
```
{{% /alert %}}


### Handling ConfigMap Array Values

In addition to simple string values, Kyverno has the ability to consume array values from a ConfigMap. Currently, the ConfigMap value must be an array of string values in JSON format. Kyverno will parse the JSON string to a list of strings, so set operations like `In` and `NotIn` can then be applied.

For example, let's say you wanted to define a list of allowed roles in a ConfigMap. A Kyverno policy can refer to this list to deny a request where the role, defined as an annotation, does not match one of the values in the list.

Consider a ConfigMap with the following content.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: roles-dictionary
  namespace: default
data:
  allowed-roles: "[\"cluster-admin\", \"cluster-operator\", \"tenant-admin\"]"
```

Once created, `describe` the resource to see how the array of strings is stored.

```sh
kubectl describe cm roles-dictionary
```
```
Name:         roles-dictionary
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
allowed-roles:
----
["cluster-admin", "cluster-operator", "tenant-admin"]
```

From the output above, the array of strings are stored in JSON array format.

{{% alert title="Note" color="info" %}}
As mentioned previously, certain characters must be escaped for [JMESPath](http://jmespath.org/) processing. In this case, the backslash ("`\`") character is used to escape the double quotes which allow the ConfigMap data to be stored as a JSON array.
{{% /alert %}}

Now that the array data is saved in the `allowed-roles` key, here is a sample `ClusterPolicy` containing a single `rule` that blocks a Deployment if the value of the annotation named `role` is not in the allowed list:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cm-array-example
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: validate-role-annotation
    context:
      - name: roles-dictionary
        configMap:
          name: roles-dictionary
          namespace: default
    match:
      resources:
        kinds:
        - Deployment
    validate:
      message: "The role {{ request.object.metadata.annotations.role }} is not in the allowed list of roles: {{ \"roles-dictionary\".data.\"allowed-roles\" }}."
      deny:
        conditions:
        - key: "{{ request.object.metadata.annotations.role }}"
          operator: NotIn
          value:  "{{ \"roles-dictionary\".data.\"allowed-roles\" }}"
```

This rule denies the request for a new Deployment if the annotation `role` is not found in the array we defined in the earlier ConfigMap named `roles-dictionary`. 

{{% alert title="Note" color="info" %}}
You may also notice that this sample uses variables from both `AdmissionReview` and ConfigMap sources in a single rule. This combination can prove to be very powerful and flexible in crafting useful policies.
{{% /alert %}}

Once creating this sample `ClusterPolicy`, attempt to create a new Deployment where the annotation `role=super-user` and test the result.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox
  annotations:
    role: super-user
  labels:
    app: busybox
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - image: busybox:1.28
        name: busybox
        command: ["sleep", "9999"]
```

Submit the manifest and see how Kyverno reacts.

```sh
kubectl create -f deploy.yaml
```
```
Error from server: error when creating "deploy.yaml": admission webhook "validate.kyverno.svc" denied the request:

resource Deployment/default/busybox was blocked due to the following policies

cm-array-example:
  validate-role-annotation: 'The role super-user is not in the allowed list of roles: ["cluster-admin", "cluster-operator", "tenant-admin"].'
```

Changing the `role` annotation to one of the values present in the ConfigMap, for example `tenant-admin`, allows the Deployment resource to be created.


## Variables from Kubernetes API Server Calls

Kubernetes is powered by a declarative API that allows querying and manipulating resources. Kyverno policies can use the [Kubernetes API](https://kubernetes.io/docs/reference/using-api/api-concepts/) to fetch a resource, or even collections of resource types, for use in a policy. Additionally, Kyverno allows applying [JMESPath (JSON Match Expression)](https://jmespath.org/tutorial.html) to the resource data to extract and transform values into a format that is easy to use within a policy.


A Kyverno Kubernetes API call works just as with kubectl and other API clients, and can be tested using existing tools. 

For example, here is a command line that uses `kubectl` to fetch the list of pods in a namespace and then pipes the output to [`jp`](https://github.com/jmespath/jp) which counts the number of pods:

```sh
kubectl get --raw /api/v1/namespaces/kyverno/pods | jp "items | length(@)"
```

{{% alert title="Tip" color="info" %}}
Use `kubectl get --raw` and [`jp`](https://github.com/jmespath/jp) (the JMESPath Command Line) to test API Calls.
{{% /alert %}}

The corresponding API call in Kyverno is defined as below. It uses a variable `{{request.namespace}}` to use the namespace of the object being operated on, and then applies the same JMESPath to store the count of pods in the namespace in the context as the variable `podCount`. This new variable can then be used in the policy rule.

```yaml
  rules:
  - name: example-api-call
    context:
    - name: podCount
      apiCall:
        urlPath: "/api/v1/namespaces/{{request.namespace}}/pods"
        jmesPath: "items | length(@)"   
```

### URL Paths

The Kubernetes API organizes resources under groups and versions. For example, the resource type `Deployment` is available in the API Group `apps` with a version `v1`. 

The HTTP URL paths of the API calls are based on the group, version, and resource type as follows:

* `/apis/{GROUP}/{VERSION}/{RESOURCETYPE}`: get a collection of resources
* `/apis/{GROUP}/{VERSION}/{RESOURCETYPE}/{NAME}`: get a resource 

For namespaced resources, to get a specific resource by name or to get all resources in a namespace, the namespace name must also be provided as follows: 

* `/apis/{GROUP}/{VERSION}/namespaces/{NAMESPACE}/{RESOURCETYPE}`: get a collection of resources in the namespace
* `/apis/{GROUP}/{VERSION}/namespaces/{NAMESPACE}/{RESOURCETYPE}/{NAME}`: get a resource in a namespace

For historic resources, the Kubernetes Core API is available under `/api/v1`. For example, to query all namespaces the path `/api/v1/namespaces` is used.

The Kubernetes API groups are defined in the [API reference documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#-strong-api-groups-strong-) and can also be retrieved via the `kubectl api-resources` command shown below:


```sh
λ kubectl api-resources
NAME                              SHORTNAMES   APIGROUP                       NAMESPACED   KIND
bindings                                                                      true         Binding
componentstatuses                 cs                                          false        ComponentStatus
configmaps                        cm                                          true         ConfigMap
endpoints                         ep                                          true         Endpoints
events                            ev                                          true         Event
limitranges                       limits                                      true         LimitRange
namespaces                        ns                                          false        Namespace
nodes                             no                                          false        Node
persistentvolumeclaims            pvc                                         true         PersistentVolumeClaim

...


```

The `kubectl api-versions` command prints out the available versions for each API group. Here is a sample:

```sh
$ kubectl api-versions
admissionregistration.k8s.io/v1
admissionregistration.k8s.io/v1beta1
apiextensions.k8s.io/v1
apiextensions.k8s.io/v1beta1
apiregistration.k8s.io/v1
apiregistration.k8s.io/v1beta1
apps/v1
authentication.k8s.io/v1
authentication.k8s.io/v1beta1
authorization.k8s.io/v1
authorization.k8s.io/v1beta1
autoscaling/v1
autoscaling/v2beta1
autoscaling/v2beta2
batch/v1
   
...

```

You can use these command together to find the URL path for resources, as shown below:


{{% alert title="Tip" color="info" %}}

To find the API group and version for a resource use `kubectl api-resources` to find the group and then `kubectl api-versions` to find the available versions.

This example find the group of `deployment` resources and then queries the version:

```sh
kubectl api-resources | grep deploy
```

The API group is shown in the 3rd column of the output. You can then use the group name to find the version:

```sh
kubectl api-versions | grep apps
```

The output of this will be `apps/v1`. Older versions of Kubernetes (prior to 1.18) will also show `apps/v1beta2`.

{{% /alert %}}


### Handling collections

The API server response for a `HTTP GET` on a URL path that requests collections of resources will be an object with a list of items (resources).

Here is an example that fetches all namespaces:

```
kubectl get --raw /api/v1/namespaces | jq
```

{{% alert title="Tip" color="info" %}}
Use [`jq`](https://stedolan.github.io/jq/) to format output for readability.  
{{% /alert %}}


This will return a `NamespaceList` object with a property `items` that contains the list of namespaces:

```json
{
    "kind": "NamespaceList",
    "apiVersion": "v1",
    "metadata": {
      "selfLink": "/api/v1/namespaces",
      "resourceVersion": "2009258"
    },
    "items": [
      {
        "metadata": {
          "name": "default",
          "selfLink": "/api/v1/namespaces/default",
          "uid": "5011b5d5-abb7-4fef-93f9-8b5fa4b2eba9",
          "resourceVersion": "155",
          "creationTimestamp": "2021-01-19T20:20:37Z",
          "managedFields": [
            {
              "manager": "kube-apiserver",
              "operation": "Update",
              "apiVersion": "v1",
              "time": "2021-01-19T20:20:37Z",
              "fieldsType": "FieldsV1",
              "fieldsV1": {
                "f:status": {
                  "f:phase": {}
                }
              }
            }
          ]
        },
        "spec": {
          "finalizers": [
            "kubernetes"
          ]
        },
        "status": {
          "phase": "Active"
        }
      },

      ...

```

To process this data in JMESPath, reference the `items`. Here is an example, to extract a few metadata fields across all namespaces:

```sh
kubectl get --raw /api/v1/namespaces | jp "items[*].{name: metadata.name, creationTime: metadata.creationTimestamp}"
```

This produces a new JSON list of objects with properties `name` and `creationTime`. 

```json
[
  {
    "creationTimestamp": "2021-01-19T20:20:37Z",
    "name": "default"
  },
  {
    "creationTimestamp": "2021-01-19T20:20:36Z",
    "name": "kube-node-lease"
  },

  ...

```

To find an item in the list you can use JMESPath filters. For example, this command will match a namespace by its name:

```sh
 kubectl get --raw /api/v1/namespaces | jp "items[?metadata.name == 'default'].{uid: metadata.uid, creationTimestamp: metadata.creationTimestamp}"
```

In addition to wildcards and filters, JMESPath has many additional powerful features including several useful functions. Be sure to go through the [JMESPath tutorial](https://jmespath.org/tutorial.html) and try the interactive examples.


### Sample Policy: Limit Services of type LoadBalancer in a namespace 

Here is a complete sample policy that limits each namespace to a single service of type `LoadBalancer`. 


```yaml
apiVersion : kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: limits
spec:
  validationFailureAction: enforce
  rules:
  - name: limit-lb-svc
    match:
      resources:
        kinds:
        - Service
    context:
    - name: serviceCount
      apiCall:
        urlPath: "/api/v1/namespaces/{{ request.object.metadata.namespace }}/services"
        jmesPath: "items[?spec.type == 'LoadBalancer'] | length(@)"    
    preconditions:
    - key: "{{ request.operation }}"
      operator: Equals
      value: "CREATE"
    validate:
      message: "Only one LoadBalancer service is allowed per namespace"
      deny:
        conditions:
        - key: "{{ serviceCount }}"
          operator: GreaterThanOrEquals
          value: 1

```

It retrieves the list of services in the namespace and stores the count of services of ype `LoadBalancer` in a variable called `serviceCount`. A `deny` rule is used to ensure that the count cannot exceed 1.

