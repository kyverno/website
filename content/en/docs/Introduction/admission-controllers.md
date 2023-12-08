---
title: Admission Controllers
description: Admission Controllers 101
weight: 35
---

## Admission Controllers

In Kubernetes, Admission Controllers are responsible for intercepting requests coming to the API server after authenticating (e.g. using token or certificate), authorizing (e.g. using RBAC) the request and before persisting (saving) the request in the backend.

For Example, whenever we create a new Pod, a request is sent to the Kubernetes API server and an Admission controller intercepts the request and it may validate, mutate or do both with the request.

## Why to use Admission Controllers

Admission controllers was introduced in Kubernetes as a set of Plugins for improving the cluster security.

Admission controllers must be enabled to use some of the more advanced security features of Kubernetes such as Pod security Policies.