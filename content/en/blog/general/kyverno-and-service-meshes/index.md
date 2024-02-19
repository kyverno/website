---
date: 2024-02-04
title: Securing Services Meshes Easier with Kyverno
linkTitle: Securing Services Meshes Easier with Kyverno
description: Providing better Pod security for service meshes with Kyverno.
draft: false
---

Service meshes are all too common these days in Kubernetes with some platforms even building them into clusters by default. Service meshes are no doubt useful in a variety of ways which are well known, but it's also well known they dramatically increase the complexity in those clusters. In addition to added complexity, service meshes also pose a (infamous) problem when it comes to enforcing Pod security because they require elevated privileges which can be difficult for other admission controllers to handle like Kubernetes' own Pod Security Admission. In this post, we'll explain more about this problem and how Kyverno can be a real savior when employing service meshes while giving you a preview of something to come in Kyverno 1.12 which will make security service meshes a piece of cake!

## Introduction

Service meshes [provide many benefits](https://konghq.com/learning-center/service-mesh/what-is-a-service-mesh) to Kubernetes applications including better load balancing, mutual TLS, observability, and more. It's possible you're even using a service mesh right now in one of your clusters. The most popular open source service meshes out there are [Istio](https://istio.io/) and [Linkerd](https://linkerd.io/). All service meshes work fundamentally the same way which we won't attempt to cover in depth in this blog. One salient point is that in order for traffic to be directed to and from their "sidecar" proxies it requires some tweaks to the iptables rules on the underlying Linux nodes. These tweaks or configuration modifications are the service mesh rewriting the routing rules of the networking stack. In order to do this, meshes like Istio and Linkerd employ an [initContainer](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) to do this before any of the other containers in the Pod start. And in order for that initContainer to do its job it requires some privileges which are very often problematic in security-conscious clusters. Minimally, these initContainers must add two [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) which allow them to make modifications to the networking stack: `NET_ADMIN` and `NET_RAW`. These initContainers may go even further by running as a root user, something which is a big no-no in the world of containers.

For example, Linkerd 2.14 will inject an initContainer like this into any Pod which should be part of its mesh (some fields omitted for brevity).

```yaml
initContainers:
  - image: cr.l5d.io/linkerd/proxy-init:v2.2.3
    name: linkerd-init
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        add:
          - NET_ADMIN
          - NET_RAW
      privileged: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 65534
      seccompProfile:
        type: RuntimeDefault
```

The thing is these additional privileges required by service mesh initContainers are forbidden by the Kubernetes official [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). This fact itself isn't the main problem but rather that, depending on the policy engine used, providing allowances for these specialized initContainers is either difficult or downright impossible. We hear users' pain just about every week in the [Kyverno community](/community/) and it seems those who experience the problem the worst are those using [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/), the in-process admission controller implementing the Pod Security Standards. This has become such a notable problem that both Istio and Linkerd [have tried](https://istio.io/latest/docs/setup/additional-setup/cni/) to [solve for it](https://linkerd.io/2.14/features/cni/) (or, more accurately, work around it) by offering another option: a custom CNI plugin.

## CNI Plugin

These CNI plugins work for many but are still, for the most part, solve one problem at the expense of creating others. After all, the iptables rules still _must_ be rewritten and something in the mesh still _must_ be responsible for that task. In both cases, the CNI plugin implements a DaemonSet which runs a privileged container to perform these modifications on every node thereby avoiding the need for an initContainer in every Pod. This does have its advantages but it also has disadvantages.

* The DaemonSet is even more privileged as it requires hostPath volumes and copies a configuration file and a binary to each node.
* It requires understanding CNI plugins which is specialized knowledge.
* Creates more complexity to operate and automate.
* Creates potential conflicts with other CNI plugins since they aren't aware of each other and determining how to chain multiple together isn't standardized.
* Creates potential race conditions during horizontal cluster scaling or node restarts as the DaemonSet Pod may not launch before workload Pods.

## The Crux of the Problem

But why is solving the initContainer problem an actual problem? The answer lies in exclusions. Exclusions, or how you exempt certain resources from being applicable to policies, is what distinguishes good admission controllers from great ones. The objective is to provide as strong of a Pod security posture as you possibly can while not impacting things which you objectively need. You want to be able to separate the "good" from the "bad" and your service meshes are definitely in the "good" category. But like a sieve filters sand, you have to carefully filter out the "good" so you're only left with the "bad". In that initContainer example previously, you definitely don't want non-service-mesh Pods from adding the `NET_ADMIN` capability as that would give them unfettered access to the networking stack allowing, for example, snooping and masquerading to occur. Options for reducing the size of the funnel are as follows, from largest to smallest.

* Disable Pod security in the entire cluster
  * This is obviously a non-starter so no need to discuss further.
* Disable Pod security in the affected Namespace
  * Because we're talking about an initContainer in every Pod that must participate in the mesh, that basically means you'd have to disable Pod security in most Namespaces of the cluster which is effectively like the first option--a no-go.
* Disable the profile which contains this check (if applicable)
  * Pod Security Standards are organized into collections called profiles with each profile containing multiple controls. A control is an edict on _what_ fields should be checked and what values are or are not permitted. You could find the profile which includes this control and disable the whole profile, but that obviously disables other controls in the same profile. Also not great. Not all policy admission controllers offer this ability.
* Disable the control on the Pod
  * These initContainers which request `NET_ADMIN` and `NET_RAW` violate the ["Capabilities" control in the baseline profile of the Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/#baseline), which is the foundational profile of Pod security (the restricted profile builds upon baseline). You could simply not check for this control in any Pod which uses such an initContainer, but that's no good either because then a malicious container could also add `NET_ADMIN`. Great that you may be enforcing all other controls, but deactivating even one control summarily is still too much.
* Disable the control on one image
  * If you've reached this level, you're doing well. You can simply not check for these privileged capabilities on images which match a certain pattern. But we can do even better still. (By the way, it wouldn't be completely safe to do this based on the name of the initContainer as some malicious user could create an initContainer called `istio-init` which uses an image named `ubuntu:latest`.)
* Disable the control on one image and in one location in the Pod
  * Now we're talking. We can isolate an exemption to ONLY a specific image and ONLY in a specific location in the Pod. For example, we can excuse the `istio/proxyv2` image if it is found in the `initContainers[]` array but only from the capabilities check. If that same image is used in the main `containers[]` list, it would cause the entire Pod to be denied.

One reason why many folks have trouble with this problem is due to Pod Security Admission (PSA). With PSA, the most granular you can achieve is the third bullet from the top: disable the profile which contains this check. Because the restricted profile is inclusive of the baseline profile, disabling the baseline profile on a Namespace is essentially the same as enforcing no Pod security at all. This limitation is the primary reason why the CNI plugin solution was created. If service meshes can separate out the need for those elevated privileges into just a single controller (a DaemonSet) and that controller only runs in a single Namespace, then we can basically isolate that one Namespace with an exemption.

## Policies in Kyverno

In Kyverno, you have a couple options for implementing Pod Security Standards. The first and "original" way is by writing a `validate` rule for each control within the Pod Security Standards. Kyverno already provides the full complement of such policies packaged as a [Helm chart](https://github.com/kyverno/kyverno/tree/main/charts/kyverno-policies) which are also available as [individual policies](/policies/?policytypes=Pod%2520Security%2520Standards%2520%28Baseline%29%2BPod%2520Security%2520Standards%2520%28Restricted%29). The "Capabilities" control in the baseline profile, for example, can be found [here](/policies/pod-security/baseline/disallow-capabilities/disallow-capabilities/). In this style of policy, you can get as granular as you like. The slight downside is, when it comes to the pre-built Pod Security Standards, they require some modifications when it comes to these service mesh initContainers. While some of those modifications are fairly gentle, others may need to be more extreme.

For example, this is what the same "Capabilities" check may look like in order to make allowances for these service mesh initContainers.

> Since Kyverno is very flexible when it comes to policy authoring there are almost always multiple ways to write the same declaration, so if you've already done this and the results differ don't worry.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-capabilities
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: adding-capabilities-service-mesh
      match:
        any:
        - resources:
            kinds:
              - Pod
      preconditions:
        all:
        - key: "{{ request.operation || 'BACKGROUND' }}"
          operator: NotEquals
          value: DELETE
      validate:
        message: >-
          Any capabilities added beyond the allowed list (AUDIT_WRITE, CHOWN, DAC_OVERRIDE, FOWNER,
          FSETID, KILL, MKNOD, NET_BIND_SERVICE, SETFCAP, SETGID, SETPCAP, SETUID, SYS_CHROOT)
          are disallowed. Service mesh initContainers may only add NET_ADMIN and NET_RAW to this list.
        foreach:
          - list: request.object.spec.initContainers[]
            preconditions:
              all:
              - key: "{{ element.image }}"
                operator: AnyIn
                value:
                - "*/istio/proxyv2*"
                - "*/linkerd/proxy-init*"
              - key: "{{ element.securityContext.capabilities.add[] || `[]` }}"
                operator: AnyNotIn
                value: ["NET_ADMIN","NET_RAW","AUDIT_WRITE","CHOWN","DAC_OVERRIDE","FOWNER","FSETID","KILL","MKNOD","NET_BIND_SERVICE","SETFCAP","SETGID","SETPCAP","SETUID","SYS_CHROOT"]
            deny:
              conditions:
                all:
                - key: "{{ element.securityContext.capabilities.add[] || `[]` }}"
                  operator: AnyNotIn
                  value: ["AUDIT_WRITE","CHOWN","DAC_OVERRIDE","FOWNER","FSETID","KILL","MKNOD","NET_BIND_SERVICE","SETFCAP","SETGID","SETPCAP","SETUID","SYS_CHROOT",""]
          - list: request.object.spec.[ephemeralContainers, containers][]
            deny:
              conditions:
                all:
                - key: "{{ element.securityContext.capabilities.add[] || `[]` }}"
                  operator: AnyNotIn
                  value: ["AUDIT_WRITE","CHOWN","DAC_OVERRIDE","FOWNER","FSETID","KILL","MKNOD","NET_BIND_SERVICE","SETFCAP","SETGID","SETPCAP","SETUID","SYS_CHROOT",""]
```

Feel free to [take this for a spin in the Kyverno Playground](https://playground.kyverno.io/#/?content=N4IgDg9gNglgxgTxALhAQzDAagUwE4DOMEAdsgAQDWCAbviRAHTED0NAjADomUwkAmFAMJQArgQAu%2BAArR4CbgFscEtPzSrk3cuRJplFfjAJooUCAHcAtHAxoARjFgSYOAtwJgccLSR01TGHUXUgAxNCdRPBwAQTgQsnIAURIAMwg8OBxtcns0OEoAczwIUQEKCTxRbL9yKqg3Xx0dK119HAo1IxJCmztHZ1cCKwJ8GngcK2UCAAsc5vJFDTgZpoXmtBIENfXyVuiCUszG%2Bd3m3gECHbOF1tl%2BU50waLhSIwSrx42za9uqHG25E4IGAwDqOAAjtVJIwIF48BpiH4AD7I8gAcgAQjEhABpADiACUAPIAVQAcgARdHkAC%2BtOBXwWcPwGgyFHJEAkSShpnctRuATEHXIlKSABkkgAVJJfIVBDQdJmLNwmQoigB8VmVOhiW3ItjADicMBcbnIXRw/FyALe5AkMxwFrMlit5FgknIAAoYqTKQBJKUAfQA6oTA0kADTkIQACWJIfJ0cpOKDxKwSUJ4bF0dCCfJmcjOvIoQAytL/ZTo7j/eLxdGALK48nEqvkAvBzH%2BqlB8uErD%2BoRR8jlqWhIQxaTR0f4yvT6XSCdTkfS0lzkcATVLQbjJOJUoAlMW0NFyEYTC6LFbGCOxhMVbNyHxTUJSKo%2BPgCIs0AhyKQoL%2BXTttKQYxJSDbdhaAjAcGhIxCG9oQPaMzGO6xgSIwyrpNE%2BSrMWrQehIFDRFCbgYRA9gAFbeBhnjeMwJAvm%2BEQkJ%2BADaAC6xZPC8bymkinwCjc3xQL8wmtJQAIUMCoLkDgDTKCQGEwEs6p0gyIDcesLIIhI7LkHqCD%2BiQWkLEK1RicJexAiAABULDoawzwQAAHrQABMtmMkJVktDZ9mwDw%2BD8CwzluVYz4SF5mk%2BeJ/yAjJYLyTgim0d4USmggr5KTgLkYYaxqDG4jBdJx5CouQAAGnGVep3m%2Bdp8JsngFCGZyEjGaZzTmSKbHAh2oHgd2wJFiAA1wSGI3Ar6AbBmGEZTSAcb5otKZCGmGZZpWsogKNeaJpmi1lhWlKLTWdaLU2Lanbt/UgV2PZ9gOQ6LaO46Tq90qzjdo2jouH23SAo5rj9wKlluO6xnuUrAlxsW7PwOBbJZZyvAI/GkIJDULKYoldX5kkJSCSUKUjaVwBlEhZW%2BuX5f0JpmgQJX8PwZUVdVHG1fS9XY8yTV6S1BlbO1nXw75PUUH1IAzYGobhjKi3LYmq2pummbZjte35odgPHVKlZnbW4qXc2raLQND2Ur2mbPZrYPSu90ifVK33O/9TuA8DBuexDu7Evui2w/haGSMRkLQuRVE0YwdFwIwbE4GAjrKAiUDZe%2BrGENGaMZ5%2BHGcVpiPI11aPvAJKM3LjFdnBJUk2bJyWpTH6V4Jl6e04wBUDPxxWlRx5VohzXMafjzQ6c1rXC1you82ZpgWeQUsy3N8t20t8bK4Da0ber21HdrhJHaO3ujedxuA1dZuAxb3ZW09g5r29S7O67nsLs/b9SiDr2%2B1D/sw4DIOJBdogAOEcLIKB0CYFwIQJEFAODcAuIIcg9wlAqDUBoNAaw9AGCfJIYgVhIAPBILHNYkV04sU/GsVoOCRSOQgBFRiEhTgqTQOqQwEACj4GYBABy%2BDeFhQ8sgdgjB3IAAZRGnBPIULGNc8EhAimAVQ9gGj8huK0QhypWjAnYAAVjEWIrgMV1F7AAF5aJsnogxAA2HmuwNGiAsTogAzM4gA7HY9YGjFAWMJEkAMfihAwzFhomAFj0S2XRBYqwLknGaWMXIqw9hwmROicQkxViACcYjIxWPcuwXJ%2BjxHRKsOYQoQZSgSDAKICQQYGh0CgAAXkRqkNAogoBET4OkU4owKatypu3PKYlcaWGkK3cYDR1RJAILYKAiJSAUFaVAUYXwu4MyGCjLo1dWgDTAhBckwdxrwWLAAYmsuDbcezhpi34CUMA2yDIXVis8GAEycDqmQUslZsUcL8GJCQAChIIBclCE4NwCBJApUWXyGouwqgkBiAQfEJRRD3PIGIr48LEWchIECrk0LlmwvWFiggpJRiCwxbUHOlDCDULaLg%2Bw4gED2Fciw1SIpGUEGZa5YRjBnG6KkXgGR1xWgEAaInU4rQumRQUEJM5vTKbUxykM04ZydAkpxXioi9oqhEp0Gqg09MiqyP1esLZqq5G7KGgcuVlqQITQtfYzclzrXcCsO67gGBsCfjgeQBBPA%2BDINQSQZQqhghYJyLQiggVJJ4H4IQiAxDSE5HIcxD8tLJUWiFSarxexGGvEUHwXogiE14GYSEmyAAWdglbnGeL%2BO6yphQIBFsISUcKkAy1xOrZWjFCSnXupLaIIIcT8liPcvW5oGjGEsrKPGztEhhh6QioUBg0QLHVuyZGTdBTK26OsW47d%2B6AAcJTKmzoEKWxdVhl0wFXRkPVua90HqPdY09sVWHsINHgRgUBdH8B4SwGNwVQrtoQIw00yAaDuVEXyr4Ua0JBTjRB8tuwFX9KVVIFVYsRkWDGa8sFUyZmmHmYkL5j6FhrONdXc1Ys/hWv2VpHZ9rjl0eaGc1oFzBqMbFi8t5HyCXfJuL8/5gLgUSFBaoiFUhFAVF1cqDVpAtVyeqApsoiKyX4AoNY3RujnGVuVL0gtYAxkQFSGC6uVMvAUEJGUFwyhKQ4Fae01DBo02Zxza0aROa/hipwBKit0qmGyt2J%2BjlTKWUuV5fy%2BD7QKCcu5bE2K8qW5txpth3YBrFO4vEypij5ADVUZ7j5grZqWZiQNfRkCVybWZbtbBVjdWnVcZq9wEB0B%2BCEjcOAnAkCQEU0kBARQXXDhRCyI58zTCBJ9cjCAOAYhIV4BGz1ggM2QC5SyEo6bqAQC0iAA===) and see for yourself. Inside, you'll find sample Pods for both Istio and Linkerd, so try to uncomment and copy elements around to test it out.

Because Istio's initContainer requires a few more privileges than Linkerd's, some slight modifications are also necessary to a couple more policies, these being found in the [restricted profile](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted). For example, here's a [Kyverno Playground link](https://playground.kyverno.io/#/?content=N4IgDg9gNglgxgTxALhAQzDAagUwE4DOMEAdsgAQDWCAbviRAHTED0NAjADomUwkAmFAMJQArgQAu%2BAArR4CbgFscEtPzSrk3cuRJplFPDgCOomEYC0eUSQtoCFhiTwQIE7gTA44WkjpposOoSxCQAYmgwYkYAgnAhpBQAoiQAZhB4cDja5ABGaHCUAOYuNoLkEtbZfuTWUDgEvjo6Frr6OIY2dg5OVq4SFjCSxDnN5IoacAAWTWPNaCQIs3PkrUYEEKKZDcsrzbwCjaN7Y62y/Mf%2BgTDBHZfNygQEaEUd5AB8FvdjAEo2JHwiuR7LV%2BuQhro3MCoFAIAB3HD8RjkJIwCRTfAVDHkVIwHBQfjkTzeRgEbxbNEIISkKQADwkjGsJBiBAAcqQfv1vg9xBI8jgiSoKhByAADSqiHCigA05AyWIFuPx/AIRK8cEYcBpkRI%2BAIAG0AFQAXVJ5LwlOpJDpDKZLPZJE5bml3J0xI1fDRVtUfD1RtNZLgFIkVJpOHpjJs9o5/VlC0J7sYODAGOUeEC3p1fpNZqDFpD3vDtqjbJjbld415/MFfIkIvFVVFyJO5G5CwQ0g0UjwZG5rXduxOgeDoetRcHLbtpcd/QoEuqLeaAF4ABTJ1P4DPa32EACUE5WrVXw/zo5t%2B4rK1XU4dTok%2B4qVUv5FXnokmZ3BAvNUXrRXMAmV4H04EAAEJDSGBIWDAFxaVoAAmQ0QOfHRj3NS0w3pb9FyvFcbzLe85yfH8Wy1a0s0IA85iPFcTwwscsKok5rxLW9%2Bgfec%2BzVbwmOXNcUxwNMt3Iz9sJw/t0ILTCJF4lZ8JnNwiMlZ9XwBd9t11PdZNWch/0AnBgLAiDhggaDYIQpCQBQwU83om1tLGeS7yUhccLIn1NKOEiTgk2ypIYmTrJ0JzZ0fZSSBAaUQHWTZthQdBMFwQhQgoDhuAOcpziUFQ1A0NBZj0AxwRMixIAuEgBxyN8P082ZWkKt5IOIQY1OOACXjefgIEKfBmFMprTJgiA4JoeDkHYRh4IABkm440DwIovJ84qEkGMBVFyeoCC40quJA9gAFYpqmrgrO85pWgsAAvPaQEO46ADZkPOlpVlEW72AAZk%2BgB2Z7losRQuJ%2BJIABEAEkQaEAAVHaYC4gByQ0EZ22lbv%2BvZLtyRHkZ28rlvugBOKbpXu%2BD2FJo7pp2ixYSKAB9TYJDAUQJHp%2Bo6CgJd%2BBwVI0FEKAZL4dJjjo/z7PuQJYThaQLRoKIcFeJICDgQINBSnFAjJe5VbANBciiNE8SWvY1EECtWlZJJofpmJQYAWXB1kLfIK2bZ%2BGIAHVuX4FwwF41oYgAGSD%2B4YJgeX6leco%2BagbXzqMNQAHkSCgBA7zCBWCAQSRBIoWP47kksAHFSn98gpvuELFM1uPXMcksAFUyTwChK5qdyKJN%2Br2goXJxAQXJhra/S%2B4HofaXGxhPoOuaFpN16CHqZNjlaYW3wUEixbPccq9YgiXMikBoH4H4GlirJ4qPoNJAgRQz42LYslB3m31CAgr6iuAxFzvAH4vhon8QDhiyOtd%2BV8AC%2BQA) to what the [require-run-as-nonroot policy](/policies/pod-security/restricted/require-run-as-nonroot/require-run-as-nonroot/) may look like to exempt `istio-init`.

Individual Kyverno policies like those just shown allow maximum flexibility, but there is an easier path to Pod Security Standards in Kyverno. The second way of implementing these standards is using what we call a "subrule" to a `validate` style policy. [In this style](/docs/writing-policies/validate/#pod-security), the `podSecurity` element is used to refer specifically to these Pod Security Standards. Under the hood, Kyverno implements the exact same library as Kubernetes' Pod Security Admission but with a different "wrapper" to make their application more flexible.

For example, using this type of subrule would allow you to easily implement the entire baseline profile of the Pod Security Standards along with an exclusion for these service mesh images like so.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: pod-security-standards
spec:
  background: true
  validationFailureAction: Enforce
  rules:
  - name: baseline-service-mesh
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      podSecurity:
        level: baseline  ## enforce the baseline profile
        version: latest  ## enforce the latest version of this profile
        exclude:         ## exclude certain controls with optionally certain images
        - controlName: Capabilities
          images:
          - "*/istio/proxyv2*"
          - "*/linkerd/proxy-init*"
```

The `exclude[]` block here names the "Capabilities" control that we've been covering thus far, and the `images[]` field names the two specific service mesh images which should be excluded. With this ability you get PSA-like behavior but with granularity that is simply not possible.

These two options give you plenty of choice, but they all involve modifying the policy directly. Another option exists which allows decoupling the exceptions from the policies themselves, and these are [Policy Exceptions](/docs/writing-policies/exceptions/). For example, you can write a PolicyException resource which exempts a given Pod from a specific rule in a specific policy. This is great especially for developer self-service as it allows other users to request exceptions without having to so much as look at a Kyverno policy. However, this as it stands in 1.11 isn't quite granular enough for cases like service mesh initContainers and so is receiving some nice upgrades in Kyverno 1.12. More on that next.

## Enhancements in 1.12

With the forthcoming Kyverno 1.12, we're making some exciting enhancements which will make exclusions for use cases like service mesh containers even easier.

The first enhancement in 1.12 is the ability to further classify exclusions to the podSecurity subrule by listing specific fields as well as their values. This allows you to both use the easy style of policy language but get down to the lowest level of the funnel. For example, this is how you'll be able to enforce the entire baseline profile of the Pod Security Standards but only exclude Istio's and Linkerd's images from specifically the initContainers list.

```yaml
### Coming in Kyverno 1.12 ###
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: pod-security-standards
spec:
  background: true
  validationFailureAction: Enforce
  rules:
    - name: baseline-service-mesh
      match:
        any:
          - resources:
              kinds:
                - Pod
      validate:
        podSecurity:
          level: baseline
          version: latest
          exclude:
            - controlName: Capabilities
              images:
                - "*/istio/proxyv2*"
                - "*/linkerd/proxy-init*"
              restrictedField: spec.initContainers[*].securityContext.capabilities.add
              values:
                - NET_ADMIN
                - NET_RAW
```

The second enhancement is to Policy Exceptions making them podSecurity aware in that you will be able to exempt specific control names in the PolicyException resource. For example, below is a PolicyException you'll be able to create in Kyverno 1.12 for the previous `validate.podSecurity` subrule allowing you to decouple those exclusions but only for Pods created in the `staging` Namespace.

```yaml
### Coming in Kyverno 1.12 ###
apiVersion: kyverno.io/v2beta1
kind: PolicyException
metadata:
  name: pod-security-exception
  namespace: kyverno
spec:
  exceptions:
  - policyName: pod-security-standards
    ruleNames:
    - baseline-service-mesh
  match:
    any:
    - resources:
        namespaces:
        - staging
  podSecurity:
    - controlName: Capabilities
      images:
        - "*/istio/proxyv2*"
        - "*/linkerd/proxy-init*"
```

This will be enhanced further in the future to apply to a specific container. See and follow the issue [here](https://github.com/kyverno/kyverno/issues/8570) for details.

## Closing

This post covered a bit about service meshes and why the use initContainers as well as the security problems posed by them. We covered multiple ways how Kyverno can solve those problems in the most granular way possible while also providing a glimpse at the next version and how this process will be made even easier. [Get in touch](/community/#get-in-touch) with the Kyverno project if you have any other questions or feedback for us!
