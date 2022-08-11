---
title: Community
linkTitle: "Community"
type: docs
---

## GitHub

The [Kyverno source code](https://github.com/kyverno/kyverno/) and project artifacts are managed on GitHub in the [Kyverno](https://github.com/kyverno) organization.

## Slack Channel

Join the Kubernetes Slack workspace at [https://slack.k8s.io/](https://slack.k8s.io/) and then search for the [#kyverno](https://slack.k8s.io/#kyverno) channel.

If you already have access to the Kubernetes Slack workspace simply select "sign in" at [https://slack.k8s.io/#kyverno](https://slack.k8s.io/#kyverno).

## Community Meetings

To attend our community meetings, join the [Kyverno group](https://groups.google.com/g/kyverno). You will then be sent a meeting invite and will have access to the agenda and meeting notes. Any member may suggest topics for discussion.

### Community Meeting

This is a monthly meeting for the broader community in which upcoming features and road map discussions take place:

- Monthly on the second Thursday at 9:00 AM PST
- [Agenda and meeting notes](https://docs.google.com/document/d/10Hu1qTip1KShi8Lf_v9C5UVQtp7vz_WL3WVxltTvdAc/edit#)

### Contributors Meeting

This is a weekly forum for Kyverno contributors and maintainers to discuss project delivery and implementation topics such as feature designs, fixes, code, and documentation:

- Weekly every Wednesday at 9:00 AM PST
- [Agenda and meeting notes](https://docs.google.com/document/d/1kFd4fpAoHS56mRHr73AZp9wknk1Ehy_hTB_KA7gJuy0/)

## Get in touch

If you are unable to attend a community meeting, feel free to reach out anytime on the [Kyverno Slack channel in the Kubernetes workspace](https://slack.k8s.io/#kyverno), or the Kyverno [mailing list](https://groups.google.com/g/kyverno).

We love hearing from our community!

## Contributing

Thanks for your interest in contributing! We welcome all types of contributions and encourage you to read our [contribution guidelines](https://github.com/kyverno/kyverno/blob/main/CONTRIBUTING.md) for next steps.

The project contributors use a combination of [GitHub discussions](https://github.com/kyverno/kyverno/discussions), [GitHub Wiki](https://github.com/kyverno/kyverno/wiki) for design documents, and the [#kyverno-dev Slack channel](https://kubernetes.slack.com/archives/C032MM2CH7X) for notes on the development environment, project guidelines, and best practices.

## Join Kyverno Adopters

Kyverno is a CNCF sandbox project is growing fast. To qualify for the [incubation level](https://github.com/cncf/toc/blob/main/process/graduation_criteria.md) the CNCF requires production usage by multiple end users.

The goal of this adopters program is to gather real-world usage examples and help Kyverno achieve the incubating state criteria. We hope to achieve this by learning from the existing and new adopters of Kyverno who are willing to share their stories with CNCF. The adopters can remain private or choose to be listed in the public [Adopters List](https://github.com/kyverno/kyverno/blob/main/ADOPTERS.md).

To participate, fill out the [ Kyverno adopters form](https://docs.google.com/forms/d/e/1FAIpQLSeMJxbK6eQ-MpsbaXZ3GKp8NEz9F932keL2pwznI1JIfi7Iqw/viewform).

## Project Governance

This document highlights the roles and responsibilities for the Kyverno community members. It also outlines the requirements for anyone who is looking to take on leadership roles in the Kyverno project.

**Note:** Please make sure to read the CNCF [Code of Conduct](https://github.com/cncf/foundation/blob/master/code-of-conduct.md).

### Project Roles

**Contributors**:

These are active contributors who have made multiple contributions to the project; by authoring PRs, commenting on issues and pull requests, or participating in community discussions on Slack or the mailing list.

**Approver**:

These are active contributors who have good experience and knowledge of the project. They are expected to proactively manage issues and pull requests without write access.

**Maintainer**:

They are approvers who have shown good technical judgement in feature design/development in the past. Maintainers have overall knowledge of the project and features in the project. They can read, clone, and push to the repository. They can also manage issues, pull requests, and some repository settings.

**Admin**:

These are persons who have full access to the project, including sensitive and destructive actions like managing security or deleting a repository. Admins can read, clone, and push to this repository. They can also manage issues, pull requests, and repository settings, including adding collaborators.

| Role         | Responsibilities                                                      | Requirements                                                                                  | Defined by                                                                                                                   |
| ------------ | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Contributors | Active contributor in the community. Reviewer of PRs                  | Made at least five contributions to the project and appointed by 2 approvers or maintainers.    | [CODEOWNERS](https://help.github.com/en/articles/about-code-owners), Github Org members.                                     |
| Approver     | Assist maintainers. Review and approve contributions.                     | Highly experienced and active reviewer + contributor to a subproject.                         | Maintainers & [CODEOWNERS](https://help.github.com/en/articles/about-code-owners).                                           |
| Maintainer   | Monitor project growth, set direction and priorities for a subproject. | Highly experienced and active reviewer + Kyverno Certification + Voted in by Kyverno maintainers. | Voted in by the Kyverno maintainers, [CODEOWNERS](https://help.github.com/en/articles/about-code-owners) and repository owner. |

#### Contributors

Contributors are project members who are continuously active in the community. They can have issues and PRs assigned to them and remain active contributors to the community.

**Checklist before becoming a Project Member**

- Create pull requests for code changes
- Respond to reviews from maintainers on pull requests
- Attend community and [project meetups](https://groups.google.com/g/kyverno)
- Register for mailing lists
- Always tries to find ways to help
- Actively contributing to 1 or more subprojects

**Responsibilities & Privileges**

- Have an issue assigned to them
- Authoring PRs
- Open issues
- Close issues they opened themselves
- Submit reviews on pull requests

#### Approvers

Approvers are contributors who provide active review and feedback on the issues and PRs. While code review is focused on code quality and correctness, approval is focused on holistic acceptance of a contribution including backwards and forwards compatibility, adhering to API and flag conventions, subtle performance and correctness issues, and interactions with other parts of the system. Approvers are encouraged to be active participants in project meetings, chat rooms, and other discussion forums.

**Checklist before becoming an Approver**

- Consistently monitors project activities such as issues created and new PRs
- Has been active on the project for over two months
- Successfully reviewed project codebase for at least one month
- Has an in-depth understanding of the project's codebase
- Sponsored by at least two maintainers

**Responsibilities & Privileges**

- Understands the project goals and workflows defined by maintainers
- Creates new issues according to the project requirements
- Assigns issues to contributors
- Responds to new PRs and issues by asking clarifying questions
- Organizes the backlog by applying labels, milestones, assignees, and projects
- Is readily available to review and approve PRs by making meaningful suggestions
- Applies code of conduct to edit and delete any inappropriate comments on commits, pull requests, and issues

#### Maintainers

[Maintainers](https://docs.github.com/en/organizations/managing-access-to-your-organizations-repositories/repository-roles-for-an-organization#repository-access-for-each-permission-level) are the technical authority for a subproject. They must have demonstrated both good judgement and responsibility towards the health of the subproject. Maintainers must set technical direction and make or approve design decisions for their subproject, either directly or through delegation of these responsibilities.

**Checklist before becoming a Maintainer:**

- Proficient in GitHub, YAML, Markdown, and Git
- Exhibits strong attention to detail when reviewing commits and provides generous guidance and feedback
- Helps others achieve their goals with open-source and community contributions
- Understands the workflow of the Issues and Pull Requests
- Makes consistent contributions to the Kyverno project
- Consistently initiates and participates in [Kyverno discussions](https://slack.k8s.io/#kyverno)
- Has knowledge and interest that aligns with the overall project goals, specifications, and design principles of the Kyverno project
- Makes contributions that are considered notable
- Demonstrates ability to help troubleshoot and resolve user issues
- Has achieved the [Kyverno Certification](https://learn.nirmata.com/explore), or demonstrated an equivalent mastery of Kyverno

**Responsibilities & Privileges**

The following responsibilities apply to the subproject for which one would be an owner.

- Tracks and ensures adequate health of the modules and subprojects they are in charge of
- Ensures adequate test coverage to confidently release new features and fixes
- Ensures that tests are passing reliably (i.e. not flaky) and are fixed when they fail
- Mentors and guides approvers, reviewers, and contributors
- Actively participates in the processes for discussion and decision making in the project
- Merges Pull Requests and helps prepare releases
- Makes and approves technical design decisions for the subproject
- Helps define milestones and releases
- Decides on when PRs are merged to control the release scope
- Works with other maintainers to maintain the project's overall health and success holistically
- Receives a Kyverno Maintainer Badge on Credly

#### Mapping Project Roles to GitHub Roles

The roles used in this document are custom roles mapped according to the [GitHub roles and responsibilities](https://docs.github.com/en/organizations/managing-access-to-your-organizations-repositories/repository-roles-for-an-organization).

| Project Role   | GitHub Role    |
| -------------- | -------------- |
| Contributor    | Triage         |
| Approver       | Write          |
| Maintainer     | Maintain       |
| Administrator  | Admin          |

### Off-boarding Guidance

If any of the above roles hasn't contributed in any phases (including, but not limited to: code changes, doc updates, issue discussions) in 3 months, the administrator needs to inform the member and remove one's roles and GitHub permissions.