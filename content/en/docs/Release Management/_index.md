---
title: Release Management
linkTitle: "Release Management"
weight: 120
---

## Release Management Guide

This document approximates timelines and how to maintain release branches.

### The overall scope of the project

Kyverno simplifies Kubernetes configuration management using policies for security and automation. Kyverno makes it easy for Kubernetes administrators to write and manage Kubernetes policies, and for Kubernetes users (ex., developers) to consume policy results and address issues.

### Release Timelines

Kyverno uses the [Semantic Versioning](https://semver.org/) scheme. Kyverno v1.0.0 was released in Dec 2019. This project follows a given version number MAJOR.MINOR.PATCH.

**MAJOR release:**

This is the version when you make incompatible API changes.

- Low frequency and  required e.g. once a year

**MINOR release:**

This is the version when you add functionality in a backwards-compatible manner. Since Kyverno is a fast growing project, having a major release approximately every three months helps to manage project progress.

- Roughly every 3 months

**PATCH release:**

This is the version when you make backwards-compatible bug fixes. The patch release contains the critical fixes.

- When critical fixes are required, or roughly each month

### How to manage tags


### Versioning

Kyverno uses GitHub tags to manage versions. New releases and release candidates are published using the wildcard tag `v<major>.<minor>.<patch>*`. 

The dev images are pushed with tag `<major>.<minor>.dev-<git hash>`, you can find published dev image for a specific commit via the GitHub workflow [image](https://github.com/kyverno/kyverno/actions/workflows/image.yaml). For example, this [job](https://github.com/kyverno/kyverno/runs/4579160206?check_suite_focus=true) pushed images with tag `1.6-dev-7-gff99d92f` for PR [#2856](https://github.com/kyverno/kyverno/pull/2856).

To test with latest images for different release branches, the images are pushed with `<major>.<minor>-latest`.
  
### Notes

- Branches for new releases follow the naming SemVer naming convention, for example release v1.5.2.
- Close to any release, all PRs for that release should be confined to the branch specific to the release.
