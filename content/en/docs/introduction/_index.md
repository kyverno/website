---
title: Introduction
linkTitle: Introduction
weight: 10
description: Learn about Kyverno and its powerful capabilities
---

## About Kyverno

Kyverno (Greek for "govern") is a cloud native policy engine. It was originally built for Kubernetes and now can also be used outside of Kubernetes clusters as a unified policy language.

Kyverno allows platform engineers to automate security, compliance, and best practices validation and deliver secure self-service to application teams.

Some of its many features include:

* use YAML and CEL (Common Expressions Language) to author policies, with no new language to learn!
* manage policies as declarative Kubernetes resources 
* enforce policies as a Kubernetes admission controller, CLI-based scanner, and at runtime 
* validate, mutate, generate, or cleanup (remove) any Kubernetes resource
* verify container images and metadata for software supply chain security
* policies for any JSON payload including Terraform resources, cloud resources, and service authorization
* policy reporting using the [OpenReport](OpenReports.io) format
* flexible policy exception management
* tooling for comprehensive unit and e2e testing of policies
* management of policies as code resources using familiar tools like `git` and `kustomize`

