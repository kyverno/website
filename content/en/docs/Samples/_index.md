
---
title: "Examples"
linkTitle: "Examples"
weight: 6
description: >
  See your project in action!
---

Sample policies are designed to be applied to your Kubernetes clusters with minimal changes. 

The policies are mostly validation rules in `audit` mode i.e. your existing workloads will not be impacted, but will be audited for policy complaince.

## Best Practice Policies

These policies are highly recommended.

1. [Disallow root user](/DisallowRootUser)
2. [Disallow privileged containers](/DisallowPrivilegedContainers)
3. [Disallow new capabilities](/DisallowNewCapabilities)
4. [Disallow kernel parameter changes](/DisallowSysctls)
5. [Disallow use of bind mounts (`hostPath` volumes)](/DisallowBindMounts)
6. [Disallow docker socket bind mount](/DisallowDockerSockMount)
7. [Disallow `hostNetwork` and `hostPort`](/DisallowHostNetworkPort)
8. [Disallow `hostPID` and `hostIPC`](/DisallowHostPIDIPC)
9. [Disallow use of default namespace](/DisallowDefaultNamespace)
10. [Disallow latest image tag](/DisallowLatestTag)
11. [Disallow Helm Tiller](/DisallowHelmTiller)
12. [Require read-only root filesystem](/RequireReadOnlyRootFS)
13. [Require pod resource requests and limits](/RequirePodRequestsLimits)
14. [Require pod `livenessProbe` and `readinessProbe`](/RequirePodProbes)
15. [Add default network policy](/AddDefaultNetworkPolicy)
16. [Add namespace quotas](/AddNamespaceQuotas)
17. [Add `safe-to-evict` for pods with `emptyDir` and `hostPath` volumes](/AddSafeToEvict)

## Additional Policies

These policies provide additional best practices and are worthy of close consideration. These policies may require specific changes for your workloads and environments. 

17. [Restrict image registries](/RestrictImageRegistries)
18. [Restrict `NodePort` services](/RestrictNodePort)
19. [Restrict auto-mount of service account credentials](/RestrictAutomountSAToken)
20. [Restrict ingress classes](/RestrictIngressClasses)
21. [Restrict User Group](/CheckUserGroup)

## Applying the sample policies

To apply these policies to your cluster, install Kyverno and import the policies as follows:

**Install Kyverno**

````sh
kubectl create -f https://github.com/kyverno/kyverno/raw/master/definitions/install.yaml
````
<small>[(installation docs)](https://kyverno.io/getting-started/)</small>

**Apply Kyverno Policies**

To start applying policies to your cluster, first clone the repo:

````bash
git clone https://github.com/kyverno/kyverno.git
cd kyverno
````

Import best_practices from [here](https://github.com/kyverno/kyverno/tree/master/samples/best_practices):

````bash
kubectl create -f samples/best_practices
````

Import addition policies from [here](https://github.com/kyverno/kyverno/tree/master/samples/more):

````bash
kubectl create -f samples/more/
````
