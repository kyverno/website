---
title: Variables and External Data Sources
description: >
    Use request data, ConfigMaps, and built-in variables in policy rules.
weight: 6
---

It is sometimes necessary to refer to contents or values of other fields and objects in a given rule in order to make those rules more "intelligent" and applicable. In order to do so, Kyverno allows the use of three different types of variables which can be used in various portions of a rule. The sources of these types of variables are ConfigMap resources, [AdmissionReview](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#webhook-request-and-response) request data, and manifest lookups.

In order to refer to both ConfigMap data values as well as [AdmissionReview](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#webhook-request-and-response) request data as variables, Kyverno uses the [JMESPath](http://jmespath.org/) notation format. Using JMESPath (pronounced "James path"), values from these sources are written in the format of `{{key1.key2.key3}}`. The policy engine will substitute any values with the format `{{ <JMESPath> }}` with the variable value before processing the rule.

{{% alert title="Note" color="info" %}}
Variables are currently not supported on `match` or `exclude` statements within a rule.
{{% /alert %}}


## Variables from AdmissionReview request data

Kyverno operates as a webhook inside Kubernetes. Whenever a new request is made to, for example, create a Pod, the API server sends this information to the webhooks registered to listen for the creation of Pod resources. This incoming data to a webhook is known as [`AdmissionReview`](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#webhook-request-and-response) request data. There are four broad categories of data available in any AdmissionReview: new resource info, old resource info, user info, and operation.

The following `AdmissionReview` request data is available to Kyverno for use in a `rule` statement.

- New resource: `{{request.object}}`
- UserInfo: `{{request.userInfo}}`
- Operation: `{{request.operation}}`
- Old resource: `{{request.oldObject}}`

The `request.object` object contains information on the request itself, for example the name, metadata, and spec of the resource.

The `request.userInfo` object contains information on who/what submitted the request which includes the `groups` and `username` keys.

The `request.operation` object contains the type of action being performed. Values are either `CREATE`, `UPDATE`, or `DELETE`.

The `request.oldObject` object is a representation of an existing resource that is being modified, commonly used during `UPDATE` operations.

Here are some examples of looking up this data:

1. Reference a resource name (type string)

`{{request.object.metadata.name}}`

2. Reference the metadata (type object)

`{{request.object.metadata}}`

3. Reference the name of a new Namespace resource being created

`{{request.object.name}}`

4. Reference the name of a user who submitted a request

`{{request.userInfo.username}}`

Variables from the `AdmissionReview` can also be combined with user-defined strings to create values for messages and other fields.

1. Build a name from multiple variables (type string)

`"ns-owner-{{request.object.metadata.namespace}}-{{request.userInfo.username}}-binding"`

### Pre-defined Variables

Kyverno automatically creates a couple useful variables and makes them available within rules:

1. `serviceAccountName`: the "userName" which is the last part of a service account (i.e. without the prefix `system:serviceaccount:<namespace>:`). For example, when processing a request from `system:serviceaccount:nirmata:user1` Kyverno will store the value `user1` in the variable `serviceAccountName`.

2. `serviceAccountNamespace`: the "namespace" part of the serviceAccount. For example, when processing a request from `system:serviceaccount:nirmata:user1` Kyverno will store `nirmata` in the variable `serviceAccountNamespace`.

### Consume `AdmissionReview` data in a Policy

Let's look at an example of how this AdmissionReview data can be used in Kyverno policies.

In the below `ClusterPolicy`, we wish to know which account created a given Pod resource. We can use information from the `AdmissionReview` contents, specifically the `username` key, to write this information out in the form of a label. Apply the following sample.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: who-created-this
spec:
  background: false
  rules:
  - name: who-created-this
    match:
      resources:
        kinds:
        - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            created-by: "{{request.userInfo.username}}"
```

This sample will mutate all incoming Pod creation requests with a label named `created-by` and the value of the authenticated user based on their `kubeconfig`.

Create a simple Pod resource.

```sh
kubectl run busybox --image busybox:1.28
```

Now `get` the newly-created `busybox` Pod.

```sh
kubectl get po busybox --show-labels
```
```
NAME       READY   STATUS    RESTARTS   AGE   LABELS
busybox   0/1     Pending   0          25m   created-by=kubernetes-admin,run=busybox
```

In the output, we can clearly see the value of our `created-by` label is `kubernetes-admin` which, in this case, is the user who created the Pod.

## Variables from ConfigMap resources

A [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) resource in Kubernetes is often a source of configuration details which can be consumed by applications. This data can be written in multiple formats, stored in a Namespace, and accessed easily. Kyverno supports using a ConfigMap as a data source for variables, either as key/value pair data or multi-line strings. When a policy referencing a ConfigMap resource is evaluated, the ConfigMap data is checked at that time ensuring that references to the `ConfigMap` are always dynamic. Should the ConfigMap be updated later, subsequent policy lookups will pick up the data at that point.

In order to consume data from a ConfigMap in a `rule`, a `context` is required. For each `rule` you wish to consume data from a ConfigMap, you must define a `context`. The context data can then be referenced in the policy `rule` using JMESPath notation.

### Defining a `context` for consumption of ConfigMap values

Consider a simple ConfigMap definition like so.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mycmap
  namespace: default
data:
  env: production
```

To refer to values from a ConfigMap inside a `rule`, define a `context` inside the `rule` with one or more ConfigMap declarations. Using the sample ConfigMap snippet referenced above, the below `rule` defines a `context` which references this specific ConfigMap by name.

```yaml
rules:
  - name: example-configmap-lookup
    # Create a context to invoke a ConfigMap object
    context:
    # Unique name to identify this reference to a ConfigMap
    - name: dictionary
      configMap:
        # Name of the ConfigMap which will be looked up
        name: mycmap
        # Namespace in which this ConfigMap is stored
        namespace: test
```

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

### Mixing ConfigMap with AdmissionReview data (Nesting)

It is also possible to nest JMESPath expression inside one another when mixing data sourced from a ConfigMap and AdmissionReview. By including one JMESPath expression inside the other, Kyverno will first substitute the inner expression before building the outer one as seen in the below example.

{{% alert title="Note" color="info" %}}
Nesting JMESPath expressions is supported starting in Kyverno 1.3.0.
{{% /alert %}}

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: resource-annotater
spec:
  background: false
  rules:
  - name: add-resource-annotations
    context:
    - name: LabelsCM
      configMap:
        name: resource-annotater-reference
        namespace: default
    match:
      resources:
        kinds:
        - Pod
    mutate:
      overlay:
        metadata:
          annotations:
            foo: "{{LabelsCM.data.{{ request.object.metadata.labels.app }}}}"
```

In this example, AdmissionReview data is first collected in the inner expression in the form of `{{request.object.metadata.labels.app}}` while the outer expression is built from a ConfigMap context named `LabelsCM`.

## Variables from Policy manifests

As the third type of variable source, Kyverno has the ability to refer to other fields populated in a Policy manifest. We refer to these as manifest lookups. This can be a useful way of setting a value by referring to the value of another field (or multiple) without having to explicitly define it.

### Referencing values in a manifest lookup

In order for Kyverno to refer to these existing values in a manifest, it uses the notation `$(./../key_1/key_2)`. This may look familiar as it is essentially the same way Linux/Unix systems refer to relative paths. For example, consider the policy manifest snippet below.

```yaml
validationFailureAction: enforce
rules:
- name: check-tcpSocket
  match:
    resources:
      kinds:
      - Pod
  validate:
    message: "Port number for the livenessProbe must be less than that of the readinessProbe."
    pattern:
      spec:
        ^(containers):
        - livenessProbe:
            tcpSocket:
              port: "$(./../../../readinessProbe/tcpSocket/port)"
          readinessProbe:
            tcpSocket:
              port: "3000"
```

In this above example, for any containers found in a Pod spec, the field `readinessProbe.tcpSocket.port` must be `3000` and the field `livenessProbe.tcpSocket.port` must be the same value. The lookup expression can be thought of as a `cd` back three levels and down into the `readinessProbe` object.

Operators also work on manifest lookup variables as well so the previous snippet could be modified as such.

```yaml
- livenessProbe:
    tcpSocket:
      port: "$(<./../../../readinessProbe/tcpSocket/port)"
  readinessProbe:
    tcpSocket:
      port: "3000"
```

In this case, the field `livenessProbe.tcpSocket.port` must now be **less** than the value specified in `readinessProbe.tcpSocket.port`.

For more information on operators see the [Operators](/docs/writing-policies/validate/#operators) section.
