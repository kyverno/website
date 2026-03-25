---
title: External Data Sources
excerpt: Fetch data from ConfigMaps, the Kubernetes API server, other cluster services, and image registries for use in Kyverno policies.
sidebar:
  order: 100
---

The [Variables](/docs/policy-types/cluster-policy/variables) section discusses how variables can help create smarter and reusable policy definitions and introduced the concept of a rule [context](/docs/policy-types/cluster-policy/variables#variables-from-external-data-sources) that stores all variables.

This section provides details on using ConfigMaps, API calls, service calls, and image registries to reference external data as variables in policies.

## Variables from ConfigMaps

A [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) resource in Kubernetes is commonly used as a source of configuration details which can be consumed by applications. This data can be written in multiple formats, stored in a Namespace, and accessed easily. Kyverno supports using a ConfigMap as a data source for variables. When a policy referencing a ConfigMap resource is evaluated, the ConfigMap data is checked at that time ensuring that references to the ConfigMap are always dynamic. Should the ConfigMap be updated, subsequent policy lookups will pick up the latest data at that point.

In order to consume data from a ConfigMap in a rule, a context is required. For each rule you wish to consume data from a ConfigMap, you must define a context. The context data can then be referenced in the policy rule using JMESPath notation.

### Looking up ConfigMap values

A ConfigMap that is defined in a rule's context can be referenced using its unique name within the context. ConfigMap values can be referenced using a JMESPath style expression.

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

To refer to values from a ConfigMap inside a rule, define a context inside the rule with one or more ConfigMap declarations. Using the sample ConfigMap snippet referenced above, the below rule defines a context which references this specific ConfigMap by name.

```yaml
rules:
  - name: example-lookup
    # Define a context for the rule
    context:
      # A unique name for the context variable under which the below contents will later be accessible
      - name: dictionary
        configMap:
          # Name of the ConfigMap which will be looked up
          name: some-config-map
          # Namespace in which this ConfigMap is stored
          namespace: some-namespace
```

Based on the example above, we can now refer to a ConfigMap value using `{{dictionary.data.env}}`. The variable will be substituted with the value `production` during policy execution.

Put into context of a full policy, referencing a ConfigMap as a variable looks like the following.

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
      match:
        any:
          - resources:
              kinds:
                - Pod
      context:
        - name: dictionary
          configMap:
            name: some-config-map
            namespace: some-namespace
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              my-environment-name: '{{dictionary.data.env}}'
```

In the above ClusterPolicy, a mutate rule matches all incoming Pod resources and adds a label to them with the name of `my-environment-name`. Because we have defined a context which points to our earlier ConfigMap named `mycmap`, we can reference the value with the expression `{{dictionary.data.env}}`. A new Pod will then receive the label `my-environment-name=production`.

:::note[Note]
ConfigMap names and keys can contain characters that are not supported by [JMESPath](http://jmespath.org/), such as "-" (minus or dash) or "/" (slash). To evaluate these characters as literals, add double quotes to that part of the JMESPath expression as follows:

```
{{ "<name>".data."<key>" }}
```

See the [JMESPath page](/docs/policy-types/cluster-policy/jmespath#formatting) for more information on formatting.
:::

Kyverno also has the ability to cache ConfigMaps commonly used by policies to reduce the number of API calls made. This both decreases the load on the API server and increases the speed of policy evaluation. Assign the label `cache.kyverno.io/enabled: "true"` to any ConfigMap and Kyverno will automatically cache it. Policy decisions will fetch the data from cache rather than querying the API server. This feature may be disabled through an optional [container flag](/docs/installation/customization#container-flags) if desired.

### Handling ConfigMap Array Values

In addition to simple string values, Kyverno has the ability to consume array values from a ConfigMap stored as either JSON- or YAML-formatted values. Depending on how you choose to store an array, the policy which consumes the values in a variable context will need to be written accordingly.

For example, let's say you wanted to define a list of allowed roles in a ConfigMap. A Kyverno policy can refer to this list to deny a request where the role, defined as an annotation, does not match one of the values in the list.

Consider a ConfigMap with the following content written as a JSON array. You may also store array values in a YAML block scalar (in which case the [`parse_yaml()` filter](/docs/policy-types/cluster-policy/jmespath#parse_yaml) will be necessary in a policy definition).

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: roles-dictionary
  namespace: default
data:
  allowed-roles: '["cluster-admin", "cluster-operator", "tenant-admin"]'
```

Now that the array data is saved in the `allowed-roles` key, here is a sample policy which blocks a Deployment if the value of the annotation named `role` is not in the allowed list. Notice how the [`parse_json()` JMESPath filter](/docs/policy-types/cluster-policy/jmespath#parse_json) is used to interpret the value of the ConfigMap's `allowed-roles` key into an array of strings.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cm-array-example
spec:
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
        failureAction: Enforce
        message: 'The role {{ request.object.metadata.annotations.role }} is not in the allowed list of roles: {{ "roles-dictionary".data."allowed-roles" }}.'
        deny:
          conditions:
            any:
              - key: '{{ request.object.metadata.annotations.role }}'
                operator: AnyNotIn
                value: '{{ "roles-dictionary".data."allowed-roles" | parse_json(@) }}'
```

This rule denies the request for a new Deployment if the annotation `role` is not found in the array we defined in the earlier ConfigMap named `roles-dictionary`.

:::note[Note]
You may also notice that this sample uses variables from both AdmissionReview and ConfigMap sources in a single rule. This combination can prove to be very powerful and flexible in crafting useful policies.
:::

Once creating this sample policy, attempt to create a new Deployment where the annotation `role=super-user` and test the result.

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
          command: ['sleep', '9999']
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

For example, this command uses `kubectl` to fetch the list of Pods in a Namespace and then pipes the output to `kyverno jp` which counts the number of Pods:

```sh
kubectl get --raw /api/v1/namespaces/kyverno/pods | kyverno jp query "items | length(@)"
```

:::note[Tip]
Use `kubectl get --raw` and the [`kyverno jp`](/docs/kyverno-cli/reference/kyverno_jp) command to test API calls and parse results.
:::

The corresponding API call in Kyverno is defined as below. It uses a variable `{{request.namespace}}` to use the Namespace of the object being operated on, and then applies the same JMESPath to store the count of Pods in the Namespace in the context as the variable `podCount`. Variables may be used in both fields. This new resulting variable `podCount` can then be used in the policy rule.

```yaml
rules:
  - name: example-api-call
    context:
      - name: podCount
        apiCall:
          urlPath: '/api/v1/namespaces/{{request.namespace}}/pods'
          jmesPath: 'items | length(@)'
```

Calls to the Kubernetes API server may also perform `POST` operations in addition to `GET` which is the default method. The returned data from the API server can then be used for further policy decisions.

For example, this snippet below shows making a call to the [SubjectAccessReview API](https://kubernetes.io/docs/reference/kubernetes-api/authorization-resources/subject-access-review-v1/) to determine if an actor is authorized. Performing a `POST` operation requires specifying the `method` field and the `data` object with the contents of the request given as a list of key/value pairs.

```yaml
context:
  - name: subjectaccessreview
    apiCall:
      urlPath: /apis/authorization.k8s.io/v1/subjectaccessreviews
      method: POST
      data:
        - key: kind
          value: SubjectAccessReview
        - key: apiVersion
          value: authorization.k8s.io/v1
        - key: spec
          value:
            resource: 'namespace'
            resourceAttributes:
              namespace: '{{ request.namespace }}'
              verb: 'delete'
              group: ''
            user: '{{ request.userInfo.username }}'
```

The response from such a request will be the full JSON return and accessible under the variable `subjectaccessreview`.

### URL Paths

The Kubernetes API organizes resources under groups and versions. For example, the resource type `Deployment` is available in the API Group `apps` with a version `v1`.

The HTTP URL paths of the API calls are based on the group, version, and resource type as follows:

- `/apis/{GROUP}/{VERSION}/{RESOURCETYPE}`: get a collection of resources
- `/apis/{GROUP}/{VERSION}/{RESOURCETYPE}/{NAME}`: get a resource

For Namespaced resources, to get a specific resource by name or to get all resources in a Namespace, the Namespace name must also be provided as follows:

- `/apis/{GROUP}/{VERSION}/namespaces/{NAMESPACE}/{RESOURCETYPE}`: get a collection of resources in the namespace
- `/apis/{GROUP}/{VERSION}/namespaces/{NAMESPACE}/{RESOURCETYPE}/{NAME}`: get a resource in a namespace

For historic resources, the Kubernetes Core API is available under `/api/v1`. For example, to query all Namespace resources the path `/api/v1/namespaces` is used.

The Kubernetes API groups are defined in the [API reference documentation for v1.25](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/) and can also be retrieved via the `kubectl api-resources` command shown below:

```sh
$ kubectl api-resources
NAME                                SHORTNAMES   APIVERSION                              NAMESPACED   KIND
bindings                                         v1                                      true         Binding
componentstatuses                   cs           v1                                      false        ComponentStatus
configmaps                          cm           v1                                      true         ConfigMap
endpoints                           ep           v1                                      true         Endpoints
events                              ev           v1                                      true         Event
limitranges                         limits       v1                                      true         LimitRange
namespaces                          ns           v1                                      false        Namespace
nodes                               no           v1                                      false        Node
persistentvolumeclaims              pvc          v1                                      true         PersistentVolumeClaim
persistentvolumes                   pv           v1                                      false        PersistentVolume
pods                                po           v1                                      true         Pod
podtemplates                                     v1                                      true         PodTemplate
replicationcontrollers              rc           v1                                      true         ReplicationController
resourcequotas                      quota        v1                                      true         ResourceQuota
...
```

The `kubectl api-versions` command prints out the available versions for each API group. Here is a sample:

```sh
$ kubectl api-versions
admissionregistration.k8s.io/v1
admissionregistration.k8s.io/v1alpha1
apiextensions.k8s.io/v1
apiregistration.k8s.io/v1
apps/v1
authentication.k8s.io/v1
authorization.k8s.io/v1
autoscaling/v1
autoscaling/v2
batch/v1
certificates.k8s.io/v1
coordination.k8s.io/v1
...
```

You can use these commands together to find the URL path for resources, as shown below:

:::note[Tip]

To find the API group and version for a resource use `kubectl api-resources` to find the group and then `kubectl api-versions` to find the available versions.

This example finds the group of `Deployment` resources and then queries the version:

```sh
kubectl api-resources | grep deploy
```

The API group is shown in the third column of the output. You can then use the group name to find the version:

```sh
kubectl api-versions | grep apps
```

The output of this will be `apps/v1`.

:::

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

Query parameters are also accepted in the `urlPath` field. This allows, for example, making API calls with a label selector or a return limit which is beneficial in that some of the processing of these API calls may be offloaded to the Kubernetes API server rather than Kyverno having to process them in JMESPath statements. The following shows a context variable being set which uses an API call with label selector and limit queries.

```yaml
context:
  - name: serviceCount
    apiCall:
      urlPath: '/api/v1/namespaces/{{ request.namespace }}/services?labelSelector=foo=bar?limit=5'
      jmesPath: "items[?spec.type == 'LoadBalancer'] | length(@)"
```

Using query parameters has the added benefit that there will always be a response even if the query returns no results. This can be beneficial (and even necessary) in some cases where an API call to fetch an exact resource by name may fail because the resource does not exist.

For example, if the `foo` Service does not exist, an API call to return that specific resource will fail.

```sh
$ kubectl get --raw /api/v1/namespaces/default/services/foo
Error from server (NotFound): services "foo" not found
```

However, an API call with a query parameter against all Services will return successful but with an empty collection.

```sh
$ kubectl get --raw /api/v1/namespaces/default/services?fieldSelector=metadata.name=foo | jq
{
  "kind": "ServiceList",
  "apiVersion": "v1",
  "metadata": {
    "resourceVersion": "167567"
  },
  "items": []
}
```

Further information on handling collections is covered below.

### Handling collections

The API server response for a `HTTP GET` on a URL path that requests collections of resources will be an object with a list of items (resources).

Here is an example that fetches all Namespace resources:

```sh
kubectl get --raw /api/v1/namespaces | jq
```

:::note[Tip]
Use [`jq`](https://stedolan.github.io/jq/) to format output for readability.  
:::

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
        "finalizers": ["kubernetes"]
      },
      "status": {
        "phase": "Active"
      }
    }
    // ...
  ]
}
```

To process this data in JMESPath, reference the `items`. Here is an example which extracts a few metadata fields across all Namespace resources:

```sh
kubectl get --raw /api/v1/namespaces | kyverno jp query "items[*].{name: metadata.name, creationTime: metadata.creationTimestamp}"
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
  }
  //...
]
```

To find an item in the list you can use JMESPath filters. For example, this command will match a Namespace by its name:

```sh
kubectl get --raw /api/v1/namespaces | kyverno jp query "items[?metadata.name == 'default'].{uid: metadata.uid, creationTimestamp: metadata.creationTimestamp}"
```

In addition to wildcards and filters, JMESPath has many additional powerful features including several useful functions. Be sure to go through the [JMESPath tutorial](https://jmespath.org/tutorial.html) and try the interactive examples in addition to the Kyverno [JMESPath page](/docs/policy-types/cluster-policy/jmespath).

### Examples

Here is a complete sample policy that limits each Namespace to a single Service of type `LoadBalancer`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: limits
spec:
  rules:
    - name: limit-lb-svc
      match:
        any:
          - resources:
              kinds:
                - Service
              operations:
                - CREATE
      context:
        - name: serviceCount
          apiCall:
            urlPath: '/api/v1/namespaces/{{ request.namespace }}/services'
            jmesPath: "items[?spec.type == 'LoadBalancer'] | length(@)"
      validate:
        failureAction: Enforce
        message: 'Only one LoadBalancer service is allowed per namespace'
        deny:
          conditions:
            any:
              - key: '{{ serviceCount }}'
                operator: GreaterThan
                value: 1
```

This sample policy retrieves the list of Services in the Namespace and stores the count of type `LoadBalancer` in a variable called `serviceCount`. A `deny` rule is used to ensure that the count cannot exceed one.

## Variables from Service Calls

Similar to how Kyverno is able to call the Kubernetes API server to both `GET` and `POST` data for use in a context variable, Kyverno is also able to call any other service in the cluster. This feature is nested under the apiCall context type and builds upon it. See the section [above](#variables-from-kubernetes-api-server-calls) on Kubernetes API calls for more information.

By using the `apiCall.service` object, a call may be made to another URL to retrieve and store data. The fields `caBundle` and `url` are used to specify the CA bundle and URL, respectively, for the call. The fields `apiCall.urlPath` and `apiCall.service.url` are mutually exclusive; a call can only be to either the Kubernetes API or some other service. At this time, authentication as part of these service calls is not supported. The response from a Service call must only be JSON.

For example, the following policy makes a `POST` request to another Kubernetes Service accessible at `http://sample.kyverno-extension/check-namespace` and sends it the data `{"name":"foonamespace"}` when a ConfigMap is created in the `foonamespace` Namespace. The JSON result Kyverno receives is stored in the context called `result`. The value of `result` is JSON where the key `allowed` is either `true` or `false`. The request is blocked if the value is `false`.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-namespaces
spec:
  rules:
    - name: call-extension
      match:
        any:
          - resources:
              kinds:
                - ConfigMap
      context:
        - name: result
          apiCall:
            method: POST
            data:
              - key: namespace
                value: '{{request.namespace}}'
            service:
              url: http://sample.kyverno-extension/check-namespace
              caBundle: |-
                -----BEGIN CERTIFICATE-----
                <snip>
                -----END CERTIFICATE-----
      validate:
        failureAction: Enforce
        message: 'namespace {{request.namespace}} is not allowed'
        deny:
          conditions:
            all:
              - key: '{{ result.allowed }}'
                operator: Equals
                value: false
```

## Global Context

Global Context allows users to cache Kubernetes resources or the results of external API calls for later reference within policies. It provides a mechanism to efficiently retrieve and utilize data across policies, enhancing flexibility and performance in policy enforcement. This new Global Context ability joins the existing [ConfigMap caching](#variables-from-configmaps) ability.

Global Context Entries are declared globally using a new `GlobalContextEntry` Custom Resource and referenced as part of a policy context. There are two types of Global Context Entries, a Kubernetes resource entry and an API call entry.

### Kubernetes Resource

A Kubernetes resource Global Context allows you to easily reference a specific kind of Kubernetes resource. Only a single kind may be referenced with the option of specifying both Namespaced and global resources.

This GlobalContextEntry caches all Deployment resources in the `fitness` Namespace.

```yaml
apiVersion: kyverno.io/v2alpha1
kind: GlobalContextEntry
metadata:
  name: deployments
spec:
  kubernetesResource:
    group: apps
    version: v1
    resource: deployments
    namespace: fitness
```

The resource value must be the pluralized, lower-case form ("deployments" and not "Deployment"). Omitting the `namespace` field for Namespaced resources will result in a cache entry being built for all such resources in the cluster. For cluster-scoped resources, omit the `namespace` field.

Only a single Kubernetes resource kind may be specified per GlobalContextEntry. Internally, Kyverno uses informers to automatically watch and build an updated cache whenever the target resource kind changes.

Once the `deployments` GlobalContextEntry has been created, it may be referenced in a Kyverno policy using a `context` of the type `globalReference` where the `name` is the same name as the GlobalContextEntry Custom Resource.

```yaml
context:
  - name: deployments
    globalReference:
      name: deployments
```

In the case of a Kubernetes resource type of GlobalContextEntry, the value will be an array of objects as shown below.

```json
[
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "annotations": {
        "deployment.kubernetes.io/revision": "1"
      }
    }
    //...
  },
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "annotations": {
        "deployment.kubernetes.io/revision": "1"
      }
    }
    //...
  }
]
```

### API Call

An API call GlobalContextEntry defines either an API call to an external service or a raw call to the Kubernetes API. The latter is useful over a Kubernetes resource GlobalContextEntry when you wish to reduce the amount of data populated into the cache by using query parameters or when needing to perform a POST rather than GET.

Below shows a similar example from the Kubernetes resource type previously but using a labelSelector to limit the number of resources returned into the cache. The contents will be refreshed according to the value of the `refreshInterval` field.

```yaml
apiVersion: kyverno.io/v2alpha1
kind: GlobalContextEntry
metadata:
  name: deployments
spec:
  apiCall:
    urlPath: '/apis/apps/v1/namespaces/fitness/deployments?labelSelector=app=blue'
    refreshInterval: 10s
```

The data returned from an `apiCall` GlobalContextEntry to the Kubernetes API is the same data structure returned from a context entry of type `apiCall` referenced [above](#variables-from-kubernetes-api-server-calls). Note that specifically this means the contents will be wrapped in `items[]` and not `[]` as is the case with a Kubernetes resource type.

A cache entry may also be created for external services as well specifying an optional CA bundle to establish trust.

```yaml
apiVersion: kyverno.io/v2alpha1
kind: GlobalContextEntry
metadata:
  name: redisdata
spec:
  apiCall:
    method: GET
    refreshInterval: 1m
    service:
      url: https://redis.myns.svc:6379
      caBundle: |-
        -----BEGIN CERTIFICATE-----
        MIIBdjCCAR2gAwIBAgIBADAKBggqhkjOPQQDAjAjMSEwHwYDVQQDDBhrM3Mtc2Vy
        <snip>
        W/LgVuvZmucCIBcETS4DIw2pWAfeKRDaEOi2YsJoDpWd7lFLQBUbe4G7
        -----END CERTIFICATE-----
```

:::note[Note]
`apiCall` GlobalContextEntries are implemented by periodically making a call to the specified endpoint every `refreshInterval`, thus beware of stale data.
:::

Reference the GlobalContextEntry in a policy using the `context.globalReference` type. Shown below is an example referencing the `redisdata` cache entry and applying a JMESPath filter to its contents. The resulting `location` variable will be the result of the `address.city` filter applied to the contents of `redisdata`.

```yaml
context:
  - name: location
    globalReference:
      name: redisdata
      jmesPath: address.city
```

The data returned by GlobalContextEntries may vary depending on whether it is a Kubernetes resource or an API call. Consequently, the JMESPath expression used to manipulate the data may differ as well. Ensure you use the appropriate JMESPath expression based on the type of data being accessed to ensure accurate processing within policies.

To use Global Contexts with the Kyverno CLI, you can use the Values file to inject these global context entries into your policy evaluation. This allows you to simulate different scenarios and test your policies with various global context values without modifying the actual `GlobalContextEntry` resources in your cluster. Refer to it here: [kyverno apply](/docs/kyverno-cli/reference/kyverno_apply).

:::caution[Warning]
GlobalContextEntries must be in a healthy state (i.e., there is a response received from the remote endpoint) in order for the policies which reference them to be considered healthy. A GlobalContextEntry which is in a `not ready` state will cause any/all referenced policies to also be in a similar state and therefore will not be processed. Creation of a policy referencing a GlobalContextEntry which either does not exist or is not ready will print a warning notifying users.
:::

#### Default values for API calls

In the case where the api server returns an error, `default` can be used to provide a fallback value for the api call context entry. The following example shows how to add default value to context entries:

```yaml
context:
  - name: currentnamespace
    apiCall:
      urlPath: '/api/v1/namespaces/{{ request.namespace }}'
      jmesPath: metadata.name
      default: default
```

## Variables from Image Registries

A context can also be used to store metadata on an OCI image by using the `imageRegistry` context type. By using this external data source, a Kyverno policy can make decisions based on details of the container image that occurs as part of an incoming resource.

For example, if you are using an `imageRegistry` like shown below:

```yaml
context:
  - name: imageData
    imageRegistry:
      reference: 'ghcr.io/kyverno/kyverno'
```

the output `imageData` variable will have a structure which looks like the following:

```json
{
  "image": "ghcr.io/kyverno/kyverno",
  "resolvedImage": "ghcr.io/kyverno/kyverno@sha256:17bfcdf276ce2cec0236e069f0ad6b3536c653c73dbeba59405334c0d3b51ecb",
  "registry": "ghcr.io",
  "repository": "kyverno/kyverno",
  "identifier": "latest",
  "manifestList": [
    /* manifestList */
  ],
  "manifest": {
    /* manifest */
  },
  "configData": {
    /* config */
  }
}
```

:::note[Note]
The `imageData` variable represents a "normalized" view of an image after any redirects by the registry are performed and internal modifications by Kyverno (Kyverno by default sets an empty registry to `docker.io` and an empty tag to `latest`). Most notably, this impacts [official images](https://docs.docker.com/docker-hub/official_images/) hosted on [Docker Hub](https://hub.docker.com/). Official images on Docker Hub are differentiated from other images in that their repository is prefixed by `library/` even if the image being pulled does not contain it. For example, pulling the [python](https://hub.docker.com/_/python) official image with `python:slim` results in the following fields of `imageData` being set:

```json
{
  "image": "docker.io/python:slim",
  "resolvedImage": "index.docker.io/library/python@sha256:43705a7d3a22c5b954ed4bd8db073698522128cf2aaec07690a34aab59c65066",
  "registry": "index.docker.io",
  "repository": "library/python",
  "identifier": "slim"
}
```

:::

The `manifestList`, `manifest` and `config` keys contain the output from `crane manifest <image>` and `crane config <image>` respectively.

For example, one could inspect the labels, entrypoint, volumes, history, layers, etc of a given image. Using the [crane](https://github.com/google/go-containerregistry/tree/main/cmd/crane) tool, show the config of the `ghcr.io/kyverno/kyverno:latest` image:

```sh
$ crane config ghcr.io/kyverno/kyverno:latest | jq
```

```json
{
  "architecture": "amd64",
  "author": "github.com/ko-build/ko",
  "created": "2023-01-08T00:10:08Z",
  "history": [
    {
      "author": "apko",
      "created": "2023-01-08T00:10:08Z",
      "created_by": "apko",
      "comment": "This is an apko single-layer image"
    },
    {
      "author": "ko",
      "created": "0001-01-01T00:00:00Z",
      "created_by": "ko build ko://github.com/kyverno/kyverno/cmd/kyverno",
      "comment": "kodata contents, at $KO_DATA_PATH"
    },
    {
      "author": "ko",
      "created": "0001-01-01T00:00:00Z",
      "created_by": "ko build ko://github.com/kyverno/kyverno/cmd/kyverno",
      "comment": "go build output, at /ko-app/kyverno"
    }
  ],
  "os": "linux",
  "rootfs": {
    "type": "layers",
    "diff_ids": [
      "sha256:c9770b71bc04d50fb006eaacea8180b5f7c0fc72d16618590ec5231f9cec2525",
      "sha256:ffe56a1c5f3878e9b5f803842adb9e2ce81584b6bd027e8599582aefe14a975b",
      "sha256:de3816af2ab66f6b306277c83a7cc9af74e5b0e235021a37f2fc916882751819"
    ]
  },
  "config": {
    "Entrypoint": ["/ko-app/kyverno"],
    "Env": [
      "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/ko-app",
      "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt",
      "KO_DATA_PATH=/var/run/ko"
    ],
    "User": "65532"
  }
}
```

In the output above, we can see under `config.User` that the `USER` Dockerfile statement to run this container is `65532`. A Kyverno policy can be written to harness this information and perform, for example, a validation that the `USER` of an image is non-root.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: imageref-demo
spec:
  rules:
    - name: no-root-images
      match:
        any:
          - resources:
              kinds:
                - Pod
              operations:
                - CREATE
                - UPDATE
      validate:
        failureAction: Enforce
        message: 'Images run as root are not allowed.'
        foreach:
          - list: 'request.object.spec.containers'
            context:
              - name: imageData
                imageRegistry:
                  reference: '{{ element.image }}'
            deny:
              conditions:
                any:
                  - key: "{{ imageData.configData.config.User || ''}}"
                    operator: Equals
                    value: ''
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
      reference: '{{ element.image }}'
      # Note that we need to use `to_string` here to allow kyverno to treat it like a resource quantity of type memory
      # the total size of an image as calculated by docker is the total sum of its layer sizes
      jmesPath: 'to_string(sum(manifest.layers[*].size))'
```

To access images stored on private registries, see [using private registries](/docs/policy-types/cluster-policy/verify-images/sigstore#using-private-registries)

For more examples of using an imageRegistry context, see the [samples page](/policies/).

The policy-level setting `failurePolicy` when set to `Ignore` additionally means that failing calls to image registries will be ignored. This allows for Pods to not be blocked if the registry is offline, useful in situations where images already exist on the nodes.

## Service API Calls with Custom HTTP Headers

Kyverno now supports including custom HTTP headers when making API calls to external services. This enhancement allows users to add extra metadata—such as authentication tokens, user agents, or any other header information—that may be required by the external service.

## Feature Overview

Prior to this update, API calls made by Kyverno policies did not allow the inclusion of extra HTTP headers. With this feature, you can now specify a `headers` field under the `service` configuration in an API call, making your external requests more flexible and secure.

## Example Policy Configuration

```yaml
context:
  - name: result
    apiCall:
      method: POST
      data:
        - key: foo
          value: bar
        - key: namespace
          value: '{{ `{{ request.namespace }}` }}'
      service:
        url: http://my-service.svc.cluster.local/validation
        headers:
          - key: 'UserAgent'
            value: 'Kyverno Policy XYZ'
          - key: 'Authorization'
            value: 'Bearer {{ MY_SECRET }}'
```

## Explanation

- **service.url**: Specifies the endpoint of the external service.
- **service.headers**: A new field that accepts an array of key-value pairs. Each pair represents a custom HTTP header to include in the API request.
  - **UserAgent**: Can be used to identify the client or policy making the call.
  - **Authorization**: Typically used to pass authentication tokens or credentials.
- **Variable Substitution**: You can dynamically include values (e.g., `{{ MY_SECRET }}`) in your headers using Kyverno's variable substitution mechanism.
