---
title: Admission Controllers
description: A Guide to Kubernetes Admission Controllers
weight: 35
---

## What are Admission Controllers?

In Kubernetes, Admission Controllers are responsible for intercepting requests coming to the API server after authenticating (e.g. using token or certificate), authorizing (e.g. using RBAC) the request and before persisting (saving) the request in the backend. They basically govern and enforce how the cluster is used.

For Example, whenever we create a new Pod, a request is sent to the Kubernetes API server and an Admission controller intercepts the request and it may validate, mutate or do both with the request.

<img src="assets/kubernetes-admission-controllers.png" alt="Kubernetes Admission Controllers" />

## Admission Controllers Phases

Admission Controllers can be thought of as a gatekeeper to the API server. They intercept incoming API requests and may change the request object or deny the request altogether. This process of admission control has two phases: the mutating phase (where mutating admission controllers are run), followed by the validating phase (where validating admission controllers are run). Some of the admission controllers act as a combination of both. If any of the admission controllers reject the request, the entire request is rejected and an error is returned to the end-user.

For example, the LimitRanger admission controller can augment pods with default resource requests and limits (mutating phase) if the request doesn't specify it already, as well as it can verify that the pods with explicitly set resource requirements do not exceed the per-namespace limits specified in the LimitRange object (validating phase). Thus acting as a combination of both Mutating as well as Validating admission controller.
