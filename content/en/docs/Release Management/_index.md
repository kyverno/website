---
title: Release Management
linkTitle: "Release Management"
weight: 120
---

## Release Management Guide.
This document describes the Kyverno release process according to timeline and how to maintain release branches.

### The overall scope of the project

Kyverno simplifies Kubernetes configuration management using policies for security and automation. Kyverno makes it easy for Kubernetes administrators to write and manage Kubernetes policies, and for Kubernetes users (ex., developers) to consume policy results and address issues.

### Release Timelines:

Kyverno uses the Semantic Versioning scheme. Kyverno v1.0.0 was released in Dec 2019. This project follows a given version number MAJOR.MINOR.PATCH.

**MAJOR release:**

This is the version when you make incompatible API changes.

- Low frequency and as required e.g. once a year

**MINOR release:**

This is the version when you add functionality in a backwards-compatible manner. Since Kyverno is a fast growing project, having a major release every 3 months would help to manage the progress of the project.

- Roughly every 3 months

**PATCH release:**

This is the version when you make backwards-compatible bug fixes. The patch release contains the critical fixes.

- When critical fixes are required, or roughly each month

### Notes:

- Branches for new release follow a naming Convention (release v1.5.2)
- Close to any release, all PRs for that release should be confined to the branch specific to the release.
