---
title: Variables
description: >
  Defining and using variables in policies from multiple sources.
weight: 90
---

Variables make policies smarter and reusable by enabling references to data in the policy definition, the [admission review request](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#webhook-request-and-response), and external data sources like ConfigMaps, the Kubernetes API Server, OCI image registries, and even external service calls.

Variables are stored as JSON and Kyverno supports using [JMESPath](http://jmespath.org/) (pronounced "James path") to select and transform JSON data. With JMESPath, values from data sources are referenced in the format of `{{key1.key2.key3}}`. For example, to reference the name of an new/incoming resource during a `kubectl apply` action such as a Namespace, you would write this as a variable reference: `{{request.object.metadata.name}}`. The policy engine will substitute any values with the format `{{ <JMESPath> }}` with the variable value before processing the rule. For a page dedicated to exploring JMESPath's use in Kyverno see [here](/docs/writing-policies/jmespath/). Variables may be used in most places in a Kyverno rule or policy with one exception being in `match` or `exclude` statements.

## Pre-defined Variables

Kyverno automatically creates a few useful variables and makes them available within rules:

1. `serviceAccountName`: the "userName" which is the last part of a ServiceAccount (i.e. without the prefix `system:serviceaccount:<namespace>:`). For example, when processing a request from `system:serviceaccount:nirmata:user1` Kyverno will store the value `user1` in the variable `serviceAccountName`.

2. `serviceAccountNamespace`: the "namespace" part of the ServiceAccount. For example, when processing a request from `system:serviceaccount:nirmata:user1` Kyverno will store `nirmata` in the variable `serviceAccountNamespace`.

3. `request.roles`: a list of roles stored in an array the given account may have. For example, `["foo:dave"]`.

4. `request.clusterRoles`: a list of cluster roles stored in an array. For example, `["dave-admin","system:basic-user","system:discovery","system:public-info-viewer"]`

5. `images`: a map of container image information, if available. See [Variables from container images](#variables-from-container-images) for more information.

{{% alert title="Note" color="warning" %}}
Variables such as `serviceAccountName`, `serviceAccountNamespace`, `request.roles`, and `request.clusterRoles` may not occur in rules in which the parent policy is set for background scanning (`spec.background: true`) as this information is not available for existing resources. To use any of these variables you must disable background scanning in the policy.
{{% /alert %}}

## Variables from policy definitions

Kyverno policy definitions can refer to other fields in the policy definition as a form of "shortcut". This can be a useful way to analyze and compare values without having to explicitly define them.

In order for Kyverno to refer to these existing values in a manifest, it uses the notation `$(./../key_1/key_2)`. This may look familiar as it is essentially the same way Linux/Unix systems refer to relative paths. For example, consider the policy manifest snippet below.

```yaml
validationFailureAction: Enforce
rules:
- name: check-tcpSocket
  match:
    any:
    - resources:
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

## Escaping Variables

In some cases, you wish to write a rule containing a variable for action on by another program or process flow and not for Kyverno's use. For example, with the variables in `$()` notation, these can be escaped with a leading backslash (`\`) and Kyverno will not attempt to substitute values. Variables written in JMESPath notation can also be escaped using the same syntax, for example `\{{ request.object.metadata.name }}`.

In the below policy, the value of `OTEL_RESOURCE_ATTRIBUTES` contains references to other environment variables which will be quoted literally as, for example, `$(POD_NAMESPACE)`.

```yaml
apiVersion: kyverno.io/v1
kind: Policy
metadata:
  name: add-otel-resource-env
  namespace: foobar
spec:
  background: false
  rules:
  - name: imbue-pod-spec
    match:
      any:
      - resources:
          kinds:
          - v1/Pod
    mutate:
      patchStrategicMerge:
        spec:
          containers:
          - (name): "?*"
            env:
            - name: NODE_NAME
              value: "mutated_name"
            - name: POD_IP_ADDRESS
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: POD_SERVICE_ACCOUNT
              valueFrom:
                fieldRef:
                  fieldPath: spec.serviceAccountName
            - name: OTEL_RESOURCE_ATTRIBUTES
              value: >-
                k8s.namespace.name=\$(POD_NAMESPACE),
                k8s.node.name=\$(NODE_NAME),
                k8s.pod.name=\$(POD_NAME),
                k8s.pod.primary_ip_address=\$(POD_IP_ADDRESS),
                k8s.pod.service_account.name=\$(POD_SERVICE_ACCOUNT),
                rule_applied=$(./../../../../../../../../name)
```

Using a Pod definition as below, this can be tested.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-env-vars
spec:
  containers:
  - name: test-container
    image: busybox
    command: ["sh", "-c"]
    args:
    - while true; do
      echo -en '\n';
      printenv OTEL_RESOURCE_ATTRIBUTES;
      sleep 10;
      done;
    env:
    - name: NODE_NAME
      value: "node_name"
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: POD_IP_ADDRESS
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
  restartPolicy: Never
```

The result of the mutation of this Pod with respect to the `OTEL_RESOURCE_ATTRIBUTES` environment variable will be as follows.

```yaml
- name: OTEL_RESOURCE_ATTRIBUTES
      value: k8s.namespace.name=$(POD_NAMESPACE), k8s.node.name=$(NODE_NAME), k8s.pod.name=$(POD_NAME),
        k8s.pod.primary_ip_address=$(POD_IP_ADDRESS), k8s.pod.service_account.name=$(POD_SERVICE_ACCOUNT),
        rule_applied=imbue-pod-spec
```

### Variables in Helm

Both Kyverno and Helm use Golang-style variable substitution syntax and, as a result, Kyverno policies containing variables deployed through Helm may need to be "wrapped" to avoid Helm interpreting them as Helm variables.

Because Helm executes its templating routine prior to Kyverno, a Kyverno policy with a variable `{{ request.userInfo.username }}` must be padded with Helm's templating so that the resulting value, after the chart is deployed, remains `{{ request.userInfo.username }}`. Wrap the Kyverno variables in following way shown below:

```
{{`{{ request.userInfo.username }}`}}
```

For Kyverno variables which use more complex JMESPath expressions including [existence checks](/docs/writing-policies/jmespath/#non-existence-checks), elements such as empty objects or arrays may also need to be escaped even within the overall expression. For example, the value of the below `value` field

```
value: "{{ element.securityContext.capabilities.drop[].to_upper(@) || `[]` }}"
```

would need to become

```
value: {{ `"{{ element.securityContext.capabilities.drop[].to_upper(@) || `}}`[]`{{` }}"` }}
```

in order to render properly.

## Variables from admission review requests

Kyverno operates as a webhook inside Kubernetes. Whenever a new request is made to the Kubernetes API server, for example to create a Pod, the API server sends this information to the webhooks registered to listen to the creation of Pod resources. This incoming data to a webhook is passed as a [`AdmissionReview`](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#webhook-request-and-response) object. There are four commonly used data properties available in any AdmissionReview request:

- `{{request.operation}}`: the type of API action being performed (`CREATE`, `UPDATE`, `DELETE`, or `CONNECT`).
- `{{request.object}}`: the object being created or modified. It is null for `DELETE` requests.
- `{{request.oldObject}}`: the object being modified. It is null for `CREATE` and `CONNECT` requests.
- `{{request.userInfo}}`: contains information on who/what submitted the request which includes the `groups` and `username` keys.
- `{{request.namespace}}`: the Namespace of the object subject to the operation.

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

`"ns-owner-{{request.namespace}}-{{request.userInfo.username}}-binding"`

Let's look at an example of how this AdmissionReview data can be used in Kyverno policies.

In the below `ClusterPolicy`, we wish to know which account created a given Pod resource. We can use information from the `AdmissionReview` contents, specifically the `username` key, to write this information out in the form of an annotation. Apply the following sample.

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
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          annotations:
            created-by: "{{request.userInfo.username}}"
```

This sample will mutate all incoming Pod creation requests with an annotation named `created-by` and the value of the authenticated user based on their `kubeconfig`.

Create a simple Pod resource.

```sh
kubectl run busybox --image busybox:1.28
```

Now `get` the newly-created `busybox` Pod.

```sh
kubectl get po busybox -o jsonpath='{.metadata.annotations}'
{"created-by":"kubernetes-admin"}
```

In the output, we can clearly see the value of our `created-by` annotation is `kubernetes-admin` which, in this case, is the user who created the Pod.

## Variables from container images

Kyverno extracts image data from the AdmissionReview request and makes this available as a variable named `images` of type map in the rule context. The following variables are set under `images`:

- `registry`
- `path`
- `name`
- `tag`
- `digest`
- `reference`
- `referenceWithTag`

Here is an example:

```json
{
  "containers": {
    "tomcat": {
      "registry": "https://ghcr.io",
      "path": "tomcat",
      "name": "tomcat",
      "tag": "9"
    }
  },
  "initContainers": {
    "vault": {
      "registry": "https://ghcr.io",
      "path": "vault",
      "name": "vault",
      "tag": "v3"
    }
  }
}
```

Whenever an AdmissionReview request has `containers`, `initContainers`, or `ephemeralContainers` defined, the `images` variable can be referenced as shown in the examples below. `tag` and `digest` are mutually exclusive as an image may only define one.

Reference the image properties of container `tomcat`:

1. Reference the registry URL

`{{images.containers.tomcat.registry}}`

2. Reference the path to the image

`{{images.containers.tomcat.path}}`

3. Reference the image name

`{{images.containers.tomcat.name}}`

4. Reference the image tag

`{{images.containers.tomcat.tag}}`

5. Reference the digest

`{{images.containers.tomcat.digest}}`

6. Reference the readable reference for the image

`{{images.containers.tomcat.reference}}`

7. Reference the readable reference for the image along with the image tag 

`{{images.containers.tomcat.referenceWithTag}}`

Reference the image properties of initContainer `vault`:

1. Reference the registry URL

`{{images.initContainers.vault.registry}}`

2. Reference the path to the image

`{{images.initContainers.vault.path}}`

3. Reference the image name

`{{images.initContainers.vault.name}}`

4. Reference the image tag

`{{images.initContainers.vault.tag}}`

5. Reference the digest

`{{images.initContainers.vault.digest}}`

6. Reference the readable reference for the image

`{{images.initContainers.vault.reference}}`

7. Reference the readable reference for the image along with image tag 

`{{images.initContainers.vault.referenceWithTag}}`

This same pattern and image variable arrangement also works for ephemeral containers.

Kyverno by default sets an empty registry to `docker.io` and an empty tag to `latest`. The default registry and whether it should be substituted are configurable options defined in [Kyverno's ConfigMap](/docs/installation/customization/#configmap-keys).

{{% alert title="Note" color="info" %}}
Note that certain characters must be escaped for JMESPath processing (ex. `-` in the case of container's name), escaping can be done by using double quotes with double escape character `\`, for example, `{{images.containers.\"my-container\".tag}}`. For more detailed information, see the JMESPath [page on formatting](/docs/writing-policies/jmespath/#formatting).
{{% /alert %}}

You can also fetch image properties of all containers for further processing. For example, `{{ images.containers.*.name }}` creates a string list of all image names.

## Inline Variables

Variables may be defined in a `context` for consumption by Kyverno rules. This can be as simple as a static value, another variable, or a nested object. Variables may also be redefined by using the same variable name. The last value that is set is used. The below sets a context variable with a value of `foo`.

```yaml
    context:
    # A unique name for the for the variable 
    # if the user redeclares a variable with the same name it should be re-assigned
    - name: foodata
      variable:
        # value defines the value that the variable must have, it may contain jmespath variables or any yaml object that can be represented as a json object.
        # value, default, and jmespath are optional but either value or jmespath must be defined.
        value: "foo"
```

This snippet sets a context variable to the value of `request.object.metadata.name`. If the `value` field is not defined, the contents of `jmesPath` will act on the entire context.

```yaml  - name: defined-jmespath
context:
- name: objName
  variable:
    jmesPath: request.object.metadata.name
```

And below allows for an inline variable with a nested object as well as a default value for that object if it cannot be resolved. Even if the value is not defined, the default can still be set to global values such as other `request.object.*` variables from AdmissionReview requests.

```yaml
    context:
    - name: nested-metadata
      variable:
        value:
          metadata:
            labels: 
              name: {{ request.object.metadata.name }}
        # the default value a variable may have if after jmespath processing the value ends up being nil
        # the default value may also be another variable, for example something from the AdmissionReview
        default: '{}'
        # jmespath expression that can be used to modify the `value` before it is assigned to the variable
        jmesPath: 'to_string(@)'
```

Variables can reference other variables as well as shown below. Note that context variables are ordered; a variable consumed by another variable must be defined higher in the list of context variables.

```yaml
context:
- name: jpExpression
  variable:
    value: name
- name: objName
  variable:
    value:
      name: "{{ request.object.metadata.name }}"
    jmesPath: "{{ jpExpression }}"
```

## Variables from external data sources

Some policy decisions require access to cluster resources and data managed by other Kubernetes controllers or external applications. For these types of policies, Kyverno allows HTTP calls to the Kubernetes API server and the use of ConfigMaps.

Data fetched from external sources is stored in a per-rule processing context that is used to evaluate variables by the policy engine. Once the data from external sources is stored in the context, it can be referenced like any other variable data.

Learn more about ConfigMap lookups and API Server calls in the [External Data Sources](/docs/writing-policies/external-data-sources/) section.

## Nested Lookups

It is also possible to nest JMESPath expressions inside one another when mixing data sourced from a ConfigMap and AdmissionReview, for example. By including one JMESPath expression inside the other, Kyverno will first substitute the inner expression before building the outer one as seen in the below example.

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
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          annotations:
            foo: "{{LabelsCM.data.{{ request.object.metadata.labels.app }}}}"
```

In this example, AdmissionReview data is first collected in the inner expression in the form of `{{request.object.metadata.labels.app}}` while the outer expression is built from a ConfigMap context named `LabelsCM`.

## Evaluation Order

Kyverno policies can contain variables in:

* Rule context
* Rule preconditions
* Rule definitions:
  * Validation patterns
  * Validation deny rules
  * Mutate strategic merge patches (`patchesStrategicMerge`)
  * Generate resource data definitions
  * verifyImages definitions

Variables are not supported in the `match` and `exclude` elements, so that rules can be matched quickly without having to load and process data. Variables are also not supported in the `patchesJson6902.path` key.

Since variables can be nested, it is important to understand the order in which the variables are evaluated. During admission control, here is how the engine processes rules:

1. The set of matching rules is determined by creating a hash from the request information to retrieve all matching rules based on the rule and resource types.
2. Each matched rule is further processed to fully evaluate the match and retrieve conditions.
3. The preconditions are then checked.
4. The rule body is processed.

This ordering makes it possible to use request data when defining the context, and context variables in preconditions. Within the context itself, each variable is evaluated in the order of definition. Hence, if required, a variable can reference a prior variable but attempts to use a subsequent definition will result in errors. Context variables themselves are resolved when evaluated in the rule context except when the occur in a condition/expression.

## JMESPath custom functions

In addition to the list of [built-in functions](https://jmespath.org/specification.html#builtin-functions) JMESPath offers, Kyverno augments these by adding several others which makes it even easier to craft Kyverno policies.

{{% alert title="Note" color="info" %}}
The JMESPath arithmetic functions work for scalars (ex., 10), resource quantities (ex., 10Mi), and durations (ex., 10h). If the input is a scalar, it must be enclosed in backticks so the parameter is treated as a number. Resource quantities and durations are enclosed in single quotes to be treated as strings.
{{% /alert %}}

The special variable `{{ @ }}` may be used to refer to the current value in a given field, useful for source values.

To find examples of some of these functions in action, see the [Kyverno policies library](/policies/). And for more complete information along with samples for each custom filter, see the JMESPath page [here](/docs/writing-policies/jmespath/).
