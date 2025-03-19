---
title: Troubleshooting 
description: Processes for troubleshooting and recovery of Kyverno.
weight: 110
---

Although Kyverno's goal is to make policy simple, sometimes trouble still strikes. The following sections can be used to help troubleshoot and recover when things go wrong.

## API server is blocked

**Symptom**: Kyverno Pods are not running and the API server is timing out due to webhook timeouts. My cluster appears "broken".

**Cause**: This can happen if all Kyverno Pods are down, due typically to a cluster outage or improper scaling/killing of full node groups, and policies were configure to [fail-closed](/docs/policy_types/cluster_policy/policy-settings.md) while matching on Pods. This is usually only the case when the Kyverno Namespace has not been excluded (not the default behavior) or potentially system Namespaces which have cluster-critical components such as `kube-system`.

**Solution**: Delete the Kyverno validating and mutating webhook configurations. When Kyverno recovers, check your Namespace exclusions. Follow the steps below. Also consider running the admission controller component with 3 replicas.

1. Delete the validating and mutating webhook configurations that instruct the API server to forward requests to Kyverno:

```sh
kubectl delete validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg
kubectl delete  mutatingwebhookconfiguration kyverno-resource-mutating-webhook-cfg
```

Note that these two webhook configurations are used for resources. Other Kyverno webhooks are for internal operations and typically do not need to be deleted. When Kyverno recovers, its webhooks will be recreated based on the currently-installed policies.

2. Restart Kyverno

This step is typically not necessary. In case it is, either delete the Kyverno Pods or scale the Deployment down to zero and then up. For example, for an installation with three replicas in the default Namespace use:

```sh
kubectl scale deploy kyverno-admission-controller -n kyverno --replicas 0
kubectl scale deploy kyverno-admission-controller -n kyverno --replicas 3
```

3. Consider excluding namespaces

Use [Namespace selectors](/docs/installation/customization.md#namespace-selectors) to filter requests to system Namespaces. Note that this configuration bypasses all policy checks on select Namespaces and may violate security best practices. When excluding Namespaces, it is your responsibility to ensure other controls such as Kubernetes RBAC are configured since Kyverno cannot apply any policies to objects therein. For more information, see the [Security vs Operability](/docs/installation/_index.md#security-vs-operability) section. The Kyverno Namespace is excluded by default. And if running Kyverno on certain PaaS platforms, additional Namespaces may need to be excluded as well, for example `kube-system`.

## Policies are not applied

**Symptom**: My policies are created but nothing seems to happen when I create a resource that should trigger them.

**Solution**: There are a few moving parts that need to be checked to ensure Kyverno is receiving information from Kubernetes and is in good health.

1. Check and ensure the Kyverno Pod(s) are running. Assuming Kyverno was installed into the default Namespace of `kyverno`, use the command `kubectl -n kyverno get po` to check their status. The status should be `Running` at all times.
2. Check all the policies installed in the cluster to ensure they are all reporting `true` under the `READY` column.

    ```sh
    $ kubectl get cpol,pol -A
    NAME                BACKGROUND   VALIDATE ACTION   READY   AGE   MESSAGE
    inject-entrypoint   true         Audit             True    15s   Ready
    ```

3. Kyverno registers as two types of webhooks with Kubernetes. Check the status of registered webhooks to ensure Kyverno is among them.

   ```sh
   $ kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations
    NAME                                                                                                   WEBHOOKS   AGE
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-cleanup-validating-webhook-cfg     1          5d21h
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-policy-validating-webhook-cfg      1          5d21h
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-exception-validating-webhook-cfg   1          5d21h
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-resource-validating-webhook-cfg    1          5d21h

    NAME                                                                                              WEBHOOKS   AGE
    mutatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-policy-mutating-webhook-cfg     1          5d21h
    mutatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-verify-mutating-webhook-cfg     1          5d21h
    mutatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-resource-mutating-webhook-cfg   1          5d21h
    ```

    The age should be consistent with the age of the currently running Kyverno Pod(s). If the age of these webhooks shows, for example, a few seconds old, Kyverno may be having trouble registering with Kubernetes.

4. Test that name resolution and connectivity to the Kyverno service works inside your cluster by starting a simple `busybox` Pod and trying to connect to Kyverno. Enter the `wget` command as shown below. If the response is not "remote file exists" then there is a network connectivity or DNS issue within your cluster. If your cluster was provisioned with [kubespray](https://github.com/kubernetes-sigs/kubespray), see if [this comment](https://github.com/jetstack/cert-manager/issues/2640#issuecomment-601872165) helps you.

    ```sh
    $ kubectl run busybox --rm -ti --image=busybox -- /bin/sh
    If you don't see a command prompt, try pressing enter.
    / # wget --no-check-certificate --spider --timeout=1 https://kyverno-svc.kyverno.svc:443/health/liveness
    Connecting to kyverno-svc.kyverno.svc:443 (100.67.141.176:443)
    remote file exists
    / # exit
    Session ended, resume using 'kubectl attach busybox -c busybox -i -t' command when the pod is running
    pod "busybox" deleted
    ```

5. For `validate` policies, ensure that `failureAction` is set to `Enforce` if your expectation is that applicable resources should be blocked. Most policies in the samples library are purposefully set to `Audit` mode so they don't have any unintended consequences for new users. It could be that, if the prior steps check out, Kyverno is working fine only that your policy is configured to not immediately block resources.

6. Check and ensure you aren't creating a resource that is either excluded from Kyverno's processing by default, or that it hasn't been created in an excluded Namespace. Kyverno uses a ConfigMap by default called `kyverno` in the Kyverno Namespace to filter out some of these things. The key name is `resourceFilters` and more details can be found [here](/docs/installation/customization.md#resource-filters).

7. Check the same ConfigMap and ensure that the user/principal or group responsible for submission of your resource is not being excluded. Check the `excludeGroups` and `excludeUsernames` and others if they exist.

## Kyverno consumes a lot of resources or I see OOMKills

**Symptom**: Kyverno is using too much memory or CPU. How can I understand what is causing this?

**Solution**: It is important to understand how Kyverno experiences and processes work to determine if what you deem as "too much" is, in fact, too much. Kyverno dynamically configures its webhooks (by default but configurable) according the policies which are loaded and on what resources they match. There is no straightforward formula where resource requirements are directly proportional to, for example, number of Pods or Nodes in a cluster. The following questions need to be asked and answered to build a full picture of the resources consumed by Kyverno.

1. What policies are in the cluster and on what types of resources do they match? Policies which match on wildcards (`"*"`) cause a tremendous load on Kyverno and should be avoided if possible as they instruct the Kubernetes API server to send to Kyverno _every action on every resource_ in the cluster. Even if Kyverno does not have matching policies for most of these resources, it is _required_ to respond to every single one. If even one policy matches on a wildcard, expect the resources needed by Kyverno to easily double, triple, or more.
2. Which controller is experiencing the load? Each Kyverno controller has different responsibilities. See the [controller guide](../high-availability/_index.md#controllers-in-kyverno) for more details. Each controller can be independently scaled, but before immediately scaling in any direction take the time to study the load.
3. Are the default requests and limits still in effect? It is possible the amount of load Kyverno (any of its controllers) is experiencing is beyond the capabilities of the default requests and limits. These defaults have been selected based on a good mix of real-world usage and feedback but **may not suit everyone**. In extremely large and active clusters, from Kyverno's perspective, you may need to increase these.
4. What do your monitoring metrics say? Kyverno is a critical piece of cluster infrastructure and must be monitored effectively just like other pieces. There are several metrics which give a sense of how active Kyverno is, the most important being [admission request count](../monitoring/admission-requests.md). Others include consumed memory and CPU utilization. Sizing should always be done based on peak consumption and not averages.
5. Have you checked the number of pending update requests when using generate or mutate existing rules? In addition to the admission request count metric, you can use `kubectl -n kyverno get updaterequests` to get a sense of the request count. If there are many requests in a `Pending` status this could be a sign of a permissions issue or, for clone-type generate rules with synchronization enabled, excessive updates to the source resource. Ensure you grant the background controller the required permissions to the resources and operations it needs, and ensure Kyverno is able to label clone sources.

You can also follow the steps on the [Kyverno wiki](https://github.com/kyverno/kyverno/wiki/Profiling-Kyverno-on-Kubernetes) for enabling memory and CPU profiling.

**Symptom**: I'm using AKS and Kyverno is using too much memory or CPU or produces many audit logs

**Solution**: On AKS the Kyverno webhooks will be mutated by the AKS [Admissions Enforcer](https://learn.microsoft.com/en-us/azure/aks/faq#can-admission-controller-webhooks-impact-kube-system-and-internal-aks-namespaces) plugin, that can lead to an endless update loop. To prevent that behavior, set the annotation `"admissions.enforcer/disabled": true` to all Kyverno webhooks. When installing via Helm, the annotation can be added with `config.webhookAnnotations`. As of Kyverno 1.12, this configuration is enabled by default.

## Kyverno is slow to respond

**Symptom**: Kyverno's operation seems slow in either mutating resources or validating them, causing additional time to create resources in the Kubernetes cluster.

**Solution**: Check the Kyverno logs for messages about throttling. If many are found, this indicates Kyverno is making too many API calls in too rapid a succession which the Kubernetes API server will throttle. Increase the values, or set the [flags](/docs/installation/customization.md#container-flags), `--clientRateLimitQPS` and `--clientRateLimitBurst`. While these flags have very sensible values after much field trials, in some cases they may need to be increased.

## Policies are partially applied

**Symptom**: Kyverno is working for some policies but not others. How can I see what's going on?

**Solution**: The first thing is to check the logs from the Kyverno Pod to see if it describes why a policy or rule isn't working.

1. Check the Pod logs from Kyverno. Assuming Kyverno was installed into the default Namespace called `kyverno` use the command `kubectl -n kyverno logs <kyverno_pod_name>` to show the logs. To watch the logs live, add the `-f` switch for the "follow" option.

2. If no helpful information is being displayed at the default logging level, increase the level of verbosity by editing the Kyverno Deployment. To edit the Deployment, assuming Kyverno was installed into the default Namespace, use the command `kubectl -n kyverno edit deploy kyverno-<controller_type>-controller`. Find the `args` section for the container named `kyverno` and either add the `-v` switch or increase to a higher level. The flag `-v=6` will increase the logging level to its highest. Take care to revert this change once troubleshooting steps are concluded.

## Kyverno exits

**Symptom**: I have a large cluster with many objects and many Kyverno policies. Kyverno is seen to sometimes crash.

**Solution**: In cases of very large scale, it may be required to increase the memory limit of the Kyverno Pod so it can keep track of these objects.

1. First, see the [above troubleshooting section](#kyverno-consumes-a-lot-of-resources-or-i-see-oomkills). If changes are required, edit the necessary Kyverno Deployment and increase the memory limit on the container. Change the `resources.limits.memory` field to a larger value. Continue to monitor the memory usage by using something like the [Kubernetes metrics-server](https://github.com/kubernetes-sigs/metrics-server#installation).

## Kyverno fails on GKE

**Symptom**: I'm using GKE and after installing Kyverno, my cluster is either broken or I'm seeing timeouts and other issues.

**Solution**: Private GKE clusters do not allow certain communications from the control planes to the workers, which Kyverno requires to receive webhooks from the API server. In order to resolve this issue, create a firewall rule which allows the control plane to speak to workers on the Kyverno TCP port which, by default at this time, is 9443. For more details, see the [GKE documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters#add_firewall_rules).

## Kyverno fails on EKS

**Symptom**: I'm an EKS user and I'm finding that resources that should be blocked by a Kyverno policy are not. My cluster does not use the VPC CNI.

**Solution**: When using EKS with a custom CNI plug-in (ex., Calico), the Kyverno webhook cannot be reached by the API server because the control plane nodes, which cannot use a custom CNI, differ from the configuration of the worker nodes, which can. In order to resolve this, when installing Kyverno via Helm, set the `hostNetwork` option to `true`. See also [this note](https://cert-manager.io/docs/installation/compatibility/#aws-eks). AWS lists the alternate compatible CNI plug-ins [here](https://docs.aws.amazon.com/eks/latest/userguide/alternate-cni-plugins.html).

**Symptom**: When creating Pods or other resources, I receive similar errors like `Error from server (InternalError): Internal error occurred: failed calling webhook "validate.kyverno.svc-fail": Post "https://kyverno-svc.kyverno.svc:443/validate?timeout=10s": context deadline exceeded`.

**Solution**: When using EKS with the VPC CNI, problems may arise if the CNI plug-in is outdated. Upgrade the VPC CNI plug-in to a version supported and compatible with the Kubernetes version running in the EKS cluster.

If the EKS cluster uses your own security group, some of the network traffic from the control plane to the worker nodes might be blocked (documented [here](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html)). Create an inbound rule in the security group attached to the EKS worker nodes, allowing communication on port 9443 from the EKS cluster security group.

## Client-side throttling

**Symptom**: Kyverno pods emit logs stating `Waited for <n>s due to client-side throttling`; the creation of mutated resources may be delayed.

**Solution**: Try increasing `clientRateLimitBurst` and `clientRateLimitQPS` (documented [here](/docs/installation/customization.md#container-flags)). If that doesn't resolve the problem, you can experiment with slowly increasing these values. Just bear in mind that higher values place more pressure on the Kubernetes API (the client-side throttling was implemented for a reason), which could result in cluster-wide latency, so proceed with caution.

## Policy definition not working

**Symptom**: My policy _seems_ like it should work based on how I have authored it but it doesn't.

**Solution**: There can be many reasons why a policy may fail to work as intended, assuming other policies work. One of the most common reasons is that the API server is sending different contents than what you have accounted for in your policy. To see the full contents of the AdmissionReview request the Kubernetes API server sends to Kyverno, add the `dumpPayload` [container flag](/docs/installation/customization.md#container-flags) set to `true` and check the logs. This has performance impact so it should be removed or set back to `false` when complete.

The second most common reason policies may fail to operate per design is due to variables. To see the values Kyverno is substituting for variables, increase logging to level `4` by setting the container flag `-v=4`. You can `grep` for the string `variable` (or use tools such as [stern](https://github.com/stern/stern)) and only see the values being substituted for those variables.

## Admission reports are stacking up

**Symptom**: Admission reports keep accumulating in the cluster, taking more and more etcd space and slowing down requests.

**Diagnose**: Please follow the [troubleshooting docs](https://github.com/kyverno/kyverno/blob/main/docs/dev/troubleshooting/reports.md) to determine if you are affected by this issue.

**Solution**: Admission reports can accumulate if the reports controller is not working properly so the first thing to check is if the reports controller is running and does not continuously restarts. If the controller works as expected, another potential cause is that it fails to aggregate admission reports fast enough. This usually happens when the controller is throttled. You can fix this by increasing QPS and burst rates for the controller by setting `--clientRateLimitQPS=500` and `--clientRateLimitBurst=500`.
Note that starting with Kyverno 1.10, two cron jobs are responsible for deleting admission reports automatically if they accumulate over a certain threshold.

## Kyverno says it does not have permissions when creating a policy

**Symptom**: Attempting to create a [mutate existing](/docs/policy_types/cluster_policy/mutate.md#mutate-existing-resources) or [generate](/docs/policy_types/cluster_policy/generate.md) policy and Kyverno throws an error similar to the one below:

```
Error from server: error when creating "my_cluster_policy.yaml": admission webhook "validate-policy.kyverno.svc" denied the request: path: spec.rules[0].generate..: system:serviceaccount:kyverno:kyverno-background-controller does not have permissions to 'create' resource source.toolkit.fluxcd.io/v1beta2/helmrepository//{{request.object.metadata.name}}. Grant proper permissions to the background controller
```

**Diagnose**: Use `kubectl` to assess whether the Kyverno background controller has the necessary permissions: `kubectl auth can-i create helmrepositories --as system:serviceaccount:kyverno:kyverno-background-controller`. If the response you get from this command is "no" then Kyverno will also receive the same.

**Solution**: The background controller processes all mutations on existing resources and generations. It ships with only a minimal set of permissions. Any additional permissions are up to the user to add. Kyverno performs permissions checks upon creation/update of policies processed by the background controller. If the required permissions are not found, the operation is prevented. This is to ensure a good user experience is maintained. See the page on customizing permissions [here](/docs/installation/customization.md#customizing-permissions) for instructions on how to easily add the permissions you require. If you have done this and still cannot proceed, likely causes include you targeting the wrong controller, one or more labels is wrong causing aggregation to not occur, or the permissions you have defined in the (Cluster)Role are incorrect (ex., specifying the resource name(s) using their singular form rather than plural). Fix the issues and re-run the `kubectl auth` command. Until it returns with a "yes" the permissions are not correct.
