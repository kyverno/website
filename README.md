# The Kyverno Website

Source for: https://kyverno.io

## Accessing Earlier Documentation

The Kyverno website follows the same support policy as Kyverno, an N-2 policy. Documentation will be made available for the current release and the two previous minor releases. While this extends to the version list on the website, users may still access earlier versions of the documentation by navigating to a specific version by URL.

Documentation for each version is published at a URL like `https://release-X-Y-0.kyverno.io/` where `X` is the major version and `Y` is the minor version. To access the documentation for version 1.9.0, navigate to the URL [https://release-1-9-0.kyverno.io/](https://release-1-9-0.kyverno.io/).

## Contributors

<a href="https://github.com/kyverno/website/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=kyverno/website" />
</a>

Made with [contributors-img](https://contrib.rocks).

## Contributing

This site makes use of the [Docsy](https://docsy.dev) theme and [Hugo Extended](https://gohugo.io/getting-started/installing#fetch-from-github) is required to render it.

To contribute changes, use the [fork & pull](https://movi.hashnode.dev/how-to-successfully-fork-clone-signoff-and-make-a-pull-request-ckdyt03sy06utjas18lx1cjer) approach.

1\. First create a [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) of the Kyverno website repository to your GitHub account. By default, the forked repository will be named `website` but can be changed in the settings for your repository if desired. You will later created a PR (pull request) using this fork.

2\. Next, create a local clone using the command:

```sh
git clone https://github.com/{YOUR-GITHUB-ID}/website kyverno-website/
```

3\. Then navigate to the local folder and build the website for local viewing of changes:

```sh
cd kyverno-website
hugo server
```

**Note For Windows Users:** When running the `hugo server` command, make sure to execute it with administrator privileges in your terminal. This is necessary to ensure proper access and functionality during the server execution.

By default, Hugo runs the website at: http://localhost:1313 and will re-build the site on changes.

## Update Docsy theme

The project uses [Hugo Modules](https://gohugo.io/hugo-modules/) to manage the theme:

Run `hugo mod get -u ./...` from project root.

To clean the module cache use `hugo mod clean`.

## Rendering Policies to Markdown

Policies found at https://kyverno.io/policies/ are generated in Markdown from the source repository at [kyverno/policies](https://github.com/kyverno/policies). For any changes to appear on https://kyverno.io/policies/, edits must be made to the upstream policy YAML files at kyverno/policies, and the `render` tool run from this repository to generate the respective Markdown. See [render](/render/README.md) README for more details.

## Style and typographical conventions

The Kyverno website has established several writing conventions in the interest of consistency and accuracy.

### Voice

Active voice is preferred in most writing examples. Ex., "this ClusterPolicy mutates incoming Pods..." and not "incoming Pods are mutated by this ClusterPolicy".

### Code styling

* Kubernetes resource kinds are considered proper nouns and are distinguished from other nouns by the initial letter capitalization. Ex., "a Kubernetes Pod will be annotated".
* Anything intended to be proper code or typed at a CLI is formatting using Markdown code syntax with backticks or in blocks (surrounded by three backticks).
* Code represented in blocks should prefer a syntax declaration for this theme's highlighting ability. Ex., when displaying YAML notate the code block with three backticks and "yaml".

### Grammar

* We standardize on use of the Oxford comma.

## Documentation Versioning

The Kyverno website now uses releases to organize documentation by the specified release making it easier for users to find the information that pertains to their version. Releases are defined by branches of kyverno/website and a combination of exposing them in the website configuration and modifying hosting parameters.

## Managing Release Versions

Here are the rules for managing release versions:

1. All fixes and feature changes go to the `main` branch (we may in a few rare cases make fixes to prior versions of the documentation.) The main branch can be accessed at `https://main.kyverno.io`.

2. When a new release is ready for GA, a new release branch is created (see steps below). Release branches are named `release-{major}-{minor}-{patch}` for example `release-1-4-2`. The release branch can be accessed using the `{branch}.kyverno.io` and the latest release is available at `kyverno.io`.

### Creating a release branch

To create a new release branch:

1. Create and push the branch using `git checkout -b release-{major}-{minor}-{patch}` or via [GitHub](https://github.com/kyverno/website/branches).

2. [Update Netlify](https://app.netlify.com/sites/kyverno/settings/deploys#branches) to point `production` to the new release branch.

3. Also in Netlify, go into the Domain management settings of the site and add a new subdomain for the branch representing the previous version. For example, if the release to be cut is 1.8.0, there will not be a `release-1-7-0.kyverno.io` record which exists. One must be created for `release-1-7-0.kyverno.io`.

In the `main` branch:

1. Update the versions list in [params.toml](/config/_default/params.toml) to add the next release.

2. Update `version_menu` and `version` in [params.toml](/config/_default/params.toml) for the next release.

3. Create a PR.

4. Clear the Netlify cache!

In the current release branch:

1. Update `params.toml` so that `version_menu` and `version` reflect the version of that release branch, NOT `main`. This is so when users navigate to the version of the docs represented in that version it shows the correct number.

#### Submitting a PR to multiple release branches

Ideally all changes will go to `main` and then be promoted to a release branch. However, occasionally we will need to fix documentation issues for already released versions. Rendered policies will always go to all branches because the policy samples themselves declare minimum capable versions via the `policies.kyverno.io/minversion` annotation.

Use the cherry pick bot to request a PR be cherry picked to a target branch. Call for the bot with a comment on the desired PR with `/cherry-pick release-1-12-0` to cherry pick this PR to the `release-1-12-0` branch. A new PR will be opened with `release-1-12-0` as the target branch.

There are several ways to create multiple PRs, but here is one easy flow:

1. Create a PR for the `main` branch, as usual.
2. For each additional branch, checkout the branch (`git checkout <branch>`), and then cherry pick the commit(s) to that branch using `git --cherry-pick <commit>`. If using GitHub Desktop, a commit can be cherry picked by setting the source branch where the PR was merged, accessing the History tab, and dragging-and-dropping that commit to the destination branch.
3. Submit PRs for each release branch.

## Customize other settings

Edit the `.toml` files inside the `config/_default` directory.

If needing to create a new page under the `Policies` heading that adopts the same CSS styling, assign `type = "policies"` to the page.
