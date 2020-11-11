---
title: Variables and External Data Sources
description: >
    Use request data, ConfigMaps, and built-in variables in policy rules
weight: 6
---

Sometimes it is necessary to vary the contents of a mutated or generated resource based on request data or other variables. To achieve this, Kyverno builds a `context` for each rule that contains information from the `AdmissionReview` request like the namespace and object, or from specified `ConfigMap` instances.

The context data can then be referenced in the policy rule using the [JMESPATH](http://jmespath.org/) notation. The policy engine will substitute any values with the format `{{ <JMESPATH> }}` with the variable value before processing the rule.

Variables are currently not supported on `match` or `exclude` statements within a rule.

## Pre-defined Variables

Kyverno automatically creates a few useful variables and adds them in the rule `context`:

- `serviceAccountName` : the "userName" which is last part of a service account i.e. without the prefix `system:serviceaccount:<namespace>:`. For example, when processing a request from `system:serviceaccount:nirmata:user1` Kyverno will store the value `user1` in the variable `serviceAccountName`.

- `serviceAccountNamespace` : the "namespace" part of the serviceAccount. For example, when processing a request from `system:serviceaccount:nirmata:user1` Kyverno will store `nirmata` in the variable `serviceAccountNamespace`.

## Using AdmissionReview request data

The following `AdmissionReview` request data is available for use in context:

- Resource: `{{request.object}}`
- UserInfo: `{{request.userInfo}}`

Here are some examples of looking up this data:

1. Reference a resource name (type string)

`{{request.object.metadata.name}}`

2. Build name from multiple variables (type string)

`"ns-owner-{{request.object.metadata.namespace}}-{{request.userInfo.username}}-binding"`

3. Reference the metadata (type object)

`{{request.object.metadata}}`

## Using ConfigMaps

Kyverno supports using Kubernetes [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/) to manage variable values outside of a policy definition. When a policy referencing a ConfigMap resource is evaluated, the ConfigMap data is checked at that time ensuring that references to the ConfigMap are always dynamic. Should the ConfigMap be updated later, subsequent policy lookups will pick up the data at that point.

To refer to values from a ConfigMap inside any Rule, define a context inside the rule with one or more ConfigMap declarations.

````yaml
  rules:
    - name: example-configmap-lookup
      # added context to define the configmap information which will be referred
      context:
      # unique name to identify configmap
      - name: dictionary
        configMap:
          # configmap name - name of the configmap which will be referred
          name: mycmap
          # configmap namepsace - namespace of the configmap which will be referred
          namespace: test
````

Sample ConfigMap Definition:

````yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mycmap
data:
  env: production
````

### Looking up ConfigMap values

A ConfigMap that is defined in a rule context can be referred to using its unique name within the context. ConfigMap values can be referenced using a [JMESPATH](http://jmespath.org/) style expression:

```
{{ <name>.<data>.<key> }}
```

For the example above, we can refer to a ConfigMap value using `{{dictionary.data.env}}`. The variable will be substituted with the value `production` during policy execution.

**Note:** ConfigMap names and keys can contain characters that are not supported by [JMESPATH](http://jmespath.org/), such as "-" (minus or dash) or "/" (slash). To evaluate these characters as literals, add quotes to that part of the JMESPATH expression as follows:

```
{{ "<name>".<data>."<key>" }}
```

### Handling ConfigMap Array Values

The ConfigMap value can be an array of string values in JSON format. Kyverno will parse the JSON string to a list of strings, so set operations like In and NotIn can then be applied.

For example, a list of allowed roles can be stored in a ConfigMap, and the Kyverno policy can refer to this list to deny the requests where the role does not match one of the values in the list.

Here are the allowed roles in the ConfigMap:

````yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: roles-dictionary
  namespace: test
data:
  allowed-roles: "[\"cluster-admin\", \"cluster-operator\", \"tenant-admin\"]"
````

**NOTE:** as mentioned above, the quotes are necessary due to the `-` character that needs to be escaped for [JMESPATH](http://jmespath.org/) processing.

Here is a rule to block a Deployment if the value of annotation `role` is not in the allowed list:

````yaml
spec:
  validationFailureAction: enforce
  rules:
  - name: validate-role-annotation
    context:
      - name: roles-dictionary
        configMap:
          name: roles-dictionary
          namespace: test
    match:
      resources:
        kinds:
        - Deployment
    preconditions:
    - key: "{{ request.object.metadata.annotations.role }}"
      operator: NotEquals
      value: ""
    validate:
      message: "role {{ request.object.metadata.annotations.role }} is not in the allowed list {{ \"roles-dictionary\".data.\"allowed-roles\" }}"
      deny:
        conditions:
        - key: "{{ request.object.metadata.annotations.role }}"
          operator: NotIn
          value:  "{{ \"roles-dictionary\".data.\"allowed-roles\" }}"
````
