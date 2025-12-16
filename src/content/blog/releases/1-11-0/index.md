---
date: 2023-11-16
title: Kyverno 1.11 Released
linkTitle: Kyverno 1.11
description: Kyverno 1.10 released with enhanced ValidatingAdmissionPolicy and Cleanup support, Cosign and Notary updates, and tons more!
draft: false
category: Releases
---

![kyverno](kyverno-horizontal.png)

The Kyverno team is delighted to share a new Kyverno release, v1.11! This release marks a significant milestone for Kyverno, with an extensive development period of around five months, including eight pre-releases and the merging of over 500 pull requests. We are incredibly proud of the progress made and cannot wait for you to explore the remarkable additions in Kyverno 1.11!

## Key New Features in Kyverno 1.11

### ValidatingAdmissionPolicy Support

In Kyverno 1.11, a new sub-rule `validate.cel` was introduced. This sub-rule type allows users to use [Common Expression Language](https://github.com/google/cel-spec) (CEL) expressions for resource validation. CEL was initially introduced in Kubernetes for the validation rules of CustomResourceDefinitions and is now also utilized by Kubernetes [ValidatingAdmissionPolicies](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/).

For example, this policy ensures that deployment replicas are less than 4.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-deployment-replicas
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: check-deployment-replicas
      match:
        any:
          - resources:
              kinds:
                - Deployment
      validate:
        cel:
          expressions:
            - expression: 'object.spec.replicas < 4'
              message: 'Deployment spec.replicas must be less than 4.'
```

It is possible to generate Kubernetes ValidatingAdmissionPolicies and their bindings from the Kyverno policy mentioned above. With this feature, Kyverno now offers complete policy management for Kubernetes ValidatingAdmissionPolicies. This includes the ability to apply ValidatingAdmissionPolicies to resources using the command-line interface (CLI) and to obtain PolicyReports for them.

### Policy Report Enhancements

In previous versions of Kyverno, PolicyReports were generated and grouped per namespace per policy. The AdmissionReports and BackgroundScanReports were retained in the cluster for remediation purposes. However, this posed a challenge for large clusters as it led to resource overload in etcd.

With the introduction of Kyverno 1.11, a PolicyReport is now created for each individual resource and will be automatically removed if the corresponding resource is deleted. To avoid repetition in every result, the scope field in the report is utilized to indicate resource metadata. Additionally, AdmissionReports and BackgroundScanReports are now considered ephemeral resources and are cleaned up once they are aggregated into the final reports. Below is a snippet of a PolicyReport.

```yaml
apiVersion: wgpolicyk8s.io/v1alpha2
kind: PolicyReport
metadata:
 name: 0f8f65db-3bfa-4178-af8d-d66fc765b17e
 namespace: default
 ownerReferences:
 - apiVersion: v1
   kind: Service
   name: kubernetes
   uid: 0f8f65db-3bfa-4178-af8d-d66fc765b17e
results:
- category: Networking
 message: validation rule 'disallow-LoadBalancer' passed.
 policy: disallow-loadbalancer-service
 result: pass
 rule: disallow-LoadBalancer
 source: kyverno
...
scope:
 apiVersion: v1
 kind: Service
 name: kubernetes
 namespace: default
 uid: 0f8f65db-3bfa-4178-af8d-d66fc765b17e
summary:
 pass: 1
...
```

### Notary Updates

In Kyverno version 1.11, support for verifying OCI 1.1 attestations using Notary has been added. The following policy will verify the signature on the sbom/cyclone-dx attestation and check if the license version of all the components in the SBOM is GPL-3.0.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image-attestation
spec:
  validationFailureAction: Enforce
  webhookTimeoutSeconds: 30
  failurePolicy: Fail
  rules:
    - name: verify-attestation-notary
      match:
        any:
          - resources:
              kinds:
                - Pod
      context:
        - name: keys
          configMap:
            name: keys
            namespace: kyverno
      verifyImages:
        - type: Notary
          imageReferences:
            - 'ghcr.io/kyverno/test-verify-image*'
          attestations:
            - type: sbom/cyclone-dx
              attestors:
                - entries:
                    - certificates:
                        cert: |-
                          -----BEGIN CERTIFICATE-----
                          <snip>
                          -----END CERTIFICATE-----
              conditions:
                - all:
                    - key: '{{ components[].licenses[].expression }}'
                      operator: AllIn
                      value: ['GPL-3.0']
```

### Cosign 2.0 Support

Kyverno 1.11 also adds support for Cosign 2.0 and all the behavioral changes in Cosign 2.0 are supported in Kyverno. Tlogs and SCTs are now verified by default and can be turned off using `rekor.ignoreTlogs` and `ctlog.IgnoreSCT` attributes in a policy. Rekor public keys and ctlog public keys can now be specified in policies to verify Tlogs and SCT timestamps without setting up TUF for Sigstore or passing a Rekor URL.

Full support for private Sigstore deployments has also been added. Private Sigstore deployments can be used by passing the TUF root and mirror in the Kyverno deployment or Helm chart.

### Image Verification Cache

Image verification requires multiple network calls and can be time consuming. We have also added caching for image verification that will cache successful image verification outcomes. It is a TTL based cache and the size and TTL configuration can be configured in the deployment.

**Note:** Users upgrading from Kyverno v1.10 to v1.11 who have image verification policies using cosign will have to explicitly disable Tlogs and SCT verification in their policy using the `rekor.ignoreTlogs` and `ctlog.IgnoreSCT` fields if they did not use Rekor while signing the image.

### Cleanup via TTL label

The cleanup ability was introduced in Kyverno 1.9 via the cleanup type of policy. This release introduced another option to clean up resources via a reserved time-to-live (TTL) label `cleanup.kyverno.io/ttl`. By assigning this label to any resource with required permissions granted to Kyverno, the resource will be removed at the designated time. In this release, the cleanup policy no longer relies on CronJobs to perform the job.

For example, creation of this Pod will cause Kyverno to clean it up after two minutes and without the presence of a cleanup policy.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    cleanup.kyverno.io/ttl: 2m
  name: foo
spec:
  containers:
    - args:
        - sleep
        - 1d
      image: busybox:1.35
      name: foo
```

Because this is a label, there is opportunity to chain other Kyverno functionality around it. For example, it is possible to use a Kyverno mutate rule to assign this label to matching resources. A validate rule could be written prohibiting, for example, users from the `infra-ops` group from assigning the label to resources in certain Namespaces. Or, Kyverno could generate a new resource with this label as part of the resource definition.

### CLI Refactoring and New Test Schema

In Kyverno 1.11, we have made significant improvements to the CLI, enhancing its stability and usability. A new test manifest schema was introduced to the Kyverno `test` command, now you can validate your `kyverno-test.yaml` and get helpful error reports during execution. Here’s a snippet of a `kyverno-test.yaml` and an error is displayed as part of the execution result.

```yaml
apiVersion: cli.kyverno.io/v1alpha1
kind: Test
metadata:
  name: mytest
policies:
  - policy.yaml
resources:
  - pod.yaml
results:
  - policy: evil-policy-match-foreign-pods
    rule: evil-validation
    resource: nginx
    status: pass
```

```bash
$ kubectl-kyverno test ./scratch/cli
No test yamls available
Test errors:
   failed to load test file (json: cannot unmarshal array into Go value of type api.Test)
```

Moreover, we have added three new commands to the Kyverno CLI: `create`, `docs` and an experimental `fix`. The `create` command creates various resources that can be used for the Kyverno CLI, including `kyverno-test.yaml` and the values file that are used for the test command. With the `fix` command, you can now easily resolve any issues and ensure that your Kyverno resources are up-to-date and optimized. The `docs` command enables automatic generation of comprehensive documentation for the Kyverno CLI. It makes it a lot easier for users to access the information they need and stay up-to-date with all the CLI capabilities.

## Other Additions

As with previous minor releases, certain features have progressed to the next phase. The PolicyExceptions and Cleanup policies moved from alpha to beta status, and PolicyExceptions are enabled by default in 1.11.

The Kyverno CLI can now be installed via a [GitHub Action](https://github.com/kyverno/action-install-cli), which currently supports GitHub-provided Linux, macOS and Windows.

## Kyverno JSON

Although not part of 1.11.0, the Kyverno team launched a new sub-project Kyverno JSON, which extends Kyverno beyond Kubernetes. Now, platform engineering teams can use Kyverno’s declarative policies to validate any JSON payload including Terraform files, Dockerfiles, Cloud configurations and service authorization requests.

Kyverno JSON can be consumed as a CLI, a Golang API, or a web service with a REST API. Read more at: https://www.cncf.io/blog/2023/11/06/kyverno-expands-beyond-kubernetes/.

## Kyverno Chainsaw

Another sub-project launched was Kyverno Chainsaw, an end-to-end declarative test tool for Kubernetes controllers. Chainsaw emerged from a real need for testing Kyverno controllers and policy behaviors in continuous integration environments. You can learn more about it at: https://kyverno.github.io/chainsaw/.

## Security Hardening

In addition to the mentioned features, enhancements, and fixes, the Kyverno project completed a [fuzzing security audit](../../general/2023-security-audit/index.md) and is undergoing a thorough third-party security review. The security review is being conducted in collaboration with the [CNCF](https://www.cncf.io/), [Ada Logics](https://adalogics.com/) and [OSTIF](https://ostif.org/).

The review exposed a high severity vulnerability [CVE-2023-47630](https://nvd.nist.gov/vuln/detail/CVE-2023-47630) involving the possibility of users consuming insecure images pulled from a compromised registry. In addition four CVEs [CVE-2023-42813](https://nvd.nist.gov/vuln/detail/CVE-2023-42813), [CVE-2023-42814](https://nvd.nist.gov/vuln/detail/CVE-2023-42814), [CVE-2023-42815](https://nvd.nist.gov/vuln/detail/CVE-2023-42815), [CVE-2023-42816](https://nvd.nist.gov/vuln/detail/CVE-2023-42816) were identified in unreleased code (i.e. on the main branch), which could potentially allow an attacker to cause a denial of service of Kyverno by exploiting the Notary verifier.

## Closing

Kyverno 1.11 is here, and we want to express our heartfelt gratitude to all the contributors who made this release possible! This release is jam-packed with awesome new features and improvements that we can’t wait for you to try out. For a more complete list of all the features, changes, and fixes, please see the [release notes](https://github.com/kyverno/kyverno/releases/tag/v1.11.0) on GitHub.

Join our community on Kubernetes Slack, attend our community meetings, and connect with us on Twitter. Thank you for your support, and we can’t wait to see what amazing things you’ll achieve with Kyverno 1.11!
