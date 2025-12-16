---
date: 2023-02-01
title: Kyverno and SLSA 3
linkTitle: Kyverno and SLSA 3
description: How the Kyverno project believes it is meeting SLSA Level 3 requirements.
draft: false
category: General
---

With the release of Kyverno 1.9, Kyverno has begun generating and attesting to the provenance of its release artifacts in the [SLSA](https://security.googleblog.com/2021/06/introducing-slsa-end-to-end-framework.html) standard and provisionally meet Level 3. This blog post attempts to explain a bit about SLSA and Level 3 and how we meet the requirements. Once the [Open Source Security Foundation](https://openssf.org/) (OpenSSF) establishes its conformance program, we hope to see official acknowledgement of this process.

## About SLSA

Supply Chain Levels for Software Artifacts, or SLSA (pronounced "salsa"), is a security framework which aims to prevent tampering and secure artifacts in a project. SLSA helps in mitigating supply chain threats. SLSA compliance is based on four levels. Level 1 starts with basic requirements and achieving level 4 requires strict hardening of the supply chain platform.

The following diagram depicts the several known points of attacks. For extensive documentation, refer to https://slsa.dev.

![slsa](SupplyChainDiagram.svg)

(_Graphic source: slsa.dev_)

## SLSA Requirements and Kyverno Compliance State

SLSA divides the requirements into three main areas: source, build, and integrity. Each area has sub-requirements to meet certain levels. Since Kyverno claims to achieve SLSA level 3, this document will explain how we are achieving that. For a complete summary of SLSA requirements, refer to the official SLSA project pages at https://slsa.dev/spec/v1.0/requirements.

### Source Requirements

| Requirement           | Required at SLSA Level 3     | Met by Kyverno |
| --------------------- | ---------------------------- | -------------- |
| Version controlled    | Yes                          | Yes            |
| Verified history      | Yes                          | Yes            |
| Retained indefinitely | Yes (for 18 months or above) | Yes            |

#### Version Controlled

**Description:**
The source code should be tracked in a version-controlled system. The version control system should maintain the history of changes. The identification of uploaders and reviewers (if any), timestamps of the reviews, its content, and the parent reviews. Each revision should be tracked back using an immutable reference. These requirements are met by most of the revision systems, e.g git.

**Kyverno Processes:**
Kyverno uses GitHub for source code management. Each commit gives info about the author, an explanation about the commit, and the time at which the commit was generated.

#### Verified History

**Description:**
The history of a revision must be trackable. It should contain a timestamp and a strongly authenticated user (author, uploader, reviewer, etc.). The identities must use two-step verification or similar.

**Kyverno Processes:**
Each commit in Kyverno contains a timestamp and info about the author. It also gives an explanation about the commit.

#### Retained Indefinitely

**Description:**
If there are no legal or policy requirements, the revision and its change history must be preserved indefinitely and cannot be deleted. For SLSA Level 3, the retention can be limited to 18 months.

**Kyverno Processes:**
The git tree remains unaltered. The source code of the build is archived.

### Build Requirements

The conversion of source code into the build is the responsibility of the build system. The build system must be secured against any sort of outside intervention. The build system should produce the builds in a reproducible manner for verification.

| Requirement           | Required at SLSA Level 3 | Met by Kyverno |
| --------------------- | ------------------------ | -------------- |
| Scripted build        | Yes                      | Yes            |
| Build service         | Yes                      | Yes            |
| Build as code         | Yes                      | Yes            |
| Ephemeral environment | Yes                      | Yes            |
| Isolated              | Yes                      | Yes            |

#### Scripted Build

**Description:**
All build steps should be defined in the build script. e.g Makefile or GitHub action workflow file. The invocation command for build script is the only manual command allowed.

**Kyverno Processes:**
Since the Kyverno code base is stored in GitHub, GitHub Actions are used to invoke build scripts. Kyverno uses a mix of Makefile and GitHub Workflows. Everything is declared inside build scripts.

#### Build Service

**Description:**
The build step should be executed on some build service environment e.g GitHub Action, AWS CodePipeline. The developer workstation doesn't qualify as a build service.

**Kyverno Processes:**
As mentioned above, the Kyverno source code is stored in GitHub. Kyverno relies on GitHub Actions as a build service environment.

#### Build As Code

**Description:**
The build definition and configuration used by the build service to generate the build must be derived from text files. The build-as-code files need to be stored in the version control system.

**Kyverno Processes:**
The build is generated by executing GitHub workflows. The build definition and configuration are all defined in workflow files under the directory `.github/workflows/` in the [kyverno/kyverno repository](https://github.com/kyverno/kyverno).

#### Ephemeral Environment

**Description:**
The build step should be executed in an ephemeral environment. The environment should be solely created for this build and must not be reused. e.g container or VM.

**Kyverno Processes:**
Kyverno relies on GitHub Actions as a build service environment. GitHub uses the concept of runners and the Kyverno project uses [GitHub-hosted runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners). For each job, a new virtual machine is created.

#### Isolated

**Description:**
The build step should be executed independently of each other. The build instance, either prior or concurrent, should not influence others.

**Kyverno Processes:**
The GitHub-hosted runners run each job in a separate virtual machine. When the job has finished, the VM is automatically decommissioned.

### Provenance Requirements

In order to prove that build was produced and artifacts were produced according to SLSA Level 3, SLSA mentions some requirements for provenance which can be grouped into the following:

- Requirements on the process by which provenance is generated and consumed
- Requirements on the content of the provenance

Kyverno relies on the official [SLSA GitHub Generator project](https://github.com/slsa-framework/slsa-github-generator) for provenance generation. For more information on the generator project, see https://github.com/slsa-framework/slsa-github-generator.

**Requirements on the process by which provenance is generated and consumed**

| Requirement       | Required at SLSA Level 3 | Met by Kyverno |
| ----------------- | ------------------------ | -------------- |
| Available         | Yes                      | Yes            |
| Authenticated     | Yes                      | Yes            |
| Service generated | Yes                      | Yes            |
| Non-falsifiable   | Yes                      | Yes            |

#### Available

**Description:**
The provenance should be provided to the customer in a format accepted by the customer.

**Kyverno Processes:**
Kyverno relies on the official [SLSA GitHub generator framework](https://github.com/slsa-framework/slsa-github-generator) to provide provenance in the [in-toto](https://in-toto.io/) format. The provenance is attested using the [Sigstore](https://www.sigstore.dev/) [cosign](https://github.com/sigstore/cosign) project and is publicly available as an image artifact on GitHub Container Registry stored in the same repository as the Kyverno container images themselves. This repository and its contents can be publicly pulled without authentication.

#### Authenticated

**Description:**
The consumer can verify the authenticity and integrity of the provenance.

**Kyverno Processes:**
The provenance is signed by OIDC identity and the public key to verify the provenance is stored in the public [Rekor transparency log](https://docs.sigstore.dev/rekor/overview/). If someone tampers with the file then the signature will fail to verify. Anyone can verify the provenance for Kyverno artifacts with the process documented [here](../../../docs/security/_index.md#verifying-provenance).

#### Service Generated

**Description:**
The provenance data should be obtained from the build service.

**Kyverno Processes:**
The GitHub Action reusable workflow hosted by the SLSA GitHub Generator project creates the provenance file. The caller workflow from the Kyverno project is `release.yaml` and the called workflow is `generator_container_slsa3.yml`. The necessary data to the called workflow is passed in the form of variables and secrets. The called workflow is a third-party workflow which is used by Kyverno for provenance generation and any actions in the called workflow run as if they were part of the caller workflow.

#### Non-Falsifiable

**Description:**
The build service's users can not falsify the provenance.

**Kyverno Processes:**
GitHub takes care of avoiding interference with the build system. GitHub uses ephemeral and isolated virtual machines, no one can persistently compromise this environment. GitHub automatically provisions a new VM for that job. When the job execution is finished, the VM is automatically decommissioned. Use of the [SLSA GitHub generator](https://github.com/slsa-framework/slsa-github-generator) separates the signing from building so the Kyverno build itself never has access to the signing secrets. Use of OIDC-based secrets through Sigstore's [keyless signing](https://docs.sigstore.dev/cosign/signing/overview/) means the ephemeral signing secret is associated only with one specific build making it easy to detect secret theft and an attempt at signing something else.

### Provenance Content Requirements

| Requirement                   | Required at SLSA Level 3 | Met by Kyverno |
| ----------------------------- | ------------------------ | -------------- |
| Identifies artifact           | Yes                      | Yes            |
| Identifies builder            | Yes                      | Yes            |
| Identifies build instructions | Yes                      | Yes            |
| Identifies source code        | Yes                      | Yes            |
| Identifies entry point        | Yes                      | Yes            |
| Includes all build parameters | Yes                      | Yes            |

#### Identifies Artifact

**Description:**
The output artifact must be identified by provenance by at least one cryptographic hash.

**Kyverno Processes:**
The provenance file stores SHA-256 hashes of build artifacts. The provenance identifies the container image using its digest in SHA-256 format.

#### Identifies Builder

**Description:**
The entity who executed the build process and generated the provenance should be identified by provenance.

**Kyverno Processes:**
The id of the builder is added to provenance in the `predicate.builder` section. In case of Kyverno, GitHub Actions act as the builder. The build logic is defined inside GitHub workflows file. The provenance generation logic is in a separate reusable workflow which is recorded in the `predicate.builder` section. As an example, refer to the [Provenance Example](#provenance-example) section.

#### Identifies Build Instructions

**Description:**
The top-level instruction that was executed to initiate the build should be available in the provenance file.

**Kyverno Processes:**
The top-level instruction is the GitHub Action workflow which is calling the provenance generation workflow. This is recorded in `invocation.entrypoint` in the provenance file. In Kyverno's case, it is `release.yaml`. The SLSA requirements mentions that "The identified instructions should be at the highest level available to the build" so it doesn't necessarily need to record all the the instructions as they are part of workflow file. As an example, refer to the [Provenance Example](#provenance-example) section.

#### Identifies Source Code

**Description:**
The repository origin of the source code used in the build must be identified in provenance.

**Kyverno Processes:**
The repository information is stored in the provenance file. This is recorded in the `predicate.invocation` section. As an example, refer to the [Provenance Example](#provenance-example) section.

#### Identifies Entry Point

**Description:**
The processes which started the build processes should be identified by provenance.

**Kyverno Processes:**
The required information is stored in the `invocation.configSource.entryPoint` in the provenance file. As an example, refer to the [Provenance Example](#provenance-example) section.

#### Include All Build Parameters

**Description:**
The provenance must include all the build parameters which are under user control.

**Kyverno Processes:**
The main GitHub Action workflow file does not accept any parameters. The `workflow_dispatch` section in the `release.yaml` file does not accept any parameters. At SLSA level 3 the parameters, if any, must be listed. At SLSA level 4, the parameters must be empty.

### Provenance Example

The following is an example of the generated provenance for Kyverno which will be returned from the process documented [here](../../../docs/security/_index.md#verifying-provenance).

```json
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "ghcr.io/kyverno/kyverno",
      "digest": {
        "sha256": "96a54a5747485b800adf05ff84d48fc9a8b66f1cdf9087cbed385dacc1cdb4d6"
      }
    }
  ],
  "predicate": {
    "builder": {
      "id": "https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@refs/tags/v1.4.0"
    },
    "buildType": "https://github.com/slsa-framework/slsa-github-generator/container@v1",
    "invocation": {
      "configSource": {
        "uri": "git+https://github.com/kyverno/kyverno@refs/tags/v1.9.0-beta.2",
        "digest": {
          "sha1": "ab368ebc080535448aa08fafdff82a4d4c69e127"
        },
        "entryPoint": ".github/workflows/release.yaml"
      },
      "parameters": {},
      "environment": {
        "github_actor": "realshuting",
        "github_actor_id": "25727662",
        "github_base_ref": "",
        "github_event_name": "push",
        "github_event_payload": {
          "after": "9d6e981a64b0b8dc357befb7fc811304d7b11f7b",
          "base_ref": null,
          "before": "0000000000000000000000000000000000000000",
          "commits": [],
          "compare": "https://github.com/kyverno/kyverno/compare/v1.9.0-beta.2",
          "created": true,
          "deleted": false,
          "enterprise": {
            "avatar_url": "https://avatars.githubusercontent.com/b/9995?v=4",
            "created_at": "2021-11-03T14:57:36Z",
            "description": "",
            "html_url": "https://github.com/enterprises/cncf",
            "id": 9995,
            "name": "Cloud Native Computing Foundation",
            "node_id": "E_kgDNJws",
            "slug": "cncf",
            "updated_at": "2022-12-27T16:04:12Z",
            "website_url": "https://cncf.io"
          },
          "forced": false,
          "head_commit": {
            "author": {
              "email": "shuting@nirmata.com",
              "name": "shuting",
              "username": "realshuting"
            },
            "committer": {
              "email": "noreply@github.com",
              "name": "GitHub",
              "username": "web-flow"
            },
            "distinct": true,
            "id": "ab368ebc080535448aa08fafdff82a4d4c69e127",
            "message": "tag v1.9.0-beta.2 (#5959)",
            "timestamp": "2023-01-10T11:45:52Z",
            "tree_id": "95c14e810108e4125c571ba33483204f4b078900",
            "url": "https://github.com/kyverno/kyverno/commit/ab368ebc080535448aa08fafdff82a4d4c69e127"
          },
          "organization": {
            "avatar_url": "https://avatars.githubusercontent.com/u/68448710?v=4",
            "description": "Kubernetes Native Policy Management",
            "events_url": "https://api.github.com/orgs/kyverno/events",
            "hooks_url": "https://api.github.com/orgs/kyverno/hooks",
            "id": 68448710,
            "issues_url": "https://api.github.com/orgs/kyverno/issues",
            "login": "kyverno",
            "members_url": "https://api.github.com/orgs/kyverno/members{/member}",
            "node_id": "MDEyOk9yZ2FuaXphdGlvbjY4NDQ4NzEw",
            "public_members_url": "https://api.github.com/orgs/kyverno/public_members{/member}",
            "repos_url": "https://api.github.com/orgs/kyverno/repos",
            "url": "https://api.github.com/orgs/kyverno"
          },
          "pusher": {
            "email": "shutting06@gmail.com",
            "name": "realshuting"
          },
          "ref": "refs/tags/v1.9.0-beta.2",
          "repository": {
            "allow_forking": true,
            "archive_url": "https://api.github.com/repos/kyverno/kyverno/{archive_format}{/ref}",
            "archived": false,
            "assignees_url": "https://api.github.com/repos/kyverno/kyverno/assignees{/user}",
            "blobs_url": "https://api.github.com/repos/kyverno/kyverno/git/blobs{/sha}",
            "branches_url": "https://api.github.com/repos/kyverno/kyverno/branches{/branch}",
            "clone_url": "https://github.com/kyverno/kyverno.git",
            "collaborators_url": "https://api.github.com/repos/kyverno/kyverno/collaborators{/collaborator}",
            "comments_url": "https://api.github.com/repos/kyverno/kyverno/comments{/number}",
            "commits_url": "https://api.github.com/repos/kyverno/kyverno/commits{/sha}",
            "compare_url": "https://api.github.com/repos/kyverno/kyverno/compare/{base}...{head}",
            "contents_url": "https://api.github.com/repos/kyverno/kyverno/contents/{+path}",
            "contributors_url": "https://api.github.com/repos/kyverno/kyverno/contributors",
            "created_at": 1549297548,
            "default_branch": "main",
            "deployments_url": "https://api.github.com/repos/kyverno/kyverno/deployments",
            "description": "Kubernetes Native Policy Management",
            "disabled": false,
            "downloads_url": "https://api.github.com/repos/kyverno/kyverno/downloads",
            "events_url": "https://api.github.com/repos/kyverno/kyverno/events",
            "fork": false,
            "forks": 479,
            "forks_count": 479,
            "forks_url": "https://api.github.com/repos/kyverno/kyverno/forks",
            "full_name": "kyverno/kyverno",
            "git_commits_url": "https://api.github.com/repos/kyverno/kyverno/git/commits{/sha}",
            "git_refs_url": "https://api.github.com/repos/kyverno/kyverno/git/refs{/sha}",
            "git_tags_url": "https://api.github.com/repos/kyverno/kyverno/git/tags{/sha}",
            "git_url": "git://github.com/kyverno/kyverno.git",
            "has_discussions": true,
            "has_downloads": true,
            "has_issues": true,
            "has_pages": true,
            "has_projects": true,
            "has_wiki": true,
            "homepage": "https://kyverno.io",
            "hooks_url": "https://api.github.com/repos/kyverno/kyverno/hooks",
            "html_url": "https://github.com/kyverno/kyverno",
            "id": 169108858,
            "is_template": false,
            "issue_comment_url": "https://api.github.com/repos/kyverno/kyverno/issues/comments{/number}",
            "issue_events_url": "https://api.github.com/repos/kyverno/kyverno/issues/events{/number}",
            "issues_url": "https://api.github.com/repos/kyverno/kyverno/issues{/number}",
            "keys_url": "https://api.github.com/repos/kyverno/kyverno/keys{/key_id}",
            "labels_url": "https://api.github.com/repos/kyverno/kyverno/labels{/name}",
            "language": "Go",
            "languages_url": "https://api.github.com/repos/kyverno/kyverno/languages",
            "license": {
              "key": "apache-2.0",
              "name": "Apache License 2.0",
              "node_id": "MDc6TGljZW5zZTI=",
              "spdx_id": "Apache-2.0",
              "url": "https://api.github.com/licenses/apache-2.0"
            },
            "master_branch": "main",
            "merges_url": "https://api.github.com/repos/kyverno/kyverno/merges",
            "milestones_url": "https://api.github.com/repos/kyverno/kyverno/milestones{/number}",
            "mirror_url": null,
            "name": "kyverno",
            "node_id": "MDEwOlJlcG9zaXRvcnkxNjkxMDg4NTg=",
            "notifications_url": "https://api.github.com/repos/kyverno/kyverno/notifications{?since,all,participating}",
            "open_issues": 296,
            "open_issues_count": 296,
            "organization": "kyverno",
            "owner": {
              "avatar_url": "https://avatars.githubusercontent.com/u/68448710?v=4",
              "email": "kyverno@googlegroups.com",
              "events_url": "https://api.github.com/users/kyverno/events{/privacy}",
              "followers_url": "https://api.github.com/users/kyverno/followers",
              "following_url": "https://api.github.com/users/kyverno/following{/other_user}",
              "gists_url": "https://api.github.com/users/kyverno/gists{/gist_id}",
              "gravatar_id": "",
              "html_url": "https://github.com/kyverno",
              "id": 68448710,
              "login": "kyverno",
              "name": "kyverno",
              "node_id": "MDEyOk9yZ2FuaXphdGlvbjY4NDQ4NzEw",
              "organizations_url": "https://api.github.com/users/kyverno/orgs",
              "received_events_url": "https://api.github.com/users/kyverno/received_events",
              "repos_url": "https://api.github.com/users/kyverno/repos",
              "site_admin": false,
              "starred_url": "https://api.github.com/users/kyverno/starred{/owner}{/repo}",
              "subscriptions_url": "https://api.github.com/users/kyverno/subscriptions",
              "type": "Organization",
              "url": "https://api.github.com/users/kyverno"
            },
            "private": false,
            "pulls_url": "https://api.github.com/repos/kyverno/kyverno/pulls{/number}",
            "pushed_at": 1673351226,
            "releases_url": "https://api.github.com/repos/kyverno/kyverno/releases{/id}",
            "size": 75072,
            "ssh_url": "git@github.com:kyverno/kyverno.git",
            "stargazers": 3340,
            "stargazers_count": 3340,
            "stargazers_url": "https://api.github.com/repos/kyverno/kyverno/stargazers",
            "statuses_url": "https://api.github.com/repos/kyverno/kyverno/statuses/{sha}",
            "subscribers_url": "https://api.github.com/repos/kyverno/kyverno/subscribers",
            "subscription_url": "https://api.github.com/repos/kyverno/kyverno/subscription",
            "svn_url": "https://github.com/kyverno/kyverno",
            "tags_url": "https://api.github.com/repos/kyverno/kyverno/tags",
            "teams_url": "https://api.github.com/repos/kyverno/kyverno/teams",
            "topics": ["kubernetes", "policy-management"],
            "trees_url": "https://api.github.com/repos/kyverno/kyverno/git/trees{/sha}",
            "updated_at": "2023-01-10T06:16:33Z",
            "url": "https://github.com/kyverno/kyverno",
            "visibility": "public",
            "watchers": 3340,
            "watchers_count": 3340,
            "web_commit_signoff_required": true
          },
          "sender": {
            "avatar_url": "https://avatars.githubusercontent.com/u/25727662?v=4",
            "events_url": "https://api.github.com/users/realshuting/events{/privacy}",
            "followers_url": "https://api.github.com/users/realshuting/followers",
            "following_url": "https://api.github.com/users/realshuting/following{/other_user}",
            "gists_url": "https://api.github.com/users/realshuting/gists{/gist_id}",
            "gravatar_id": "",
            "html_url": "https://github.com/realshuting",
            "id": 25727662,
            "login": "realshuting",
            "node_id": "MDQ6VXNlcjI1NzI3NjYy",
            "organizations_url": "https://api.github.com/users/realshuting/orgs",
            "received_events_url": "https://api.github.com/users/realshuting/received_events",
            "repos_url": "https://api.github.com/users/realshuting/repos",
            "site_admin": false,
            "starred_url": "https://api.github.com/users/realshuting/starred{/owner}{/repo}",
            "subscriptions_url": "https://api.github.com/users/realshuting/subscriptions",
            "type": "User",
            "url": "https://api.github.com/users/realshuting"
          }
        },
        "github_head_ref": "",
        "github_ref": "refs/tags/v1.9.0-beta.2",
        "github_ref_type": "tag",
        "github_repository_id": "169108858",
        "github_repository_owner": "kyverno",
        "github_repository_owner_id": "68448710",
        "github_run_attempt": "1",
        "github_run_id": "3883016519",
        "github_run_number": "232",
        "github_sha1": "ab368ebc080535448aa08fafdff82a4d4c69e127"
      }
    },
    "metadata": {
      "buildInvocationID": "3883016519-1",
      "completeness": {
        "parameters": true,
        "environment": false,
        "materials": false
      },
      "reproducible": false
    },
    "materials": [
      {
        "uri": "git+https://github.com/kyverno/kyverno@refs/tags/v1.9.0-beta.2",
        "digest": {
          "sha1": "ab368ebc080535448aa08fafdff82a4d4c69e127"
        }
      }
    ]
  }
}
```

## Summary

The SLSA project is providing huge gains in assuring the integrity of the software supply chain.
