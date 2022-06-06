---
title: Releases
linkTitle: "Releases"
description: Kyverno Releases
weight: 120
---

## Release Notes and Assets

Release notes are available on GitHub at https://github.com/kyverno/kyverno/releases

## Release Management

This section provides guidelines on release timelines and release branch maintenance.

### Release Timelines

Kyverno uses the [Semantic Versioning](https://semver.org/) scheme. Kyverno v1.0.0 was released in December 2019. This project follows a given version number MAJOR.MINOR.PATCH.

#### MAJOR release

Major releases contain large features, design and architectural changes, and may include incompatible API changes.

- Low frequency and required e.g. once a year

#### MINOR release

Minor releases contain features, enhancements, and fixes that are introduced in a backwards-compatible manner. Since Kyverno is a fast growing project, but is a critical component of the Kubernetes control plane, having a major release approximately every three months helps balance speed and stability.

- Roughly every 3 months

#### PATCH release

Patch releases are for backwards-compatible bug fixes. Typically only critical fixes are picked for patch releases.

- When critical fixes are required, or roughly each month

### Versioning

Kyverno uses GitHub tags to manage versions. New releases and release candidates are published using the wildcard tag `v<major>.<minor>.<patch>*`.

The dev images are pushed with tag `<major>.<minor>.dev-N-<git hash>`, where "N" is a two-digit number beginning at one for the major-minor combination and incremented by one on each subsequent tagged image. See [more](https://github.com/kyverno/kyverno/pkgs/container/kyverno/versions) examples. You can find published dev images for a specific commit via the GitHub workflow named [image](https://github.com/kyverno/kyverno/actions/workflows/image.yaml). For example, this [job](https://github.com/kyverno/kyverno/runs/4579160206?check_suite_focus=true) pushed images with tag `1.6-dev-7-gff99d92f` for PR [#2856](https://github.com/kyverno/kyverno/pull/2856).

To test with the latest images for different release branches, the images are pushed with `<major>.<minor>-dev-latest`.

### Branches and PRs

Release branches and PRs are managed as follows:

- All changes are always first committed to `main`.
- Branches are created for each major or minor release.
- The branch name will contain the version, for example `release-1.5`.
- Patch releases are created from a release branch.
- For critical fixes that need to be included in a patch release, PRs should always be first merged to main and then cherry-picked to the release branch. The milestone label is important here for tracking.
- For complex changes, or when branches diverge significantly, separate PRs may be required for `main` and release branches.
- Issues are always added to milestones for releases.
- PRs are labeled with milestone labels, for maintainers to cherry-pick to patch branches.
- During PR review, the Assignee selection is used to indicate the reviewer.
