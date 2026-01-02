---
title: Kyverno CLI
description: Apply and test policies outside a cluster
sidebar:
  order: 100
---

The Kyverno Command Line Interface (CLI) is designed to validate and test policy behavior to resources prior to adding them to a cluster.

The CLI can be used in CI/CD pipelines to assist with the resource authoring process to ensure they conform to standards prior to them being deployed. It can be used as a `kubectl` plugin or as a standalone CLI.

The CLI, although composed of the same Kyverno codebase, is a purpose-built binary available via multiple installation methods but is distinct from the Kyverno container image which runs as a Pod in a target Kubernetes cluster.
