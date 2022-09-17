---
title: External Data Sources
description: >
    Use data from ConfigMaps, the Kubernetes API server, and image registries in Kyverno policies.
weight: 7
---

The [Variables](/docs/writing-policies/variables/) section discusses how variables can help create smarter and reusable policy definitions and introduced the concept of a rule [`context`](/docs/writing-policies/variables/#variables-from-external-data-sources) that stores all variables.

This section provides details on using ConfigMaps, API calls, and image registries to reference external data as variables in policies.

{{% alert title="Note" color="info" %}}
For improved security and performance, Kyverno is designed to not allow connections to systems other than the cluster Kubernetes API server and image registries. Use a separate controller to fetch data from any source and store it in a ConfigMap that can be efficiently used in a policy. This design enables separation of concerns and enforcement of security boundaries.
{{% /alert %}}

## Variables from ConfigMaps

A [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) resource in Kubernetes is commonly used as a source of configuration details which can be consumed by applications. This data can be written in multiple formats, stored in a Namespace, and accessed easily. Kyverno supports using a ConfigMap as a data source for variables. When a policy referencing a ConfigMap resource is evaluated, the ConfigMap data is checked at that time ensuring that references to the ConfigMap are always dynamic. Should the ConfigMap be updated, subsequent policy lookups will pick up the latest data at that point.

In order to consume data from a ConfigMap in a `rule`, a `context` is required. For each `rule` you wish to consume data from a ConfigMap, you must define a `context`. The context data can then be referenced in the policy `rule` using JMESPath notation.

### Looking up ConfigMap values

A ConfigMap that is defined in a rule's `context` can be referred to using its unique name within the context. ConfigMap values can be referenced using a JMESPath style expression.

```sh
{{ <context-name>.data.<key-name> }}
```

Consider a simple ConfigMap definition like so.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: some-config-map
  namespace: some-namespace
data:
  env: production
```

To refer to values from a ConfigMap inside a `rule`, define a `context` inside the `rule` with one or more ConfigMap declarations. Using the sample ConfigMap snippet referenced above, the below `rule` defines a `context` which references this specific ConfigMap by name.

```yaml
rules:
  - name: example-lookup
    # Define a context for the rule
    context:
    # A unique name for the ConfigMap
    - name: dictionary
      configMap:
        # Name of the ConfigMap which will be looked up
        name: some-config-map
        # Namespace in which this ConfigMap is stored
        namespace: some-namespace 
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
          name: some-config-map
          namespace: some-namespace
      match:
        any:
        - resources:
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
See the [JMESPath page](/docs/writing-policies/jmespath/#formatting) for more information on formatting concerns.
{{% /alert %}}

### Handling ConfigMap Array Values

In addition to simple string values, Kyverno has the ability to consume array values from a ConfigMap.

{{% alert title="Note" color="info" %}}
Storing array values in a YAML block scalar was removed as of Kyverno 1.7.0. Please use JSON-encoded array of strings instead.
{{% /alert %}}

For example, let's say you wanted to define a list of allowed roles in a ConfigMap. A Kyverno policy can refer to this list to deny a request where the role, defined as an annotation, does not match one of the values in the list.

Consider a ConfigMap with the following content written as a YAML multi-line value.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: roles-dictionary
  namespace: default
data:
  allowed-roles: "[\"cluster-admin\", \"cluster-operator\", \"tenant-admin\"]"
```

{{% alert title="Note" color="info" %}}
As mentioned previously, certain characters must be escaped for [JMESPath](http://jmespath.org/) processing. In this case, the backslash ("`\`") character is used to escape the double quotes which allow the ConfigMap data to be stored as a JSON array.
{{% /alert %}}

Now that the array data is saved in the `allowed-roles` key, here is a sample ClusterPolicy containing a single `rule` that blocks a Deployment if the value of the annotation named `role` is not in the allowed list:

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
      any:
      - resources:
          kinds:
          - Deployment
    validate:
      message: "The role {{ request.object.metadata.annotations.role }} is not in the allowed list of roles: {{ \"roles-dictionary\".data.\"allowed-roles\" }}."
      deny:
        conditions:
          any:
          - key: "{{ request.object.metadata.annotations.role }}"
            operator: NotIn
            value:  "{{ \"roles-dictionary\".data.\"allowed-roles\" }}"
```

This rule denies the request for a new Deployment if the annotation `role` is not found in the array we defined in the earlier ConfigMap named `roles-dictionary`.

{{% alert title="Note" color="info" %}}
You may also notice that this sample uses variables from both AdmissionReview and ConfigMap sources in a single rule. This combination can prove to be very powerful and flexible in crafting useful policies.
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

```sh
Error from server: error when creating "deploy.yaml": admission webhook "validate.kyverno.svc" denied the request:

resource Deployment/default/busybox was blocked due to the following policies

cm-array-example:
  validate-role-annotation: 'The role super-user is not in the allowed list of roles: ["cluster-admin", "cluster-operator", "tenant-admin"].'
```

Changing the `role` annotation to one of the values present in the ConfigMap, for example `tenant-admin`, allows the Deployment resource to be created.

## Variables from Kubernetes API Server Calls

Kubernetes is powered by a declarative API that allows querying and manipulating resources. Kyverno policies can use the [Kubernetes API](https://kubernetes.io/docs/reference/using-api/api-concepts/) to fetch a resource, or even collections of resource types, for use in a policy. Additionally, Kyverno allows applying [JMESPath (JSON Match Expression)](https://jmespath.org/tutorial.html) to the resource data to extract and transform values into a format that is easy to use within a policy.

A Kyverno Kubernetes API call works just as with `kubectl` and other API clients, and can be tested using existing tools.

For example, here is a command line that uses `kubectl` to fetch the list of Pods in a Namespace and then pipes the output to `kyverno jp` which counts the number of Pods:

```sh
kubectl get --raw /api/v1/namespaces/kyverno/pods | kyverno jp "items | length(@)"
```

{{% alert title="Tip" color="info" %}}
Use `kubectl get --raw` and the [`kyverno jp`](/docs/kyverno-cli/#jp) command to test API Calls.
{{% /alert %}}

The corresponding API call in Kyverno is defined as below. It uses a variable `{{request.namespace}}` to use the Namespace of the object being operated on, and then applies the same JMESPath to store the count of Pods in the Namespace in the context as the variable `podCount`. Variables may be used in both fields. This new resulting variable `podCount` can then be used in the policy rule.

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

For namespaced resources, to get a specific resource by name or to get all resources in a Namespace, the Namespace name must also be provided as follows:

* `/apis/{GROUP}/{VERSION}/namespaces/{NAMESPACE}/{RESOURCETYPE}`: get a collection of resources in the namespace
* `/apis/{GROUP}/{VERSION}/namespaces/{NAMESPACE}/{RESOURCETYPE}/{NAME}`: get a resource in a namespace

For historic resources, the Kubernetes Core API is available under `/api/v1`. For example, to query all Namespace resources the path `/api/v1/namespaces` is used.

The Kubernetes API groups are defined in the [API reference documentation for v1.22](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#-strong-api-groups-strong-) and can also be retrieved via the `kubectl api-resources` command shown below:

```sh
$ kubectl api-resources
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

You can use these commands together to find the URL path for resources, as shown below:

{{% alert title="Tip" color="info" %}}

To find the API group and version for a resource use `kubectl api-resources` to find the group and then `kubectl api-versions` to find the available versions.

This example finds the group of `Deployment` resources and then queries the version:

```sh
kubectl api-resources | grep deploy
```

The API group is shown in the third column of the output. You can then use the group name to find the version:

```sh
kubectl api-versions | grep apps
```

The output of this will be `apps/v1`. Older versions of Kubernetes (prior to 1.18) will also show `apps/v1beta2`.

{{% /alert %}}

Kyverno can also fetch data from other API locations such as `/version` and [aggregated APIs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/apiserver-aggregation/).

For example, fetching from `/version` might return something similar to what is shown below.

```sh
$ kubectl get --raw /version
{
  "major": "1",
  "minor": "23",
  "gitVersion": "v1.23.8+k3s1",
  "gitCommit": "53f2d4e7d80c09a7db1858e3f4e7ddfa13256c45",
  "gitTreeState": "clean",
  "buildDate": "2022-06-27T21:48:01Z",
  "goVersion": "go1.17.5",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

Fetching from an aggregated API, for example the `metrics.k8s.io` group, can be done with `/apis/metrics.k8s.io/<api_version>/<resource_type>` as shown below.

```sh
$ kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes | jq
{
  "kind": "NodeMetricsList",
  "apiVersion": "metrics.k8s.io/v1beta1",
  "metadata": {},
  "items": [
    {
      "metadata": {
        "name": "k3d-kyv180rc1-server-0",
        "creationTimestamp": "2022-09-11T13:37:39Z",
        "labels": {
          "beta.kubernetes.io/arch": "amd64",
          "beta.kubernetes.io/instance-type": "k3s",
          "beta.kubernetes.io/os": "linux",
          "egress.k3s.io/cluster": "true",
          "kubernetes.io/arch": "amd64",
          "kubernetes.io/hostname": "k3d-kyv180rc1-server-0",
          "kubernetes.io/os": "linux",
          "node-role.kubernetes.io/control-plane": "true",
          "node-role.kubernetes.io/master": "true",
          "node.kubernetes.io/instance-type": "k3s"
        }
      },
      "timestamp": "2022-09-11T13:37:24Z",
      "window": "10.059s",
      "usage": {
        "cpu": "298952967n",
        "memory": "1311340Ki"
      }
    }
  ]
}
```

### Handling collections

The API server response for a `HTTP GET` on a URL path that requests collections of resources will be an object with a list of items (resources).

Here is an example that fetches all Namespace resources:

```sh
kubectl get --raw /api/v1/namespaces | jq
```

{{% alert title="Tip" color="info" %}}
Use [`jq`](https://stedolan.github.io/jq/) to format output for readability.  
{{% /alert %}}

This will return a `NamespaceList` object with a property `items` that contains the list of Namespaces:

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

To process this data in JMESPath, reference the `items`. Here is an example which extracts a few metadata fields across all Namespace resources:

```sh
kubectl get --raw /api/v1/namespaces | kyverno jp "items[*].{name: metadata.name, creationTime: metadata.creationTimestamp}"
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

To find an item in the list you can use JMESPath filters. For example, this command will match a Namespace by its name:

```sh
kubectl get --raw /api/v1/namespaces | kyverno jp "items[?metadata.name == 'default'].{uid: metadata.uid, creationTimestamp: metadata.creationTimestamp}"
```

In addition to wildcards and filters, JMESPath has many additional powerful features including several useful functions. Be sure to go through the [JMESPath tutorial](https://jmespath.org/tutorial.html) and try the interactive examples in addition to the Kyverno JMESPath page [here](/docs/writing-policies/jmespath/).

### Sample Policy: Limit Services of type LoadBalancer in a Namespace

Here is a complete sample policy that limits each namespace to a single service of type `LoadBalancer`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: limits
spec:
  validationFailureAction: enforce
  rules:
  - name: limit-lb-svc
    match:
      any:
      - resources:
          kinds:
          - Service
    context:
    - name: serviceCount
      apiCall:
        urlPath: "/api/v1/namespaces/{{ request.namespace }}/services"
        jmesPath: "items[?spec.type == 'LoadBalancer'] | length(@)"    
    preconditions:
      any:
      - key: "{{ request.operation }}"
        operator: Equals
        value: CREATE
    validate:
      message: "Only one LoadBalancer service is allowed per namespace"
      deny:
        conditions:
          any:
          - key: "{{ serviceCount }}"
            operator: GreaterThan
            value: 1
```

This sample policy retrieves the list of Services in the Namespace and stores the count of type `LoadBalancer` in a variable called serviceCount. A `deny` rule is used to ensure that the count cannot exceed one.

## Variables from Image Registries

A context can also be used to store metadata on an OCI image by using the `imageRegistry` context type. By using this external data source, a Kyverno policy can make decisions based on details of the container image that occurs as part of an incoming resource.

For example, if you are using an `imageRegistry` like shown below:

```yaml
context: 
- name: imageData
  imageRegistry: 
    reference: "ghcr.io/kyverno/kyverno"
```

the output `imageData` variable will have a structure which looks like the following:

```json
{
    "image":         "ghcr.io/kyverno/kyverno",
    "resolvedImage": "ghcr.io/kyverno/kyverno@sha256:17bfcdf276ce2cec0236e069f0ad6b3536c653c73dbeba59405334c0d3b51ecb",
    "registry":      "ghcr.io",
    "repository":    "kyverno/kyverno",
    "identifier":    "latest",
    "manifest":      manifest,
    "configData":    config,
}
```

{{% alert title="Note" color="info" %}}
The `imageData` variable represents a "normalized" view of an image after any redirects by the registry are performed and internal modifications by Kyverno (Kyverno by default sets an empty registry to `docker.io` and an empty tag to `latest`). Most notably, this impacts [official images](https://docs.docker.com/docker-hub/official_images/) hosted on [Docker Hub](https://hub.docker.com/). Official images on Docker Hub are differentiated from other images in that their repository is prefixed by `library/` even if the image being pulled does not contain it. For example, pulling the [python](https://hub.docker.com/_/python) official image with `python:slim` results in the following fields of `imageData` being set:

```json
{
    "image":         "docker.io/python:slim",
    "resolvedImage": "index.docker.io/library/python@sha256:43705a7d3a22c5b954ed4bd8db073698522128cf2aaec07690a34aab59c65066",
    "registry":      "index.docker.io",
    "repository":    "library/python",
    "identifier":    "slim"
}
```
{{% /alert %}}

The `manifest` and `config` keys contain the output from `crane manifest <image>` and `crane config <image>` respectively.

For example, one could inspect the labels, entrypoint, volumes, history, layers, etc of a given image. Using the [crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) tool, show the config of the `ghcr.io/kyverno/kyverno:latest` image:

```json
$ crane config ghcr.io/kyverno/kyverno:latest | jq
{
  "architecture": "amd64",
  "config": {
    "User": "10001",
    "Env": [
      "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ],
    "Entrypoint": [
      "./kyverno"
    ],
    "WorkingDir": "/",
    "Labels": {
      "maintainer": "Kyverno"
    },
    "OnBuild": null
  },
  "created": "2022-02-04T08:57:38.818583756Z",
  "history": [
    {
      "created": "2022-02-04T08:57:38.454742161Z",
      "created_by": "LABEL maintainer=Kyverno",
      "comment": "buildkit.dockerfile.v0",
      "empty_layer": true
    },
    {
      "created": "2022-02-04T08:57:38.454742161Z",
      "created_by": "COPY /output/kyverno / # buildkit",
      "comment": "buildkit.dockerfile.v0"
    },
    {
      "created": "2022-02-04T08:57:38.802069102Z",
      "created_by": "COPY /etc/passwd /etc/passwd # buildkit",
      "comment": "buildkit.dockerfile.v0"
    },
    {
      "created": "2022-02-04T08:57:38.818583756Z",
      "created_by": "COPY /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ # buildkit",
      "comment": "buildkit.dockerfile.v0"
    },
    {
      "created": "2022-02-04T08:57:38.818583756Z",
      "created_by": "USER 10001",
      "comment": "buildkit.dockerfile.v0",
      "empty_layer": true
    },
    {
      "created": "2022-02-04T08:57:38.818583756Z",
      "created_by": "ENTRYPOINT [\"./kyverno\"]",
      "comment": "buildkit.dockerfile.v0",
      "empty_layer": true
    }
  ],
  "os": "linux",
  "rootfs": {
    "type": "layers",
    "diff_ids": [
      "sha256:180b308b8730567d2d06a342148e1e9d274c8db84113077cfd0104a7e68db646",
      "sha256:99187eab8264c714d0c260ae8b727c4d2bda3a9962635aaea67d04d0f8b0f466",
      "sha256:26d825f3d198779c4990007ae907ba21e7c7b6213a7eb78d908122e435ec9958"
    ]
  }
}
```

In the output above, we can see under `config.User` that the `USER` Dockerfile statement to run this container is `10001`. A Kyverno policy can be written to harness this information and perform, for example, a validation that the `USER` of an image is non-root.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: imageref-demo
spec:
  validationFailureAction: enforce
  rules:
  - name: no-root-images
    match:
      any:
      - resources:
          kinds:
          - Pod
    preconditions:
      all:
      - key: "{{request.operation}}"
        operator: NotEquals
        value: DELETE
    validate:
      message: "Images run as root are not allowed."  
      foreach:
      - list: "request.object.spec.containers"
        context: 
        - name: imageData
          imageRegistry: 
            reference: "{{ element.image }}"
        deny:
          conditions:
            any:
              - key: "{{ imageData.configData.config.User || ''}}"
                operator: Equals
                value: ""
```

In the above sample policy, a new context has been written named `imageData` which uses the `imageRegistry` type. The `reference` key is used to instruct Kyverno where the image metadata is stored. In this case, the location is the same as the image itself hence `element.image` where `element` is each container image inside of a Pod. The value can then be referenced in an expression, for example in `deny.conditions` via the key `{{ imageData.configData.config.User || ''}}`.

Using a sample "bad" resource to test which violates this policy, such as below, the Pod is blocked.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: badpod
spec:
  containers:
  - name: ubuntu
    image: ubuntu:latest
```

```sh
$ kubectl apply -f bad.yaml 
Error from server: error when creating "bad.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Pod/default/badpod was blocked due to the following policies

imageref-demo:
  no-root-images: 'validation failure: Images run as root are not allowed.'
```

By contrast, when using a "good" Pod, such as the Kyverno container image referenced above, the resource is allowed.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: goodpod
spec:
  containers:
  - name: kyverno
    image: ghcr.io/kyverno/kyverno:latest
```

```sh
$ kubectl apply -f good.yaml 
pod/goodpod created
```

The `imageRegistry` context type also has an optional property called `jmesPath` which can be used to apply a JMESPath expression to contents returned by `imageRegistry` prior to storing as the context value. For example, the below snippet stores the total size of an image in a context named `imageSize` by summing up all the constituent layers of the image as reported by its manifest (visible with, for example, `crane` by using the `crane manifest` command). The value of the context variable can then be evaluated in a later expression.

```yaml
context: 
  - name: imageSize
    imageRegistry: 
      reference: "{{ element.image }}"
      # Note that we need to use `to_string` here to allow kyverno to treat it like a resource quantity of type memory
      # the total size of an image as calculated by docker is the total sum of its layer sizes
      jmesPath: "to_string(sum(manifest.layers[*].size))"
```

To access images stored on private registries, see [using private registries](/docs/writing-policies/verify-images#using-private-registries)

For more examples of using an imageRegistry context, see the [samples page](/policies).

As of Kyverno 1.8.0, the policy-level setting `failurePolicy` when set to `Ignore` additionally means that failing calls to image registries will be ignored. This allows for Pods to not be blocked if the registry is offline, useful in situations where images already exist on the nodes.
