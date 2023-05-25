---
date: 2023-05-24
title: PodSecurityPolicy migration with Kyverno
linkTitle: PodSecurityPolicy migration with Kyverno
description: Migrating from PodSecurityPolicy to Kyverno
draft: false
---

As you've probably heard or maybe observed at this point in time, [PodSecurityPolicy](https://kubernetes.io/docs/concepts/security/pod-security-policy/) (PSP) in Kubernetes is no more. After a deprecation beginning in v1.21, they were finally removed in v1.25. Many organizations out there are still relying on PSPs and, if you're reading this post, you're probably one of them. As you begin to upgrade your clusters closer and closer towards v1.25, the clock is ticking. The choices with which you are faced are to either delay cluster upgrades, which means you aren't keeping up with the frequent releases and risk being on an unmaintained version, or upgrade to v1.25 or later and simply not have security for Pods. Neither is really an acceptable choice. In this blog post, we'll show you what your options are and provide a step-by-step migration guide for getting off PSP and onto Kyverno so you can feel confident in your ability to upgrade safely.

## Background

PSP was a built-in admission controller to Kubernetes and existed right after v1.0 was released. Its removal in v1.25 meant it hung around for quite some time. Being the earliest form of Pod security for Kubernetes, it experienced some growing pains and began to feel the strain of more demanding use cases and users alike. That strain ultimately resulted in a decision to not promote it from a beta API, from which it was left, and to instead move towards its successor, [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/). That's the very, very short story, but for more details on the historical context of PSP and a retrospective, take a look at [this blog post](https://kubernetes.io/blog/2022/08/23/podsecuritypolicy-the-historical-context/) from the Kubernetes project. A previous blog did a good job of explaining the what and why of the deprecation and ultimately removal [here](https://kubernetes.io/blog/2021/04/06/podsecuritypolicy-deprecation-past-present-and-future/) and so we recommend checking both out.

The TL;DR version of the story goes something like this. PSP ultimately lead to the establishment of a set of easily-bundled "standards" known as [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). These standards, as all, aren't a "how" they're a "what". Standards aren't a technology, they define what Pods should do in order to be considered secure. Standards are organized into "controls" where each control is basically a directive on which field(s) should be configured in a prescribed way. These standards are still here today because they capture all (well, most) the security-related fields of a Pod and provide an easy-to-understand way to secure them. These standards are beneficial because, prior to them, Pod security was somewhat of the wild, wild west. It wasn't clear what really _should_ be done to secure Pods, in what situations, and how to best go about that. But PSP was at least the "how" before the standards existed. Once the writing was on the wall for PSP, a replacement had to be found. That replacement was Pod Security Admission (PSA). PSA was the "how" for Pod Security Standards (again, only the "what"). PSA implements the Pod Security Standards, which are broken down into basically two profiles. There were already many improvements with PSA but one of the nicest was they weren't tied to RBAC like PSPs were. PSA is the in-process way to secure Pods today and is a great way to get started with securing Pods if you never experienced PSP. But, as with all things, there are trade-offs. PSA is very rigid in its wide application of these standards. Entire profiles of controls are implemented in a single swath with no opportunity for customization. While this works in some situations, the lack of flexibility is a big challenge for operating Kubernetes in most real-world environments today. This is where Kyverno can come in and give you the best of all those worlds: comprehensive coverage of Pod security and in a way which is totally flexible, meets you where you are, and is easy to do.

## Comparison

We've put together a comparison table below which allows you to see how the three options stack up and we'll cover each of these rows below to give you a better explanation of what they mean.

|                 Pod Security Policy             |            Pod Security Admission          |                     Kyverno                    |
|:-----------------------------------------------:|:------------------------------------------:|:----------------------------------------------:|
|     Pods only                                   |     Pods only                              |     Anything                                   |
|     Limited options                             |     Only 2 options (PSS only, gaps*)       |     Anything                                   |
|     Limited mutation                            |     No mutation                            |     Mutate anything                            |
|     Requires RBAC modifications                 |     Does not require RBAC                  |     Does not require RBAC                      |
|     Limited to User, Group, ServiceAccount      |     Limited to cluster, Namespace          |     Any association                            |
|     No support for Pod controllers              |     No support for Pod controllers**       |     Automatic support for Pod controllers      |
|     No auditing                                 |     Audits in audit log                    |     Audits in Policy Reports                   |
|     No message customization                    |     No message customization               |     Fully custom messages                      |
|     No exclusions                               |     No exclusions                          |     Flexible exclusions                        |
|     Integrated                                  |     Integrated                             |     External                                   |

\* No readOnlyRootFilesystem, runtimeClass (excludes deprecated options)<br>
\*\* Audit support only

**Pods only.** PSP and PSA, as the names imply, only function on Pods. This is a great thing, but Pods aren't the only resource that need security in Kubernetes. Kyverno can cover anything in Kubernetes, even custom resources, both current and future.

**Limited options.** PSP offers around 20 different options for controlling a Pod's spec (several of these are now deprecated or removed), all of which are naturally security inclined. PSA has even less. You get two options, one for each profile (baseline and restricted). Kyverno allows access to every Pod field (and every other field for every other resource).

**Limited mutation.** This was one of the nice things about PSP that went away in PSA. Pods could be mutated to apply some default values if not specified. PSA dropped that entirely. With PSP, you only got about 5 different mutations. With PSA, you get none. And with Kyverno, you can mutate anything you want on any resource.

**Requires RBAC modifications.** This was one of the biggest pain points for those who know PSP. From the moment PSP was activated in a cluster, it was basically a breaking change unless you had extensive RBAC resources in place in the form of Roles, RoleBindings, ClusterRoles, ClusterRoleBindings, and the PodSecurityPolicy resources as well. It was an implicit deny and an explicit allow behavior, but only if you were authorized to use at least one in the first place. PSA improved here in that it wasn't tied to RBAC at all which meant much complexity was alleviated. Kyverno, like PSA, does not require RBAC to consume policies. From the moment a policy exists, it takes effect based upon its definition.

**Limited to User, Group, and ServiceAccount.** As it was tied to RBAC, PSP had its scope of application tied to these principals which made it difficult to apply and often resulted in a huge web of these mappings. PSA is limited to either the whole cluster or Namespace, but nothing further. Kyverno can be associated with anything and apply as granular as you can express in Kubernetes.

**No support for Pod controllers.** Another bummer for PSP users was the fact that Pod controllers such as Deployments and StatefulSets would always be allowed but Pods would be blocked. You had to figure this out typically by going to inspect the ReplicaSet to understand why. PSA has basically the same behavior here. Kyverno has automatic support for Pod controllers through its ability to [auto-generate Pod controller rules](/docs/writing-policies/autogen/).

**No auditing.** A PSP either blocks or it doesn't, there's no in between. PSA can audit, warn, or block, but the audits are locked up in the API server's audit log which isn't visible inside the cluster. Kyverno generates its audits as a cluster-visible, custom resource called a [Policy Report](/docs/policy-reports/) which is an open standard developed by the Kubernetes Policy Working Group and is adopted by other tools aside from just Kyverno. These Policy Reports are just another Kubernetes resource allowing them to be scraped by other tools and, importantly, read by other users in a way which can be controlled via RBAC.

**No message customization.** When a PSP blocks a Pod the message can't be customized. Same situation with PSA. The message returned by Kyverno can be fully customized making it very useful to show, for example, a team name or email of someone for developers or users to contact.

**Integrated.** PSP and PSA are both integrated into the control plane. Kyverno is an external component (a dynamic admission controller) and so must be run separately in your cluster. In order to do this, Kyverno uses webhooks.

## Migration Outline

When migrating from PSP to Kyverno, this is the high-level approach that we recommend. Links are provided for the Kyverno concepts which are applicable to this migration, however it is still recommended that before diving into a migration yourself you spend some more time with the documentation and, of course, experimentation in a lab or non-production environment.

1. Identify which PSP you want to offload to Kyverno starting with the narrowest scoped PSP first. Each field in the PSP should translate to one rule in most cases. Most fields are covered by the Pod Security Standards and Kyverno already has [pre-built policies ready to go](/policies/?policytypes=Pod%2520Security%2520Standards%2520(Baseline)%2BPod%2520Security%2520Standards%2520(Restricted)) for the entire set. It additionally has other policies specifically for [PSP migration cases](/policies/?policytypes=PSP%2520Migration) to cover all remaining capabilities which PSP covered (including mutation use cases).
2. Identify and install the needed Kyverno policy in `Audit` mode after first determining the scope at which it should operate. Kyverno policies, unlike PSPs, do not require RBAC to consume the policy. As soon as it is installed, it takes effect. There are [two variants](/docs/kyverno-policies/) of Kyverno policies: ClusterPolicy and Policy. A Policy is Namespaced and is therefore confined to operating on the Pods within that same Namespace. A ClusterPolicy is cluster scoped but may still be configured to selectively operate at a more granular level including a specific Namespace, for a specific User, for a group of Users, for a ServiceAccount, or a combination thereof. In other words, a Policy is maximally scoped at the Namespace. A ClusterPolicy is maximally scoped at the cluster. Each one may have its scope decreased but not increased. They can be mixed and matched to suit your needs.
3. Before moving forward, wait for [Policy Reports](/docs/policy-reports/) to be generated. Verify the reports do not contain any Failed entries. A Pod which is blocked by a PSP will not go on to be observed by Kyverno, therefore there should be no Failed results in a Policy Report for a Kyverno policy analogous to its PSP counterpart. For tighter confinement of the Kyverno policy, you can configure the match block to only consider Pods which are allowed due to a specific PSP through use of the annotation `kubernetes.io/psp`. The value of this annotation will be the name of the PSP used for validation. Keep in mind, if choosing to match based on this annotation it will disable [auto-gen rules](/docs/writing-policies/autogen/) so only Pods will be shown in reports. [Background scanning](/docs/policy-reports/) (on by default) must be enabled in these policies to evaluate resources which already exist in the cluster.
4. Once the reports look as intended, change RBAC in such a way that a more permissive PSP is referenced instead. As long as PSP is enabled in the cluster, it is an implicit denying action. Only through the presence of at least one PSP which permits the Pod can it be created.
5. Create a test Pod which would be in violation of the deprecated PSP (and would previously be blocked) and ensure it is allowed by the more permissive PSP.
6. Wait between 10-20 seconds and check the Policy Report in the Namespace where the Pod was just created.
7. Verify that the result in the report corresponding to this Pod is listed as a Fail result. This indicates the Kyverno policy has caught the Pod and it is now in violation of a Kyverno policy.
8. Change the policy to `Enforce` mode which will then block these Pods, same as the PSP which was just deprecated.
9. Continue to follow this process until all PSPs have been moved to the most permissive PSP and are now being enforced by Kyverno.
10. Optionally, during an outage window, you may choose to deactivate PSP (if applicable) by removing the `PodSecurityPolicy` value from the `--enable-admission-plugins` flag, or inversely, add the `PodSecurityPolicy` value to the  `--disable-admission-plugins` flag on the Kubernetes API server.

## Guided Migration

In this section, we'll walk you through a guided migration process which follows the outline shown above. Although your PSPs are likely to be different, we'll illustrate this process with a couple of simple examples. Obviously, keep in mind that your RBAC situation is likely different, so use this as a general template to understand what is required.

We'll assume the following:

1. Kubernetes v1.24 is in use although this should be applicable to earlier versions as well. Note the versions supported by Kyverno in the compatibility matrix [here](/docs/installation/#compatibility-matrix).
2. A Namespaced called `qa` which is the subject of this tutorial.
3. A user named `chip` who is currently subject to a PSP in the `qa` Namespace we wish to migrate onto Kyverno.

First, we've identified the following PSP which requires that host namespaces, corresponding to Pod spec fields `hostNetwork`, `hostIPC`, and `hostPID` must be unset or set to `false` if they are defined. This is a common component of many PSPs because it prevents Pods from gaining access to the underlying host in a way which could compromise it. It's also a good illustration because this maps nicely onto the Pod Security Standards control of a similar name, and there is a Kyverno policy which covers this control [here](/policies/pod-security/baseline/disallow-host-namespaces/disallow-host-namespaces/).

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: qa
spec:
  hostNetwork: false
  hostIPC: false
  hostPID: false
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
```

Next, we will create a Role in the `qa` Namespace which allows the above PSP to be used.

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: psp-qa-role
  namespace: qa
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - qa
  verbs:
  - use
```

Once the Role is created, we need to bind this role for the user `chip` in the `qa` Namespace.

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: psp-qa-bind
  namespace: qa
subjects:
- kind: User
  name: chip
roleRef:
  kind: Role
  name: psp-qa-role
  apiGroup: rbac.authorization.k8s.io
```

Here's a "good" Pod which doesn't use any host namespaces and is allowed.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: busybox
  name: goodpod
spec:
  automountServiceAccountToken: false
  hostIPC: false
  containers:
  - name: busybox
    image: busybox:1.35
    args:
    - sleep
    - 1d
```

Here's a "bad" Pod and will be blocked by the `qa` PSP if created by user `chip`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: busybox
  name: badpod
spec:
  automountServiceAccountToken: false
  hostIPC: true
  containers:
  - name: busybox
    image: busybox:1.35
    args:
    - sleep
    - 1d
```

Now that the baseline has been established, after installing Kyverno, introduce this policy into the cluster which provides the same level of validation as our `qa` PSP. Note a couple things here:

1. This is a ClusterPolicy which means it applies to the entire cluster however it has been scoped down to only match on the `qa` Namespace. This will be opened up later but for now, it will only be confined to that Namespace.
2. The policy matches on `Pod` and no other type of resource.
3. The policy is in `Audit` mode which means it will not block any Pods which violate the policy. We will change this a bit later to provide the same blocking action as our PSP.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-namespaces
  annotations:
    policies.kyverno.io/title: Disallow Host Namespaces
    policies.kyverno.io/category: Pod Security Standards (Baseline)
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Host namespaces (Process ID namespace, Inter-Process Communication namespace, and
      network namespace) allow access to shared information and can be used to elevate
      privileges. Pods should not be allowed access to host namespaces. This policy ensures
      fields which make use of these host namespaces are unset or set to `false`.      
spec:
  validationFailureAction: Audit
  background: true
  rules:
    - name: host-namespaces
      match:
        any:
        - resources:
            kinds:
              - Pod
            namespaces:
              - qa
      validate:
        message: >-
          Sharing the host namespaces is disallowed. The fields spec.hostNetwork,
          spec.hostIPC, and spec.hostPID must be unset or set to `false`.          
        pattern:
          spec:
            =(hostPID): "false"
            =(hostIPC): "false"
            =(hostNetwork): "false"
```

With this Kyverno policy installed, assuming there are existing Pods (at least the "good" Pod test from above) in the `qa` Namespace, wait 10-20 seconds and check for Policy Reports. We want to ensure there are only results in the `PASS` column and none in the `FAIL`. Since the PSP is providing the same level of protection, Pods caught by the PSP and blocked will not get created and, therefore, Kyverno should not see any which violate the same controls.

```sh
$ kubectl -n qa get policyreport
NAME                            PASS   FAIL   WARN   ERROR   SKIP   AGE
cpol-disallow-host-namespaces   1      0      0      0       0      3s
```

Now that we're looking good on the reports side, let's introduce a more permissive PSP. This PSP is more open than our `qa` PSP in that it permits use of host namespaces. Since a Pod must pass through at least one PSP, the only way we can migrate away from PSP with it still enabled is to make PSP, at some point, maximally permissive so the Pods will pass through the API server and get caught by Kyverno. This may not look exactly like your permissive PSP, but it gives you an idea of the general flow. Create this PSP called `permissive` in the cluster.

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: permissive
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: "*"
spec:
  hostIPC: true
  hostPID: true
  hostNetwork: true
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  hostPorts:
  - min: 0
    max: 65535
  volumes:
  - '*'
  allowedCapabilities:
  - '*'
```

With the `permissive` PSP created, change the `psp-qa-role` Role in the `qa` Namespace to reference the new PSP instead. The only change we'll make is to flip from `qa` to `permissive` under the `resourceNames` field.

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: psp-qa-role
  namespace: qa
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - permissive
  verbs:
  - use
```

Because the `chip` user still has a binding to this Role, we should now be able to test with a sample "bad" Pod. We now expect that this will be permitted by the PSP and allowed in the cluster.

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: busybox
  name: badpod
spec:
  automountServiceAccountToken: false
  hostIPC: true
  containers:
  - name: busybox
    image: busybox:1.35
    args:
    - sleep
    - 1d
```

Verify that the `permissive` PSP was the one evaluated by inspecting the annotations on the `badpod` Pod. Here we can see the annotation `kubernetes.io/psp` as assigned the value `permissive` indicating our more permissive PSP was the one evaluated by this Pod's creation request.

```yaml
$ kubectl -n qa get po badpod -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"busybox"},"name":"badpod","namespace":"qa"},"spec":{"automountServiceAccountToken":false,"containers":[{"args":["sleep","1d"],"image":"busybox:1.35","name":"busybox"}],"hostIPC":true}}
    kubernetes.io/psp: permissive
```

After creating the "bad" Pod, wait a few seconds and then once again get the Kyverno Policy Report to confirm that Kyverno caught it instead. We should now see that there is one result in the `FAIL` column which indicates Kyverno saw our "bad" Pod violated the policy we created earlier.

```yaml
$ kubectl -n qa get policyreport
NAME                            PASS   FAIL   WARN   ERROR   SKIP   AGE
cpol-disallow-host-namespaces   1      1      0      0       0      3m3s
```

Let's inspect the contents of that policy report just to be sure. The following command assumes you have [yq](https://github.com/mikefarah/yq) installed.

```yaml
$ kubectl -n qa get policyreport cpol-disallow-host-namespaces -o jsonpath='{.results[?(@.result=="fail")]}' | yq -p json -
category: Pod Security Standards (Baseline)
message: 'validation error: Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must be unset or set to `false`.          . rule host-namespaces failed at path /spec/hostIPC/'
policy: disallow-host-namespaces
resources:
  - apiVersion: v1
    kind: Pod
    name: badpod
    namespace: qa
    uid: 60c5f78a-0ff0-4666-8705-d4f6f3e943d2
result: fail
rule: host-namespaces
scored: true
severity: medium
source: kyverno
timestamp:
  nanos: 0
  seconds: 1.684957284e+09
```

The "bad" Pod clearly failed and the policy report contains more details.

Now that you're confident things are configured correctly, change the Kyverno policy to `Enforce` mode and attempt to create another "bad" Pod. You should see this is now blocked.

```yaml
spec:
  validationFailureAction: Enforce
```

```sh
Error from server: error when creating "badpod.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Pod/qa/extrabadpod was blocked due to the following policies 

disallow-host-namespaces:
  host-namespaces: 'validation error: Sharing the host namespaces is disallowed. The
    fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must be unset or set to
    `false`. rule host-namespaces failed at path /spec/hostIPC/'
```

When you're comfortable with these results, the Kyverno policy can be opened up further should you wish by removing the match on the `qa` Namespace so it applies across the entire cluster.

When all aspects of your cluster have been migrated to a permissive PSP, you may choose to deactivate the PodSecurityPolicy admission plugin in the cluster by removing the `PodSecurityPolicy` value from the `--enable-admission-plugins` flag, or inversely, add the `PodSecurityPolicy` value to the  `--disable-admission-plugins` flag on the Kubernetes API server.
