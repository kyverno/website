---
title: "Testing Policies"
linkTitle: "Testing Policies"
weight: 55
description: >
    Test Kyverno policies for effectiveness.
---

The [Kyverno CLI `test` command](/docs/kyverno-cli/#test) can be used to test if a policy is behaving as expected.

Please refer to the [`test` command documentation](/docs/kyverno-cli/#test) for details. You can also find examples in the [sample policies repo](https://github.com/kyverno/policies).

## Continuous Integration

By using the Kyverno CLI, it is possible to test Kyverno policies in a Continuous Integration (CI) pipeline. There are two primary use cases for such CI integration.

The first use case is that Kubernetes resources, defined in YAML files, can be tested against a set of Kyverno policies to determine their result prior to being applied to a live cluster. This is useful when the policies against which resources should be tested are known yet the resources are not. For example, developer teams are responsible for creating their own manifests and pushing to a git repository from which they will be deployed to a running Kubernetes environment. Tests can be executed on, for example, a [pull request](https://www.pagerduty.com/resources/learn/what-is-a-pull-request/) by applying policies against the resources contained in the pull request and viewing the results. For validate rules, any failing tests may indicate that the resource would fail if it were allowed into the cluster. A failure in any tests would cause a failure in the overall pipeline, and by surfacing these failures early rather than later, users may make changes earlier in the delivery process.

The second use case is when ensuring a set of policies and resources always produce a predefined set of outcomes. This is useful when testing strategic modifications to either policies and/or resources, or when testing future versions of Kyverno prior to upgrading a cluster. For example, operations teams may want to ensure that a standard set of platform services are always allowed to be created in a cluster by defining a Kyverno test manifest which declares they should pass. Those services, represented in YAML manifest form, may be strategically changed when, for example, a new image version is available. By executing the same tests, expected results may be compared to actual results. If there are discrepancies, the tests fail and operations teams will know which test failed and can resolve the issue prior to changes made in a cluster.

### GitHub Actions

[GitHub Actions](https://github.com/features/actions) provides a comprehensive CI system for repositories hosted on GitHub. Tests for Kyverno policies may be executed via a workflow as part of the CI process.

The following is an example of a simple GitHub Actions workflow which may be used as part of building a larger CI pipeline. Consider a repository with the following structure.

```
.
├── .github
│   └── workflows
│       └── kyverno.yaml
├── README.md
├── policies
│   ├── disallow-privilege-escalation.yaml
│   └── disallow-privileged-containers.yaml
├── resources
│   ├── configmap.yaml
│   └── deployment.yaml
└── tests
    ├── require_labels
    │   ├── kyverno-test.yaml
    │   ├── require_labels.yaml
    │   └── resource.yaml
    └── restrict_image_registries
        ├── kyverno-test.yaml
        ├── resource.yaml
        └── restrict_image_registries.yaml
```

The repository contains Kyverno policies stored in `policies/`, Kubernetes resource manifests stored in `resources/` and complete Kyverno test cases stored in `tests/`. A sample workflow may be added at the path `.github/workflows/kyverno.yaml` with the below contents which performs the following for both opened pull requests and manually if triggered on the repository.

1. The repository is checked out.
2. The GitHub action for Kyverno CLI is downloaded by naming a specific version. This can be changed to simulate the effect a Kyverno upgrade may have in a cluster. Please refer to [kyverno-cli-installer](https://github.com/marketplace/actions/kyverno-cli-installer) for more information on the GitHub action for Kyverno CLI.
3. Check the Kyverno CLI version
4. Tests the unknown manifests in `resources/` against the known policies stored in `policies/`.
5. Tests the pre-defined test cases stored in `tests/` which contain Kyverno test manifests, policies, and resources separated by folder.

```yaml
name: kyverno-policy-test
on:
  - pull_request
  - workflow_dispatch
jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Checkout repo
        uses: actions/checkout@v4
      - name: Install Kyverno CLI
        uses: kyverno/action-install-cli@v0.2.0
        with:
          release: 'v1.11.0'
      - name: Check install
        run: kyverno version
      - name: Test new resources against existing policies
        run: kyverno apply policies/ -r resources/
      - name: Test pre-defined cases
        run: kyverno test tests/
```

Upon pull request to the repository containing this file, the GitHub Actions workflow will be triggered. If all tests succeed, the output will show a success for all steps.

![ci-pass](/images/ci-pass.png)

Each step may be expanded for complete output.

If a pull request fails in any of the steps in the job, for example if a new manifest is introduced into `resources/` which fails one or more policies defined in `policies/`, the pipeline will halt causing the entire run to fail.

![ci-fail](/images/ci-fail.png)

Again, each step may be inspected for output. In the above screenshot, a Deployment manifest did not pass a validate policy and therefore caused the overall failure.

For full usage details of the Kyverno CLI, refer to the [documentation](/docs/kyverno-cli/).