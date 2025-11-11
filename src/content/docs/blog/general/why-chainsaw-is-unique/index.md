---
date: 2023-12-13
title: Kyverno Chainsaw - Exploring the Power of Assertion Trees!
linkTitle: Kyverno Chainsaw - Exploring the Power of Assertion Trees
author: Charles-Edouard Brétéché
description: The Chainsaw Secret Sauce!
---

![Kyverno Chainsaw](kyverno-chainsaw-horizontal.png)

While the [Chainsaw documentation](https://kyverno.github.io/chainsaw) is nice and comprehensive, I feel like the most powerful feature of Chainsaw deserves its own blog post for a couple of reasons:

- Its hard to make it standout in the documentation
- You can't appreciate Chainsaw until you understand what makes it so unique
- Seeing the feature in action is the best way to learn about it

What makes Chainsaw unique is its **_assertion model_**.

In this blog post we will deep dive into the assertion model used by Chainsaw, how it works, and how we extended something that looks like YAML but is more than that.

After all, if Chainsaw was only about applying resources in a cluster and checking fields are set correctly on those resources it would be deceptive. There are other tools which can do that today and Chainsaw would be more or less redundant.

## Basic assertions

Let's start by reviewing the basics briefly.

### The most basic assertion

We will start with a basic assertion:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
spec:
  replicas: 2
```

When asking Chainsaw to execute the assertion above, it will look for a Deployment named `coredns` in the `kube-system` namespace and will compare the existing resource with the (partial) resource definition contained in the assertion.

In this specific case, if `spec.replicas` is set to 2 in the existing resource, the assertion will be considered valid. If it is not equal to 2 the assertion will be considered failed.

This is the most basic assertion Chainsaw can evaluate.

### A slightly less basic assertion

A slightly less basic assertion is shown below.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: kube-dns
  namespace: kube-system
spec:
  replicas: 2
```

This time we are not providing a resource name.

Chainsaw will look up all Deployments with the `k8s-app: kube-dns` label in the `kube-system` namespace. The assertion will be considered valid if **at least one** Deployment matches with the (partial) resource definition contained in the assertion. If none matches the assertion will be considered failed.

Apart from the resource lookup process being a little bit more interesting, this kind of assertion is essentially the same as the previous one. Chainsaw is basically making a decision by comparing an actual and expected resource.

### A word on timeout

Keep in mind that Chainsaw won't consider an assertion valid or failed in one shot. The assertion will be continuously evaluated during a predetermined period of time until the assertion succeeds or the timeout expires.

## It's good, but not enough

Now that we covered the basic assertions we can look at their limitations and how Chainsaw solves them.

Basic assertions cover the simple cases but:

- Working with arrays is not easy
  - How are we supposed to compare arrays with different sizes?
  - How can we check a specific item in an array is present?
- Matching exact values is not always what we want
  - How can we verify the number of replicas is above a certain number (not exactly this number)?
  - How can we apply a regex to a label?

While the examples above are the most obvious ones, they demonstrate that an assertion model needs to be more rich and more flexible than simple comparisons.

### Overview of the Chainsaw Assertion Model

Let's see how Chainsaw can assert that the number of replicas of a Deployment is greater than a certain threshold. Let's look at how it can be written.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: kube-dns
  namespace: kube-system
spec:
  (replicas > 2): true
```

In the assertion above, the **key part** of the YAML syntax contains a [JMESPath](https://jmespath.site) expression. The evaluation of this expression will be compared to the **value part** of the YAML syntax.

In this case, the expression is simple but represents the main concept behind the Chainsaw assertion model. At every node in the YAML tree, Chainsaw can create a projection of the element currently being processed and pass the result of this projection to the descendants. When a leaf of the tree is reached, a comparison happens. If the comparison fails, the assertion will be considered failed. If all comparisons succeed, the assertion will be considered valid.

### Working with arrays

Working with arrays can be challenging. To manipulate arrays, Chainsaw leverages JMESPath capabilities to allow easy filtering and projections.

Let's say we want an assertion to consider only containers that have no security context defined.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: kube-dns
  namespace: kube-system
spec:
  template:
    spec:
      (containers[?securityContext == null]):
        (length(@)): 0
```

In the assertion above, the first three fields `spec`, `template`, and `spec` are basic projections that simply take the content of their respective fields and pass that to descendants.

`(containers[?securityContext == null])` is a JMESPath expression filtering the `containers` array, selecting only the element where `securityContext` is `null`. This projection results in a new array that is passed to the descendant (`(length(@))` in this case).

`(length(@))` is another JMESPath expression that computes the length of the array. There's no more descendant at this point. We're at a leaf of the YAML tree and the array length we just computed is then compared against 0.

If the comparison matches, the assertion will be considered valid; if not, it will be considered failed.

In simple words, the assertion above checks that all containers in the Deployment have a security context configured.

### Iterating over arrays (or maps)

Being able to filter arrays allows selecting the elements to be processed.

On top of that, Chainsaw allows iterating over array elements to validate each item separately.

The assertion above can be rewritten using an iterator:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: kube-dns
  namespace: kube-system
spec:
  template:
    spec:
      # the `~` modifier tells Chainsaw to iterate over the array elements
      ~.(containers):
        securityContext: {}
```

This assertion uses the `~` modifier and Chainsaw will evaluate descendants once per element in the array.

### Explicit bindings and reference

When passing from a parent node to descendant nodes, it can be useful to keep a reference to one or more parent nodes.

Let's say we want to consider the pod-level security context in addition to the container-level security context. We can write such an assertion with the syntax below:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: kube-dns
  namespace: kube-system
spec:
  template:
    # `->podSpec` creates a binding to the pod spec, accessible in descendant nodes
    (spec)->podSpec:
      # the `~` modifier tells Chainsaw to iterate over the array elements
      ~.(containers):
        # `$podSpec` references the binding created above
        ($podSpec.securityContext != null || securityContext != null): true
```

In the assertion above, `(spec)->podSpec` means that Chainsaw will keep a reference to the result of the expression evaluation and will make it available to descendants under the `$podSpec` binding.

Now we can use the binding to write an assertion check taking the pod-level security context into account like this `($podSpec.securityContext != null || securityContext != null): true`. This enhanced assertion check will ensure that, if any container's securityContext is not defined, the pod-level securityContext is defined.

### What more

We covered all major features of assertion trees in this blog post.

Chainsaw doesn't directly implement assertion trees but relies on the [kyverno-json package](https://github.com/kyverno/kyverno-json). You can browse [the documentation](https://kyverno.github.io/kyverno-json/latest/policies/asserts/#assertion-trees) to learn more about assertion trees, this documentation also applies to Chainsaw. The [kyverno-json playground](https://kyverno.github.io/kyverno-json/latest/_playground/) is also a good resource to familiarise with assertion trees.

Note that JMESPath supports functions and also allows custom functions to be registered in the JMESPath interpreter. The supported list of functions is available [here](https://kyverno.github.io/chainsaw/latest/reference/jp/functions/).

## Conclusion

I hope this blog post helps you understand what assertion trees are and how they work.

Simple tests usually only need simple capabilities, but assertion trees can come in very handy when your tests become more complex.

In the future, we plan to support CEL as well as JMESPath as the underlying evaluation engine. While JMESPath works well, the fact that Kubernetes adopted CEL makes it an excellent choice for Chainsaw too.
