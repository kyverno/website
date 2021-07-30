# The Kyverno Website

https://kyverno.io

## Preview instructions

* This site makes use of the [Docsy](https://docsy.dev) theme.
  [Hugo Extended](https://gohugo.io/getting-started/installing#fetch-from-github) is required to render it.
* Create a [fork](https://movi.hashnode.dev/how-to-successfully-fork-clone-signoff-and-make-a-pull-request-ckdyt03sy06utjas18lx1cjer) of the Kyverno website repository to your GitHub account. You will later created a PR (pull request using this fork.)
* `git clone https://github.com/{GITHUB-ID}/website kyverno-website/ --recurse-submodules`
* `cd kyverno-website`
* `hugo server -v`

## Rendering Policies to Markdown

See [render](/render/README.md) folder.

## Customize settings

Edit the `.toml` files inside the `config/_default` dir

## Style and typographical conventions

The Kyverno website has established several writing conventions in the interest of consistency and accuracy.

### Voice

Active voice is preferred in most writing examples. Ex., "this ClusterPolicy mutates incoming Pods..." and not "incoming Pods are mutated by this ClusterPolicy".

### Code styling

* Kubernetes resource kinds are considered proper nouns and are distinguished from other nouns by the initial letter capitalization. Ex., "a Kubernetes Pod will be annotated".
* Anything intended to be proper code or typed at a CLI is formatting using Markdown code syntax with backticks or in blocks (surrounded by three backticks).
* Code represented in blocks should prefer a syntax declaration for this theme's highlighting ability. Ex., when displaying YAML notate the code block with three backticks and "yaml".

## Managing Release Versions

Here are the rules for managing release versions:

1. All fixes and feature changes go to the `main` (we may in a few rare cases make fixes to prior versions of the documentation.) The main branch can be accessed at `https://main.kyverno.io`.

2. When a new release is ready for GA, a new release branch is created (see steps below). Release branches are named `release-{major}-{minor}-{patch}` for example `release-1-4-2`. The release branch can be accessed using the `{branch}.nirmata.io` and the latest release is available at `kyverno.io`.

### Creating a release branch

To create a new release branch:

1. Create and push the branch using `git checkout -b release-{major}-{minor}-{patch}` or via [GitHub](https://github.com/kyverno/website/branches).

2. [Update Netlify](https://app.netlify.com/sites/kyverno/settings/deploys#branches) to point `production` to the new release.

In the `main` branch:

1. Update the versions list in [config.toml](/config/_default/config.toml) to add the next release.

2. Update `version_menu` and `version` in [params.toml](/config/_default/params.toml) for the next release.

3. Create a PR.

#### Submitting a PR to multiple release branches

Ideally all changes will go to `main` and then be promoted to a release branch. However, ocassionally we will need to fix documentation issues for already released versions. For such cases, a PR must be created for each release branch.

There are several ways to create multiple PRs, but here is one easy flow:
1. Create a PR for the `main` branch, as usual.
2. For each additional branch, checkout the branch (`git checkout <branch>`), and then cherry pick the commit(s) to that branch using `git --cherry-pick <commit>`.
3. Submit PRs for each release branch.
