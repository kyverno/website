---
title: Auto-Gen Rules for Pod Controllers
description: >
    Automatically generate rules for pod controllers.
weight: 7
---

**Note: The auto-gen feature is only supported for validation rules with patterns and mutation rules with overlay. Deny rules and Generate rules are not supported.**

Writing policies on pods helps address all pod creation flows. However, when pod controllers are used pod-level policies result in *"hidden"* errors that are not reported when the pod controller object is created (the error is reported when the pod controller creates the pod and hence not visible to the user.)

Kyverno solves this issue by supporting automatic generation of policy rules for pod controllers from a rule written for a pod.

This auto-generation behavior is controlled by the `pod-policies.kyverno.io/autogen-controllers` annotation. 

By default, Kyverno inserts an annotation `pod-policies.kyverno.io/autogen-controllers=DaemonSet,Deployment,Job,StatefulSet,CrobJob`, to generate additional rules that are applied to these pod controllers. 
 
You can change the annotation `pod-policies.kyverno.io/autogen-controllers` to customize the target pod controllers for the auto-generated rules. For example, Kyverno generates a rule for a `Deployment` if the annotation of policy is defined as `pod-policies.kyverno.io/autogen-controllers=Deployment`. 

When a `name` or `labelSelector` is specified in the match / exclude block, Kyverno skips generating pod controllers rule as these filters may not be applicable to pod controllers.
 
To disable auto-generating rules for pod controllers set `pod-policies.kyverno.io/autogen-controllers`  to the value `none`.
