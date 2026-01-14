---
date: 2023-05-30
title: Kyverno 1.10 Released
slug: kyverno-1.10-released
tags:
  - Releases
excerpt: Kyverno 1.10 released with featuring separate controllers, external service calls, Notary support, and tons more!
draft: false
---

![kyverno](kyverno-horizontal.png)

The Kyverno team are proud to announce the release of Kyverno 1.10, a minor release in terms of version number but a major release in every other regard. With around four months in the making and after four pre-releases and nearly 500 pull requests merged, Kyverno 1.10 is one of the largest releases in the history of the project and features a ton of new and highly-requested features and a staggering number of fixes and improvements. It also brings with it some breaking changes so please read thoroughly. We can't wait for you to see what's inside so let's get started!

## Key New Features of Kyverno 1.10

Kyverno 1.10 contains several new and significant features including decomposing Kyverno into smaller pieces, external service calls, Notary support, and a major revamp of generate rules.

### Increased Scalability with Service Decomposition

In previous versions of Kyverno, everything except the cleanup controller (introduced in 1.9) was packaged in a single container. This made sense in the early days, but as Kyverno began to grow in capability and complexity, the single-deployment model just wasn't going to cut it. Users also wanted a way to only install what they needed and not get everything else that came along with it. Beginning in Kyverno 1.10, the major capabilities of Kyverno have been broken out into separate deployments allowing you to switch on or off the ones you want. What this looks like is shown below.

![kyverno](kyverno-installation.png)

The four major components of Kyverno and their primary functions are as follows:

- **Admission Controller**: The heart of Kyverno, the Admission Controller receives and processes webhook requests from the Kubernetes API server and is responsible for validate, mutate, and verifyImages rules along with Policy Exceptions. It also performs most of the validations on policies themselves. This is the only required component of Kyverno which must be installed.
- **Reports Controller**: Responsible for processing of Kyverno's Policy Reports including performing background reporting scans.
- **Background Controller**: Not to be confused with background scans, the Background Controller handles all the generate rules and mutate rules when they impact existing resources (which all happen in the background).
- **Cleanup Controller**: Takes care of all the cleanup tasks according to cleanup policies.

Because Kyverno is now decomposed into separate controllers, each controller can be scaled independently although they all don't necessarily handle it differently. We recommend reading the [High Availability page](/docs/guides/high-availability) for more details on the internals of these controllers and how scale and availability are handled per controller.

### Extensibility via External Service Calls

Kyverno is already able to gather data from external sources as a factor in its policy-making decisions, for example from the Kubernetes API, OCI image registries, and ConfigMaps. However, one of the most requested features has been the ability for it to make calls to services other than the Kubernetes API server for the same reasons. We're happy to say that as of Kyverno 1.10, this feature now exists! It is new and a bit limited at this point so we can get an understanding of how folks intend to use it, but it allows performing GET and POST requests against another service in the cluster along with specifying a certificate authority bundle for establishing trust against HTTPS servers. A sample of what this looks like is shown below.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-namespaces
spec:
  validationFailureAction: Enforce
  rules:
    - name: call-extension
      match:
        any:
          - resources:
              kinds:
                - ConfigMap
      context:
        - name: result
          apiCall:
            method: POST
            data:
              - key: somekey
                value: '{{ somevariable }}'
            service:
              url: http://sample.myservice/someendpoint
              caBundle: |-
                -----BEGIN CERTIFICATE-----
                <snip>
                -----END CERTIFICATE-----
      validate:
        message: 'This shall not pass due to item {{ fookey}}'
        deny:
          conditions:
            all:
              - key: '{{ result.allowed }}'
                operator: Equals
                value: false
```

And, by the way, in addition to POST calls to external services, we've also enhanced the existing `apiCall` context variable to be able to POST to the Kubernetes API making it possible to [do things like](/policies/other/check-subjectaccessreview/check-subjectaccessreview/) pass a [SubjectAccessReview](https://kubernetes.io/docs/reference/kubernetes-api/authorization-resources/subject-access-review-v1/) which will make permissions assessments much easier.

### Software Supply Chain Security with CNCF Notary

The [Notary project](https://notaryproject.dev/) is another project, like Sigstore, aiming to solve software supply chain security through OCI image signing. Notary is currently in its second version and differentiates itself from Sigstore by using OCI artifacts to store image signatures. Although Kyverno has had support for verifying signatures and attestations from Sigstore's Cosign project for a while now, we wanted to add support for Notary so that no matter what technology you use to sign your images, Kyverno will be there for you.

Starting in Kyverno 1.10, we've added a new `type` field to verifyImages rules allowing you to specify the signatory used, either `Notary` or `Cosign`. An example of what this looks like is shown below.

```yaml
apiVersion: kyverno.io/v2beta1
kind: ClusterPolicy
metadata:
  name: check-image-notary
spec:
  validationFailureAction: Enforce
  webhookTimeoutSeconds: 30
  failurePolicy: Fail
  rules:
    - name: verify-signature-notary
      match:
        any:
          - resources:
              kinds:
                - Pod
      verifyImages:
        - type: Notary
          imageReferences:
            - 'mytest.azurecr.io/user/net-monitor:v1'
          attestors:
            - count: 1
              entries:
                - certificates:
                    cert: |-
                      -----BEGIN CERTIFICATE-----
                      <snip>
                      -----END CERTIFICATE-----
```

While this addition supports simple Notary verification, if needing to call an external service when using an extension, the external service call feature as shown earlier can be used.

### Generate Rule Refactoring

Even though generate rules have been a cornerstone of Kyverno for a while now, we did a significant overhaul on them to add new functionality, fix issues, improve the user experience, and just in general give it a major face lift. Specifically, one of the new features in generate rules which has been a frequent request is to allow the triggering resource to share the same synchronize life cycle as the generated resource. Users told us they want to be able to remove or change a trigger while sync is on and have that influence the resource that trigger was responsible for generating. This is now a reality in Kyverno 1.10 and will help in multitenancy use cases where generate rules are so frequently employed.

We didn't stop there, though, we also added new features like triggering on DELETE requests, triggering on subresources, and performing permissions checks up front when the generate rule is created, helping to avoid failures down the line in case you forgot to add them. These features and many more can be found inside Kyverno 1.10 when using generate rules. We also had to make some tough decisions that lead to a couple breaking changes, so please read the release notes carefully if you're a user of generate rules. And although we'll talk about upgrades below, we strongly suggest removing and then reintroducing them in your cluster (or at least in a test cluster somewhere) to allow Kyverno to validate the new restrictions put into effect in 1.10.

## Other Additions and Enhancements

There are loads of other additions and enhancements to be found in Kyverno 1.10 and we simply can't cover them all, but here are the most notable ones.

Operations can now be specified directly in `match` and `exclude` blocks obviating the need for preconditions. This enhancement can simplify your rules by moving that condition to match on `CREATE`, for example, up into the `match` block. Specifying operations like this is also a requirement if you want to generate something based upon a `DELETE` operation.

```yaml
match:
  any:
    - resources:
        kinds:
          - Service
        operations:
          - CREATE
```

Policy Exceptions have been enhanced in 1.10 to add support for background scanning, useful when you consume a Policy Report and want to see that fail result to go away, and wildcards in the `ruleNames[]` field. The latter will assist when you might have several rules in a policy which begin with the same prefix.

A number of significant enhancements were made to Policy Reports in Kyverno 1.10 which dramatically improve performance, reduce time to aggregate reports, and lower resource consumption. Another enhancement some users may rejoice in hearing is that background scans will now, by default (but configurable, of course) consider Kyverno's resource filters when producing reports. So if you've excluded a Namespace in the [resource filter](/docs/installation/customization#resource-filters), by default you won't see any reports for it either when coming from background scans.

Context variables are now lazily evaluated (JIT) which means no more failed rules when preconditions don't pass. Variables are often used in conditions and so they will follow the same circuit-breaking mechanisms already in place for those conditions. This should also have the benefit of reducing API calls in rules where they may not always be needed.

Speaking of conditions, there's now a new `message` field that's available for use in conditions everywhere they're used throughout Kyverno which will allow you to append the contents of that field in the message response returned by Kyverno. This is especially handy in verifyImages rules where the reason why an attestation verification failed can be narrowed down to the exact condition. And if there are multiple, they'll be appended to each other. Very handy indeed.

Kyverno 1.10 has three new JMESPath filters, `image_normalize()`, `trim_prefix()`, and `to_boolean()` in addition to some enhancements to existing filters. A couple of those enhancements to call out are the `sum()` filter can now sum quantities like memory making it valuable for adding up all the memory requests in a Pod to figure out whether it should be allowed or not. And the `x509_decode()` filter now supports decoding of Certificate Signing Requests so you can apply additional security checks if you use that API.

Lastly, the documentation and policy library were greatly refreshed and improved as of this release. Not just that, but all Kyverno policies in the library can now be found on [Artifact Hub](https://artifacthub.io/packages/search?kind=15&sort=relevance&page=1) making Kyverno policies presently the fourth largest artifact type.

## Potentially Breaking Changes

As we hope you've seen, Kyverno 1.10 has some truly amazing features and enhancements in store for you, but making all this happen plus the hundreds of fixes we didn't cover here meant we had to make some important decisions. We'd like to make you aware of these breaking changes up front so there are no surprises.

First, due to the decomposition efforts, the Kyverno Helm chart had to basically be rewritten. This is reflected in a major version number increment from 2 to 3. As such, there is no direct upgrade path when coming from v2 of the chart and attempts to do so will be blocked by default. We've written up a Helm upgrade and migration guide [here](https://github.com/kyverno/kyverno/blob/release-1.10/charts/kyverno/README.md#migrating-from-v2-to-v3) and we strongly recommend you give that a good read. Although we also publish a YAML manifest as part of each release, there again a direct upgrade is not supported. In short, we recommend a backup-uninstall-reinstall-restore method when approaching this release, but the write-up has more details.

For rules which matched on certain types of subresources like `PodExecOptions`, you'll need to move to the canonical format of them such as `Pod/exec`. A simple change to make, and Kyverno will let you know if you try to create it the other way.

And, finally, because of the number of issues we sorted regarding generate rules in this release, we had to put a few more guardrails in place to ensure the correct user experience was being met. Some fields now no longer support defining variables, some others may be immutable after rule creation, and a few fields will now be required whereas they previously were not. The latter we've tried to limit to situations in which policies are newly seen and not which pre-exist in the cluster.

For these breaking changes, and others, please carefully read the extensive and (yes, sorry) lengthy release notes [here](https://github.com/kyverno/kyverno/releases).

## Closing

Kyverno 1.10 is quite the loaded release as you can probably see. After about four months and close to 500 PRs, there were a tremendous number of changes from the Kyverno community. And if you were one of the many, many contributors who pitched in to make this release a reality, a hearty THANK YOU for all your work! Hopefully what you've seen makes you excited to try out 1.10 for yourself. Come engage with us in the Kyverno channel on [Kubernetes Slack](/community/#slack-channel), attend one of our [community meetings](/community/#meetings), or just catch us on [Twitter](https://twitter.com/kyverno).

And if you're already a Kyverno adopter, sign up to be an official adopter by updating the Adopters form [here](https://github.com/kyverno/kyverno/blob/main/ADOPTERS.md).
