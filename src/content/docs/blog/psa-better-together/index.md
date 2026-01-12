---
date: 2023-06-12
title: Using Kyverno with Pod Security Admission
slug: blog/using-kyverno-with-pod-security-admission
tags:
  - General
excerpt: Using Pod Security Admission with Kyverno for the best of both worlds.
draft: false
---

[Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) (PSA) is the built-in successor to Kubernetes [PodSecurityPolicy](https://kubernetes.io/docs/concepts/security/pod-security-policy/) (PSP) and is enabled by default starting in v1.23, graduating to stable in v1.25, the same version where PSP was finally removed. PSA is different from PSP in [many respects](/blog/psp-migration/index#comparison), however one of the most important--and central to how PSA operates--is that it is focuses on implementing **standards** and not individual checks like PSP did. The standards in this case are the [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). While many might see technologies like Kyverno and other admission controllers in competition PSA, the two can actually be highly complementary and deliver increased value through tighter security guarantees while catering to the flexibility demanded by modern Kubernetes operations. In this blog, we'll explain some of these use cases for how Kyverno can be used alongside PSA to get the best of both worlds.

## Introduction

First, let's explain a bit about how PSA can be used for those not familiar. Although this won't be a full tutorial on how to use the technology, it'll at least establish a good set of boundaries to help you know where it begins and ends.

PSA can basically be used in two ways: at the cluster level and at the Namespace level. Although it is "on" by default, it isn't "active" by default. Since PSA does not require an API resource similar to how PSP worked, it is "activated" in different ways. To activate PSA at the cluster level, one must create and install a specific file local to the control plane of the kind `AdmissionConfiguration` the contents of which will dictate how it works. Many Kubernetes PaaS providers have already done the work at the cluster level for you and, in many cases, there's nothing you can configure yourself. For example, in cases like EKS, PSA is enabled at the cluster level but set to the privileged mode which allows insecure Pod configurations. To activate PSA at the Namespace level, one need only label a Namespace. The two methods aren't mutually exclusive. In the case of the Namespace method, using PSA is extremely quick and simple.

Now on to the important point about profiles mentioned at the outset. PSA is the technology which implements the Pod Security Standards (PSS). Those standards are broken up into three **profiles**: [privileged](https://kubernetes.io/docs/concepts/security/pod-security-standards/#privileged), which is effectively the lack of any security, [baseline](https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline), and [restricted](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted). Each profile is a collection of different **controls**. Each control establishes which fields of a Pod's spec should or should not be set and with what value(s). The restricted profile is cumulative of the baseline profile, so by enabling restricted you implicitly get baseline.

Regardless of how PSA is activated and at what scope, it implements these profiles. Critical to understand is that **this is an all-or-nothing proposition**: a profile is implemented in its entirety and there is no possibility to cherry pick which controls in the profile are checked. Although each profile can be checked in either `audit`, `warn`, or `enforce` mode (even multiple modes simultaneously), you either get all of that profile or you get none of it.

Lastly, there is the matter of exclusions. It is extremely common for users to need the ability to tactically exclude certain Pods from the scope of policy because of some special needs they have. PSA allows exclusions via exemptions but only when PSA is activated cluster wide. The exemptions available are `usernames`, `runtimeClasses` and `namespaces`. All exemptions must be specified in the `AdmissionConfiguration` file mentioned earlier.

With some of the mechanics of PSA out of the way, let's get into the use cases for PSA and Kyverno.

## Use Cases

Although there are many possible points of intersection between PSA and Kyverno, here are four we've identified and commonly see employed. For some, there can be many different variations which we won't all cover.

### Use Kyverno to require PSA Namespace labels

As mentioned in the beginning, one of PSA's methods of operation is through assignment of labels to Namespaces. Without at least one PSA-specific label, nothing will happen. Kyverno can assist in this process in a couple ways:

1. Validate that labels are assigned where and how they need to be
2. Automatically assign the labels based upon your criteria

On the first, Kyverno can ensure that every Namespace has _some_ PSA label attached to it helping to prevent either typos or just forgetfulness. What that/those label(s) is/are and with what values is entirely up to you, but it is all driven by policy-as-code (PaC). This is, indeed, convenient, but it can be a more serious issue when you have PSA activated at, for example, the baseline profile across the cluster. Should a user be able to assign the Namespace label `pod-security.kubernetes.io/enforce: privileged` in these cases, it will effectively deactivate PSA on that Namespace. That's obviously not good and could compromise the security of that Namespace. But since Kubernetes RBAC doesn't allow for such granular permissions, you can outsource that job to Kyverno to ensure this act cannot be performed.

On the second, Kyverno can actually assign (i.e., mutate) the desired PSA labels for you based upon whatever criteria you establish and define in a policy. Even if you've done so in git, Kyverno can double-check your work and assign them if not present. For example, you might want to assign the `pod-security.kubernetes.io/enforce: baseline` label to all Namespaces by default but assign `pod-security.kubernetes.io/enforce: restricted` to those which begin with the name `pci-` or have another label called `env: prod`. Kyverno's [mutation](/docs/policy-types/cluster-policy/mutate) ability gives you very flexible definitions which can make these things happen.

These policies have already been written and are provided to you [here](/policies/?policytypes=Pod%2520Security%2520Admission).

### Use PSA and Kyverno both to enforce

In this use case, which is the most common, you use both PSA and Kyverno combined to provide comprehensive protection for your cluster where each does something different. Due to the limited nature of exclusions, we often find that PSA is used right up until the point that its flexibility can go no further. The most common examples are with some monitoring/observability tools and service meshes. These types of tools often have Pods that need to run with privileges not afforded by sometimes even the baseline profile. Rather than deactivate Pod security in those Namespaces--which for many is a non-starter--Kyverno can be used because of its great flexibility.

Kyverno has the ability to exclude a Pod based on just about any combination you can think up. Whether it's Pod name, image, user, label, or what have you, Kyverno can exempt it from controls.

When it comes to how Kyverno enforces, there are generally two options. First, Kyverno [publishes and maintains](/policies/pod-security/) the complete Pod Security Standards as individual policies (one per control). These are also conveniently packaged into their own Helm chart for easy installation. Second, Kyverno directly integrates the PSA libraries into the engine and exposes a simplified rule type we call a validate "subrule" known as [podSecurity](/docs/policy-types/cluster-policy/validate#pod-security). This rule type, powered under the hood by PSA, allows a consolidated, simplified way to enforce the Pod Security Standards. But in addition, it also allows more capabilities not found in PSA. For example, using this podSecurity subrule, it is possible to exempt specific controls by name and even specific images in addition to the [standard exclusions](/docs/policy-types/cluster-policy/match-exclude) provided by all Kyverno rule types. This is incredibly powerful yet easy to use.

For example, below is a Kyverno policy which applies to Pods in all Namespaces beginning with the prefix `prod-` and enforces the restricted profile except for the Seccomp check and specifically on containers which use the `cadvisor` image.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa
spec:
  background: true
  validationFailureAction: Enforce
  rules:
    - name: restricted
      match:
        any:
          - resources:
              kinds:
                - Pod
              namespaces:
                - prod-*
      validate:
        podSecurity:
          level: restricted
          version: latest
          exclude:
            - controlName: Seccomp
            - controlName: Seccomp
              images:
                - cadvisor*
```

This is just one example and there are many variations for how these two technologies can be used simultaneously, each to enforce some aspect of Pod security on your cluster. For more information as well as a list of those variations, see the [documentation](/docs/policy-types/cluster-policy/validate#psa-interoperability). In addition to the documentation, there are pre-built samples ready to go [here](/policies/?policytypes=Pod%2520Security).

And, by the way, one more benefit you get when using Kyverno to enforce its Pod Security Standards over PSA is that it allows you to block Pod controllers directly as a result of its [rule auto-generation](/docs/policy-types/cluster-policy/autogen) capability. This is not something PSA allows and only non-compliant Pods will be blocked.

### Use Kyverno reporting for PSA

PSA allows for assigning multiple labels to a Namespace (or configuring the same via the `AdmissionConfiguration` file) to get a union of the behaviors. For example, PSA can `enforce` at the baseline profile and `audit` and/or `warn` at the restricted profile. The audit mode means any violations will be allowed yet will be written in the Kubernetes audit log. There are a few down sides with this approach. The audit log is not accessible from inside the cluster because it's not a native Kubernetes resource, it's literally a log file written to the control plane or, optionally, sent to an external server. Audit logs also commonly cannot be enabled retroactively or to do so is cumbersome and disruptive. In the case of some cloud PaaS offerings, if audit logging wasn't enabled at the time the cluster was created then it can't be subsequently enabled, potentially forcing you to build another cluster just to gain these insights.

This is yet another opportunity where Kyverno can step in and help. In cases where PSA is not enforcing at the most restrictive level, Kyverno can be layered in to generate its Policy Reports. A [Policy Report](/docs/policy-reports) is an in-cluster, Kubernetes-native resource which is an open standard developed by the upstream [Kubernetes policy working group](https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report) and adopted by many other tools. Policy reports give you a leg up over audit logs because they empower self-service and compliment multi-tenant approaches. Since they're just another Kubernetes resource, RBAC can be wrapped around them allowing, for example, developers to see violations in their own Namespaces so they know what they're responsible for addressing. They can also help you as a cluster admin or operator know which resources in the cluster are non-compliant at any point in time since Policy Reports are not historical and always reflect the current cluster state.

It's important to understand, however, that Kyverno's Policy Reporting feature will only work on Pods which have _not_ been blocked by PSA. But, provided that is true, the process to enable and begin viewing Policy Reports is simple: load any Kyverno policy, for example the [restricted profile of the PSS](/policies/pod-security/subrule/restricted/restricted-latest/restricted-latest), in `audit` mode with the flag `background: true`. The `audit` mode means Kyverno will not block any Pods, and the `true` setting on the `background` field means it will periodically scan the cluster to compare existing resources against the policy giving you an extra layer of comfort that nothing got missed. Policy Reports will then be created in each Namespace where Pods are located.

Reporting isn't just restricted to Pods either but can be used to check for those Namespace labels we discussed earlier. For example, you may want to know which Namespaces have no PSA labels whatsoever which could key you in to someone or something doing things it perhaps shouldn't. By introducing the below policy, Kyverno will generate and maintain and a Cluster Policy Report in the `default` Namespace with the result of these continual checks. The results can be conveniently viewed by cluster admins or scraped and alerted on by other tools such as the [Policy Reporter](https://kyverno.github.io/policy-reporter-docs/) and more.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa-reporting
spec:
  validationFailureAction: audit
  background: true
  rules:
    - name: check-namespace-labels
      match:
        any:
          - resources:
              kinds:
                - Namespace
      validate:
        message: This Namespace is missing a PSA label.
        pattern:
          metadata:
            labels:
              pod-security.kubernetes.io/*: '?*'
```

### Use Kyverno CLI in pipelines to test against PSS profiles

If none of the above use cases piqued your interests or you are unwilling to install anything additional in your cluster, there is **still** an opportunity for Kyverno to provide value. Kyverno comes with a CLI which can be used in CI pipelines to check resource manifests against those Pod Security Standards enforced by PSA. But since PSA itself is in-line to the Kubernetes API with no external tooling, it takes standing up a full, running cluster to perform the same checks otherwise. As we mentioned earlier, Kyverno integrates the PSA libraries directly into its engine. And since the CLI is really just a different form factor of the same Kyverno engine, you get the same benefits of Kyverno outside the cluster as in.

Take one of the earlier policies we've pointed out along the way and see a sample GitHub Action workflow we publish in the [documentation](/docs/testing-policies#github-actions) and you're up and running. The `kyverno apply` command will naturally exit with an error code if the resource(s) do not pass. The CLI combined with Kyverno's rule auto-generation capability mentioned earlier means you can be informed of those Deployments, StatefulSets, and others before they need to touch a cluster.

Below you can see the result of the Kyverno CLI comparing a standard Deployment with no security settings defined to the restricted profile of the PSS showed previously. As you can see, the Deployment failed the checks and a message is printed with exactly which controls failed and what must be done to address them.

```sh
$ kubectl-kyverno apply restricted.yaml -r deploy.yaml

Applying 1 policy rule to 1 resource...

policy psa -> resource default/Deployment/busybox failed:
1. autogen-restricted: Validation rule 'autogen-restricted' failed. It violates PodSecurity "restricted:latest":
({Allowed:false ForbiddenReason:allowPrivilegeEscalation != false ForbiddenDetail:container "busybox" must set securityContext.allowPrivilegeEscalation=false})
({Allowed:false ForbiddenReason:unrestricted capabilities ForbiddenDetail:container "busybox" must set securityContext.capabilities.drop=["ALL"]})
({Allowed:false ForbiddenReason:runAsNonRoot != true ForbiddenDetail:pod or container "busybox" must set securityContext.runAsNonRoot=true})
({Allowed:false ForbiddenReason:seccompProfile ForbiddenDetail:pod or container "busybox" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost"})

pass: 0, fail: 1, warn: 0, error: 0, skip: 2
```

## Closing

Pod Security Admission is a major improvement over PodSecurityPolicy and couldn't be simpler to activate and begin using in your clusters. If you have no Pod security today, we absolutely recommend you plug that gap and starting with PSA can be a great way. As we hope we've made clear, there are many places where PSA and Kyverno can be used together and it doesn't have to be an either or decision. Use PSA where it makes sense and provides the necessary level of coverage, and use Kyverno to pick up the slack.
