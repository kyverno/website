---
title: Community
linkTitle: "Community"
type: docs
---

## GitHub

The [Kyverno source code](https://github.com/kyverno/kyverno/) and project artifacts are managed on GitHub in the [Kyverno](https://github.com/kyverno) organization.

## Slack Channel

Kyverno maintains a thriving community with two different opportunities to participate. The largest is the [Kubernetes Slack workspace](https://slack.k8s.io/#kyverno), where end-users engage in the [#kyverno](https://slack.k8s.io/#kyverno) channel and contributors collaborate in the [#kyverno-dev](https://slack.k8s.io/#kyverno-dev) channel. The other is the [CNCF Slack workspace](https://cloud-native.slack.com/#kyverno), where the [#kyverno](https://slack.k8s.io/#kyverno) channel is dedicated to end-user interactions.

## Community Meetings

### Community Meeting

This is a public, weekly for Kyverno the full community. First time participants, new contributors, or anyone interested in Kyverno are welcome! This forum allows community members to propose agenda items of any sort, including but not limited to releases, roadmap, any contributor PRs or issues on which they are working.

- Weekly every Wednesday at 9:00 AM PST
- [Agenda and meeting notes](https://docs.google.com/document/d/1kFd4fpAoHS56mRHr73AZp9wknk1Ehy_hTB_KA7gJuy0/)

To attend our community meetings, join the [Kyverno group](https://groups.google.com/g/kyverno). You will then be sent a meeting invite and will have access to the agenda and meeting notes. Any member may suggest topics for discussion.

### Maintainers Meeting

This is a public, weekly meetings for maintainers to discuss issues and PRs pertaining to Kyverno's development and roadmap. 

Topics are proposed by maintainers. Contributors and end users are welcome to attend and contributors, but may not propose new agenda items here but instead add to the [community meeting](#community-meeting) agenda.

- Weekly every Tuesday at 7:30 AM PST
- [Agenda and meeting notes](https://docs.google.com/document/d/1I_GWsz32gLw8sQyuu_Wv0-WQrtRLjn9FuX2KGNkvUY4/edit?usp=sharing)


### Nirmata Office Hours

This is a monthly meeting for the broader community where the Kyverno maintainers from [Nirmata](https://nirmata.com/) cover one or more topics with preference given to open community discussion, question and answer, etc. 

The meeting is live streamed on YouTube with recordings available after. Either join in person or attend in view-only mode:

- Monthly on the second Thursday at 7:00 AM PST
- [GitHub repository](https://github.com/nirmata/office-hours-for-kyverno)


## Get in touch

If you are unable to attend a community meeting, feel free to reach out anytime on the [Kyverno Slack channel in the Kubernetes workspace](https://slack.k8s.io/#kyverno), or the Kyverno [mailing list](https://groups.google.com/g/kyverno).

We love hearing from our community!

## Contributing

Thanks for your interest in contributing! We welcome all types of contributions and encourage you to read our [contribution guidelines](https://github.com/kyverno/kyverno/blob/main/CONTRIBUTING.md) for next steps.

The project contributors use a combination of [GitHub discussions](https://github.com/kyverno/kyverno/discussions) and the [#kyverno-dev Slack channel](https://kubernetes.slack.com/archives/C032MM2CH7X) for notes on the development environment, project guidelines, and best practices.

Developer documentation is available in the [DEVELOPER.md](https://github.com/kyverno/kyverno/blob/main/DEVELOPMENT.md) file. 

**NOTE:** Developer documentation was previously available in the ([GitHub Wiki](https://github.com/kyverno/kyverno/wiki)) but is no longer maintained there. 

To start contributing, take a look at available issues in the [Good First Issues](https://github.com/orgs/kyverno/projects/10) project.

## Join Kyverno Adopters

Kyverno is a CNCF incubating project and is growing fast. To qualify for the [graduation level](https://github.com/cncf/toc/blob/main/process/graduation_criteria.md#graduation-stage) the CNCF requires production usage by multiple end users.

The goal of this adopters program is to gather real-world usage examples and help the Kyverno project grow. We hope to achieve this by learning from the existing and new adopters of Kyverno who are willing to share their stories with CNCF.

To participate, fill out the [Kyverno adopters form](https://forms.gle/K5CApcBAD5D4H1AG8).

## Project Governance

This document highlights the roles and responsibilities for the Kyverno community members. It also outlines the requirements for anyone who is looking to take on leadership roles in the Kyverno project. The following governance applies to all Kyverno subprojects.

**Note:** Please make sure to read the CNCF [Code of Conduct](https://github.com/cncf/foundation/blob/master/code-of-conduct.md).

### Project Roles

The table below summarizes project roles and responsibilities. Details are provided in the sections following the table:

| Role | Requirements | Ongoing Responsibilities | Defined by |
| ------------ | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Contributors | At least five (5) contributions to the project.   | None | CONTRIBUTORS.md                                   |
| Code Owner   | At least ten (10) significant contributions and appointed by 2 maintainers. Highly experienced and active reviewer + contributor to a subproject. | Active contributions, assist maintainers, review and approve contributions.| Maintainers, [CODEOWNERS](https://help.github.com/en/articles/about-code-owners), GitHub organization member. |
| Maintainer   | Highly experienced and active contributor + Kyverno Certification + Voted in by Kyverno maintainers. | Code Owner, monitor project growth, set direction and priorities for a subproject. | Voted in by the Kyverno maintainers, listing in `MAINTAINERS.md`, GitHub organization member, and repository owner. |

#### Contributors

Contributors are individuals who have made at least five (5) contributions to the project; by authoring PRs, commenting on issues and pull requests, and participating in community discussions on Slack or the mailing list.

**Checklist before becoming a Contributor**

- Have at least five (5) PRs successfully merged for any repositories under the Kyverno organization
- Member of the kyverno channel on Kubernetes and/or CNCF Slack
- Attended one (1) Contributors Meeting as documented
- Registered for the Kyverno [mailing list](https://groups.google.com/g/kyverno)

**Privileges of a Contributor**

- Listed in the file in at least one (1) organization repository
- Kyverno contributor badge issued

To join the Kyverno project as a Contributor create a Pull Request (PR) in the [Kyverno repository](https://github.com/kyverno/kyverno) with the following:
1. Changes to add yourself to the [CONTRIBUTORS.md](https://github.com/kyverno/kyverno/blob/main/CONTRIBUTORS.md) file.
2. Links to your prior contributions (at least five).
3. Links to slack discussions, issue comments, etc.

#### Code Owners

Code Owners are a special type of contributor and have _significantly_ contributed and maintain an _active_ status within the organization. They can have issues and PRs assigned to them and are responsible for providing PR reviews. Unlike Contributors, Code Owners have responsibilities and must maintain an active status defined below to remain a Code Owner.

**Checklist before becoming a Code Owner**

- Have at least ten (10) significant PRs successfully merged for any combination of repositories under the Kyverno organization
- Member of the kyverno channel on Kubernetes and/or CNCF Slack
- Attended five (5) Contributors Meetings as documented
- Registered for the Kyverno [mailing list](https://groups.google.com/g/kyverno)
- Create a pull request to add self to `CODEOWNERS` file in at least one (1) repository
- Attained a minimum of two (2) positive votes from maintainers
- Respond to reviews from maintainers on pull requests

**Responsibilities of a Code Owner**

- Maintain an active status in a three (3) month period to include any of the following:
  - One (1) PR filed
  - Any request for PR review responded to
  - One (1) issue or PR responded to
  - One (1) Slack thread responded to
  - Two (2) attendance at weekly Contributors Meetings

**Privileges of a Code Owner**

- Listed as an organization member
- Listed in `CODEOWNERS` in at least one (1) repository
- Kyverno contributor badge issued
- Have issues assigned to them
- Have PRs assigned to them

**On-boarding Criteria**

- Voted in by a majority of current maintainers, raised in a PR by the proposed member to add themselves to `CODEOWNERS`, during a voting period lasting seven (7) days

**Off-boarding Criteria**

- Voted out by a majority of current maintainers via a GitHub issue during a voting period lasting seven (7) days. A vote may be called by any maintainer after the point at which the responsibilities have not been met. A positive vote will result in removal from `CODEOWNERS` and from organization membership.

#### Maintainers

Maintainers are individuals who go beyond the status of code owner who have shown good technical judgement in feature design/development in the past. Maintainers have overall knowledge of the project and features in the project. They can read, clone, and push to the repository. They can also manage issues, pull requests, and some repository settings.

[Maintainers](https://docs.github.com/en/organizations/managing-access-to-your-organizations-repositories/repository-roles-for-an-organization#repository-access-for-each-permission-level) are the technical authority for a subproject and are considered leaders for the organization as a whole. They must have demonstrated both good judgement and responsibility towards the health of the subproject. Maintainers must set technical direction and make or approve design decisions for their subproject, either directly or through delegation of these responsibilities. Unlike contributors and code owners, maintainers have the highest degree of responsibility and ownership for the project. Maintainer status may be subject to a vote and, if the minimum level of activity is not maintained, may be moved to an _emeritus_ status.

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
- Has achieved the Kyverno Certification or demonstrated an equivalent mastery of Kyverno
- Meets or exceeds all the requirements of a Code Owner
- Maintains an active status as a Code Owner for a period of six (6) months

**Responsibilities of a Maintainer**

- All the responsibilities of a Code Owner
- Tracks and ensures adequate health of the modules and subprojects they are in charge of
- Ensures adequate test coverage to confidently release new features and fixes
- Ensures that tests are passing reliably (i.e. not flaky) and are fixed when they fail
- Mentors and guides code owners, reviewers, and contributors
- Actively participates in the processes for discussion and decision making in the project
- Merges Pull Requests and helps prepare releases
- Makes and approves technical design decisions for the subproject
- Helps define milestones and releases
- Decides on when PRs are merged to control the release scope
- Works with other maintainers to maintain the project's overall health and success holistically

**Privileges of a Maintainer**

- Privileges of a Code Owner
- Receives a Kyverno Maintainer Badge
- Listed in `MAINTAINERS.md`

**On-boarding Criteria**

- Voted in by a majority of current maintainers, raised in a PR by the proposed member to add themselves to `MAINTAINERS.md`, during a voting period lasting seven (7) days

**Off-boarding Criteria**

An off-boarding vote may be called by any maintainer if any of the following criteria are met:
- A maintainer has made less than 30 contributions over a span of 6 months.
  - Contributions can be tracked using the [DevStats dashboard](https://kyverno.devstats.cncf.io/d/66/developer-activity-counts-by-companies?orgId=1&var-period_name=Last%206%20months&var-metric=contributions&var-repogroup_name=All&var-country_name=All&from=1522810884223&to=1680577284223&var-companies=All).
  - Other relevant data will be collected and evaluated to assess the maintainer's contributions. This includes their involvement in discussions, conversations on Slack, and any other relevant interactions.

The off-boarding process includes the following steps:
- The off-boarding process is initiated by any currently active maintainer who conducts a review of the maintainers list and proceeds to initialize the off-boarding process if the above criteria are met.
- The plans of off-boarding process is sent in a private Slack message or email to the candidate.
- If the candidate for removal states plans to continue participating, another 6 months will be granted to the candidate to make contributions and the new cycle starts. No action is taken and this process terminates.
- If the candidate fails to meet the criteria during the second attempt to make contributions, the off-boarding process continues.
- A pull request (PR) proposing movement of the candidate is sent, initiating the public voting phase.
- The vote passes if a majority of current maintainers vote yes during a voting period lasting seven (7) days.
- A positive vote will result in movement to an _emeritus_ status within `MAINTAINERS.md` and removal from organization membership.

#### Admins

These are persons who have full access to the project, including sensitive and destructive actions like managing security or deleting a repository. Admins can read, clone, and push to this repository. They can also manage issues, pull requests, and repository settings, including adding collaborators.

#### Mapping Project Roles to GitHub Roles

The roles used in this document are custom roles mapped according to the [GitHub roles and responsibilities](https://docs.github.com/en/organizations/managing-access-to-your-organizations-repositories/repository-roles-for-an-organization).

| Project Role   | GitHub Role    |
| -------------- | -------------- |
| Contributor    | Triage         |
| Code Owner     | Write          |
| Maintainer     | Maintain       |
| Administrator  | Admin          |

### Off-boarding Guidance

If any of the above roles hasn't contributed in any phases (including, but not limited to: code changes, doc updates, issue discussions) in 3 months, the administrator needs to inform the member and remove one's roles and GitHub permissions.
