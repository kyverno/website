# How to Contribute

Thank you for expressing interest in contributing to the Kyverno documentation! We welcome all contributions, suggestions, and feedback! We'd love to accept your contributions to this project, there are just a few guidelines you need to follow.

## Contributor License Agreement

Contributions to this project must be accompanied by a [Contributor License Agreement](https://github.com/cncf/cla). Project authors will retain the copyright to your contribution; this simply gives us permission to use and redistribute your contributions as part of the project. You generally only need to submit a CLA once, so if you've already submitted one (even if it was for a different project), you probably don't need to do it again.

## Code Reviews

All submissions, including submissions by project members, require review. We use GitHub pull requests for this purpose. Consult [GitHub Help](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests) for more information on using pull requests.

## Community Guidelines

This project follows the [CNCF Code of Conduct](https://github.com/cncf/foundation/blob/main/code-of-conduct.md).

## Ways To Contribute

If you wish to contribute to this project, there are several options as outlined below.

[Report Issues](#report-issues)
[Submit a Pull Request](#submit-a-pull-request)
[Join Our Community Meetings](#community-meetings)

### Report issues

If you see a bug or want to suggest an enhancement, please create an [issue](https://github.com/kyverno/website/issues/new/choose). Issues are a great way to tell the Kyverno documentation team what you think can be improved or fixed. Even reporting a misspelling is appreciated!

### Submit a Pull Request

Find an [open issue](https://github.com/kyverno/website/issues) and indicate your interest by requesting assignment. We understand that sometimes priorities change, so if you've been assigned an issue but are no longer able to or interested in completing it, please unassign yourself so future contributors know it is available to take on.

If you are new to the git contribution flow or GitHub in general, please see the [excellent documentation](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project) available on the Git website with easy, step-by-step instructions on how to create your first Pull Request on GitHub.

#### Overview

The Kyverno website is a static site designed and built using [Astro](https://astro.build/). It uses the [Starlight](https://starlight.astro.build/) documentation theme and is built and hosted on [Netlify](https://www.netlify.com/). The contents of the website are written as standard Markdown and MDX files allowing easy editing and contribution. For more detailed development information, see [DEVELOPMENT.md](./DEVELOPMENT.md).

#### Developing on GitHub Codespaces

This repository can be developed using [GitHub Codespaces](https://github.com/features/codespaces), which provides a containerized development environment with all the necessary tools. If a devcontainer configuration is available, creating a Codespace will automatically set up the environment with Node.js and npm.

If you are new to Codespaces and devcontainers, please see the introductory guide [here](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers).

#### Developing Locally

The Kyverno website requires Node.js v24 or higher and npm to be installed. When developing locally, ensure you have the correct Node.js version installed.

To check your Node.js version:

```sh
$ node --version
v24.11.1
```

You should see v24 or higher. If you need to install or update Node.js, visit [nodejs.org](https://nodejs.org/).

After cloning the repository, install dependencies:

```sh
npm install
```

For more detailed setup instructions, see [DEVELOPMENT.md](./DEVELOPMENT.md).

#### Testing Changes

Once you have made your changes, inspect them visually by rendering the website.

```sh
npm run dev
```

The development server will start at `http://localhost:4321`. The site will automatically reload when you make changes to source files.

For more information about testing and building, see [DEVELOPMENT.md](./DEVELOPMENT.md).

### Get In Touch

#### Slack

Kyverno maintains a thriving community with two different opportunities to participate. The largest is the [Kubernetes Slack workspace](https://slack.k8s.io/#kyverno) and the other is the [CNCF Slack workspace](https://cloud-native.slack.com/#kyverno).

#### Community Meetings

For the available Kyverno meetings, see [here](https://kyverno.io/community/#meetings).

## Developer Certificate of Origin (DCO) Sign off

For contributors to certify that they wrote or otherwise have the right to submit the code they are contributing to the project, we require everyone to acknowledge this by signing their work acknowledging the [DCO](https://developercertificate.org/).

For a complete guide on DCO, please see [this article](https://www.secondstate.io/articles/dco/).

For users of Visual Studio Code, there is a convenient setting in the git extension named "Always Sign Off" which, when checked, allows VS Code to sign all commits.
