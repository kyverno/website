---
title: Releases
linkTitle: "Releases"
description: >
    Understand how and when Kyverno releases software.
weight: 120
---

## Release Notes and Assets

Release notes are available on GitHub at https://github.com/kyverno/kyverno/releases

## Release Management

This section provides guidelines on release timelines and release branch maintenance.

### Release Timelines

Kyverno uses the [Semantic Versioning](https://semver.org/) scheme. Kyverno v1.0.0 was released in December 2019. This project follows a given version number MAJOR.MINOR.PATCH.

#### MAJOR release

Major releases contain large features, design and architectural changes, and may include incompatible API changes. Major releases are low frequency and created as required e.g. once a year.

#### MINOR release

Minor releases contain features, enhancements, and fixes that are introduced in a backwards-compatible manner. Since Kyverno is a fast growing project, but is a critical component of the Kubernetes control plane, having a major release approximately every few months helps balance speed and stability. Vulnerabilities scored as either medium or low will be included in minor releases unless they coincide with an existing patch release.

- Roughly every 3 months

#### PATCH release

Patch releases are for backwards-compatible bug fixes, very minor enhancements which do not impact stability or compatibility, or critical or high security vulnerabilities. Typically only critical fixes are selected for patch releases.

- When critical fixes are required, or roughly each month

### Versioning

Kyverno uses GitHub tags to manage versions. New releases and release candidates are published using the wildcard tag `v<major>.<minor>.<patch>*`.

Untagged pushes to both release branches and the `main` branch also result in images being built. For commits pushed to a release branch (a branch prefixed with `release-`), an image is built with a tag equaling the git SHA which produced the build. A rolling tag of the branch name will be re-applied to the latest image built from commits pushed to that branch. For example, the latest commit to the `release-1.10` branch is `19621b7a703935d6217a404ab5054687a84a3eda` results in an image built which is tagged with `19621b7a703935d6217a404ab5054687a84a3eda` and `release-1.10`. Commits to the `main` branch follow a similar versioning strategy except the rolling tag `latest` will be used instead.

### Issues

Non-critical issues and features are always added to the next minor release milestone, by default.

Critical issues, with no workarounds, are added to the next patch release.

### Branches and PRs

Release branches and PRs are managed as follows:

- All changes are always first committed to `main`.
- Branches are created for each major or minor release.
- The branch name will contain the version, for example `release-1.5`.
- Patch releases are created from a release branch.
- For critical fixes that need to be included in a patch release, PRs should always be first merged to `main` and then cherry-picked to the release branch. The milestone label (for example `milestone-1.5`) must be added to PRs that are to be merged to a release branch, along with the `cherry-pick-required` label. When the PR is cherry picked (or merged), the `cherry-pick-completed` label is added.
- For complex changes, or when branches diverge significantly, separate PRs may be required for `main` and release branches.
- During PR review, the Assignee selection is used to indicate the reviewer.

### Release Planning

A minor release will contain a mix of features, enhancements, and bug fixes.

Major features follow the [Kyverno Design Proposal (KDP)](https://github.com/kyverno/KDP/) process.

During the start of a release, there may be many issues assigned to the release milestone. The priorities for the release are discussed in the weekly contributor's meetings. As the release progresses several issues may be moved to the next milestone. Hence, if an issue is important it is important to advocate its priority early in the release cycle.
