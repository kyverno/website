---
date: 2024-02-15
title: Kyverno Chainsaw 0.1.4 - Awesome new features!
tags:
  - General
authors:
  - name: Charles-Edouard Brétéché
excerpt: What's new in chainsaw v0.1.4!
---

![Kyverno Chainsaw](assets/kyverno-chainsaw-horizontal.png)

The [latest release of Kyverno Chainsaw](https://github.com/kyverno/chainsaw/releases/tag/v0.1.4) came out yesterday. Let's look at the new features included in this release.

- Resource diff in assertion failures
- Resource templating support

## Resource diff in assertion failures

This is a relatively straightforward one but it brings a lot of context to assertion failures.

Suppose an assertion fails, before `v0.1.4` the output would have looked like this:

```sh
    | 09:52:19 | deployment | step-1   | ASSERT    | RUN   | v1/Pod @ chainsaw-full-llama/*
    | 09:52:49 | deployment | step-1   | ASSERT    | ERROR | v1/Pod @ chainsaw-full-llama/*
        === ERROR
        v1/Pod/chainsaw-full-llama/example-5477b4ff8c-vrzs8 - metadata.annotations.foo: Invalid value: "null": Expected value: "bar"
    | 09:52:49 | deployment | step-1   | TRY       | DONE  |
```

While the message contains a description of the failure (`metadata.annotations.foo: Invalid value: "null": Expected value: "bar"`) and the offending resource (`v1/Pod/chainsaw-full-llama/example-5477b4ff8c-vrzs8`), it's not easy to understand where the resource comes from.

The same error in `v0.1.4` will be reported including a resource diff:

```sh
    | 09:55:50 | deployment | step-1   | ASSERT    | RUN   | v1/Pod @ chainsaw-rare-liger/*
    | 09:56:20 | deployment | step-1   | ASSERT    | ERROR | v1/Pod @ chainsaw-rare-liger/*
        === ERROR
        ---------------------------------------------------
        v1/Pod/chainsaw-rare-liger/example-5477b4ff8c-tnhd9
        ---------------------------------------------------
        * metadata.annotations.foo: Invalid value: "null": Expected value: "bar"

        --- expected
        +++ actual
        @@ -1,10 +1,16 @@
         apiVersion: v1
         kind: Pod
         metadata:
        -  annotations:
        -    foo: bar
           labels:
             app: nginx
        +  name: example-5477b4ff8c-tnhd9
           namespace: chainsaw-rare-liger
        +  ownerReferences:
        +  - apiVersion: apps/v1
        +    blockOwnerDeletion: true
        +    controller: true
        +    kind: ReplicaSet
        +    name: example-5477b4ff8c
        +    uid: 118abe16-ec42-4894-83db-64479c4aac6f
         spec: {}
    | 09:56:20 | deployment | step-1   | TRY       | DONE  |
```

The additional diff now gives a lot more context about the offending resource. Showing the `ownerReferences` field tells us who is responsible for the resource existence.

The diff complements complex assertion failures (`metadata.annotations.foo: Invalid value: "null": Expected value: "bar"`) to provide everything needed to get a solid understanding of what failed in an assertion operation.

Thank you [vfarcic](https://github.com/vfarcic) for the [feature request](https://github.com/kyverno/chainsaw/issues/775).

## Resource templating support

This second new feature is probably a game changer in the e2e testing tools ecosystem.

Anyone serious with e2e testing faced this issue at least once. How can I make my resource manifest slightly different, depending on the test being executed?

Without resource templating, we always end up using workarounds like templating in a pre-processing step or relying on scripts invoking `envsubst` with a bunch of environment variables to perform substitutions. Those workarounds are error-prone, often limiting, and hard to maintain

Chainsaw `v0.1.4` now offers a better solution for that, thanks to resource templating!

### Bad example (before chainsaw v0.1.4)

Suppose you want to create a resource having a field that must be set to the URL of a service. This URL will be different depending on the namespace the service is installed in.

Without resource templating, this could be done with something like this.

Given the resource below:

```yaml
apiVersion: metrics.keptn.sh/v1beta1
kind: KeptnMetricsProvider
metadata:
  name: my-mocked-provider
spec:
  type: prometheus
  targetServer: 'http://mockserver.$NAMESPACE.svc.cluster.local:1080'
```

We can use a script to perform namespace substitution with `envsubst` and pipe the result to `kubectl`:

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: example
spec:
  steps:
    - try:
        - script:
            content: |
              envsubst < resource.yaml | kubectl apply -f - -n $NAMESPACE
```

This is bad because Chainsaw doesn't know anything about this resource and won't be able to clean it up when tearing down the test.

### Good example (the chainsaw v0.1.4 way)

With resource templating this can become a regular `apply` operation, Chainsaw will now have full knowledge of the created resource.

The resource can embed complex expressions as demonstrated below:

```yaml
apiVersion: metrics.keptn.sh/v1beta1
kind: KeptnMetricsProvider
metadata:
  name: my-mocked-provider
spec:
  type: prometheus
  # `targetServer` is configured using a complex jmespath expression
  targetServer: (join('.', ['http://mockserver', $namespace, 'svc.cluster.local:1080']))
```

The resource definition above can be used in a regular `apply` operation:

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: example
spec:
  # enable templating (at the test level)
  template: true
  steps:
    - try:
        - apply:
            # or enable templating (at the operation level)
            template: true
            file: resource.yaml
```

### Supported operations

Resource templating is supported in `apply`, `create` and `delete` operations without restriction (provided templating has been enabled at the configuration, test, step or operation level).

Resource templating can also be used in `assert` and `error` operations with some restrictions. Because the content of an `assert` or `error` operation is already an assertion tree, only the elements used for looking up the resources to be processed by the operation will be considered for templating. That is, only `apiVersion`, `kind`, `name`, `namespace` and `labels` are considered for templating. Other fields are not, they are part of the assertion tree.

Last but not least, the same level of templating can be applied to the ephemeral test namespace created by Chainsaw using the `namespaceTemplate` stanza. This can be particularly useful if you need the ephemeral namespace to be annotated or labeled in a certain way:

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: example
spec:
  namespaceTemplate:
    metadata:
      annotations:
        keptn.sh/lifecycle-toolkit: enabled
  steps:
    # ...
```

### Credits

Thank you to the [Keptn](https://keptn.sh/) folks, especially [RealAnna](https://github.com/RealAnna) for helping with the design of this feature.

## Conclusion

Those two new features make Chainsaw a lot more flexible and improve usability a lot.

The resource templating opens new testing opportunities. Combined with the capacity to provide arbitrary data to tests with the `--values` flag, Chainsaw offers a very dynamic way to define tests.

Please keep in mind that resource templating is still experimental and could change slightly in future releases. Nonetheless, we encourage everyone to try it out and give us feedback to improve it as much as we can in the next versions.

More infos 👇

- GitHub: https://github.com/kyverno/chainsaw
- Docs: https://kyverno.github.io/chainsaw
- Slack: https://kubernetes.slack.com/archives/C067LUFL43U
