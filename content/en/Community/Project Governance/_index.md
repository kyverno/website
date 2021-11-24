---
title: Project Governance
linkTitle: "Project Governance"
description: This document gives a brief overview of the Kyverno community roles with the requirements and responsibilities associated with them.
weight: 10
---

## Kyverno Project Roles

This document identifies the role and responsibilities for the Kyverno community members. It also highlights the requirements for anyone who is looking to take on leadership roles in the Kyverno project.

In order to perform any actions on the Kyverno Github repositories, contributors should have certain access to GitHub, such as creating a pull request in a repository or changing an organization's billing settings, a contributor must have sufficient access to the relevant account or resource.

**Note:** Please make sure to read and observe our [Code of Conduct](https://github.com/cncf/foundation/blob/master/code-of-conduct.md).

### Leadership Roles

**Contributors**:

These are active contributors who have made multiple contributions to the project; by authoring PRs, reviewing issues/PRs or participate in community discussions on slack/mailing list.

**Approver**:

These are active contributors who have good experience and knowledge of the project. They are expected to proactively manage issues and pull requests without write access.

**Maintainer**:

They are approvers who have shown good technical judgement in feature design/development in the past. Has overall knowledge of the project and features in the project. These role is for project managers who are expected to manage the repository without access to sensitive or destructive actions.

**Admin**:

These are persons who have full access to the project, including sensitive and destructive actions like managing security or deleting a repository.

| Role         | Responsibilities                                                      | Requirements                                                                                  | Defined by                                                                                                                   |
| ------------ | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Contributors | active contributor in the community. reviewer of PRs                  | made at least five contributions to the project & appointed by 2 approvers or maintainers.    | [CODEOWNERS](https://help.github.com/en/articles/about-code-owners), Github Org members.                                     |
| Approver     | assist maintainers Review & approve contributions                     | highly experienced and active reviewer + contributor to a subproject.                         | Maintainers & [CODEOWNERS](https://help.github.com/en/articles/about-code-owners).                                           |
| Maintainer   | monitor project growth, set direction and priorities for a subproject | highly experienced and active reviewer + Kyverno Certification + Voted by Kyverno maintainers | Voted in by the Kyverno maintainers, [CODEOWNERS](https://help.github.com/en/articles/about-code-owners) & Repository owner. |
| Owner        |                                                                       |                                                                                               | Not opposed by any project owner.                                                                                            |

### Contributor

Project members are continuously active contributors in the project. They can have issues and PRs assigned to them and remain active contributors to the community.

**Checklist before becoming a Project Member**

- Create pull requests for code changes.
- Respond to reviews from maintainers on pull requests.
- Attend community and [project meetups](https://groups.google.com/g/kyverno)..
- Register for mailing lists.
- Always tries to find ways to help.
- Actively contributing to 1 or more subprojects.

**Responsibilities & Privileges**

- Have an issue assigned to them.
- Authoring PRs.
- Open issues.
- Close issues they opened themselves
  submit reviews on pull requests.

### Approver

Code approvers are able to both review and approve code contributions, as well as help maintainers, triage issues and do project management.

While code review is focused on code quality and correctness, approval is focused on holistic acceptance of a contribution including backwards/forwards compatibility, adhering to API and flag conventions, subtle performance and correctness issues, interactions with other parts of the system. Approvers are encouraged to be active participants in project meetings, chat rooms, and other discussion forums.

**Checklist before becoming an Approver**

- Consistently monitors project activities such as issues created, new PR.
- Has been active on the project for over 2 month
- Successfully reviewed projects codebase for at least 1month.
- Has an in-depth understanding of the project's codebase.
- Sponsor from 2 maintainers.

**Responsibilities & Privileges**

- Understand the project goals and workflows defined by maintainers.
- Creates new issues according to the project requirements.
- Assign issues to contributors.
- Respond to new PRs and Issues by asking clarifying questions.
- Organize the backlog by applying labels, milestones, assignees, and projects.
- Readily available to review and approve PR, by making meaningful suggestions.
- Edit and delete anyone's comments on commits, pull requests, and issues

### Maintainer

Maintainers are the technical authority for a subproject. They MUST have demonstrated both good judgement and responsibility towards the health of that subproject. Maintainers MUST set technical direction and make or approve design decisions for their subproject - either directly or through delegation of these responsibilities.

**Checklist before becoming a Project Maintainer:**

- Proficient in GitHub, Yaml, Markdown & Git.
- Strong attention to detail with an analytical mind and outstanding problem-solving skills.
- Holds good knowledge in helping others achieve their goals.
- Understands the workflow of the Issues and Pull Requests.
- Makes consistent contributions to the Kyverno project-
- Consistently scheduling and participating in [Kyerno meetups](https://groups.google.com/g/kyverno).
- Holds knowledge and interest that aligns with the overall project goals, specifications and design principles of the Kyverno project.
- Makes contributions that are considered notable.
- Creates at least 10 PR.
- Creates at least 5 issues.
- Drops at least 10 comments or reviews
- Ability to help troubleshoot and resolve user issues.
- Has taken the [Kyverno Free Certification](https://learn.nirmata.com/explore), or demonstrated sound understanding of Kyverno.

**Responsibilities & Privileges**

The following responsibilities apply to the subproject for which one would be an owner.

- Tracks and ensures adequate health of the subprojects they are in charge of.
- Adequate test coverage to confidently release
- Tests are passing reliably (i.e. not flaky) and are fixed when they fail
  Mentor and guide approvers, reviewers, and contributors in the Kyverno subproject.
- Actively participates in the processes for discussion and decision making in the project.
- Merge a pull request.
- Make and approve technical design decisions for the subproject.
- Define milestones and releases.
- Decides on when PRs are merged to control the release scope.
- Work with other maintainers to maintain the project's overall health and success holistically.
- Receive a Kyverno Maintainer Badge on Credly.
