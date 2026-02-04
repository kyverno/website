---
title: Introduction
linkTitle: Introduction
sidebar:
  order: 10
excerpt: Learn about Kyverno and its powerful capabilities
---

## What is Policy Management?

In cloud native systems, policies are configurations that manage other configurations or runtime behaviors.

The <a href="https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/policy/CNCF_Kubernetes_Policy_Management_WhitePaper_v1.pdf" target="_blank" rel="noopener">Kubernetes Policy Management</a> paper is a good reference to understand the role and implementation of policies.

## Why is Policy Management necessary?

Cloud native systems, like Kubernetes, have declarative configurations. Since these systems are very flexible, and support a large number of use cases, they support extensive detailed configurations. Additionally, these systems support multiple roles - developers, operations, and platform teams collaborate on and share configurations.Hence, these systems are highly flexible but also complex to configure and manage directly.

Policies provide the right level of abstraction and seperation of concerns for cloud native infrastructure and applications.

## About Kyverno

Kyverno (Greek for "govern") is a cloud native policy engine. It was originally built for Kubernetes and now can also be used outside of Kubernetes clusters as a unified policy language.

Kyverno allows platform engineers to automate security, compliance, and best practices validation and deliver secure self-service to application teams.

Some of its many features include:

- use YAML and CEL (Common Expressions Language) to author policies, with no new language to learn!
- manage policies as declarative Kubernetes resources
- enforce policies as a Kubernetes admission controller, CLI-based scanner, and at runtime
- validate, mutate, generate, or cleanup (remove) any Kubernetes resource
- verify container images and metadata for software supply chain security
- policies for any JSON payload including Terraform resources, cloud resources, and service authorization
- policy reporting using the [OpenReport](https://openreports.io) format
- flexible policy exception management
- tooling for comprehensive unit and e2e testing of policies
- management of policies as code resources using familiar tools like `git` and `kustomize`
