---
title: Troubleshooting 
description: Processes for troubleshooting and recovery of Kyverno.
weight: 110
---

Although Kyverno's goal is to make policy simple, sometimes trouble still strikes. The following sections can be used to help troubleshoot and recover when things go wrong.

## API server is blocked

**Symptom**: Kyverno Pods are not running and the API server is timing out due to webhook timeouts. This can happen if the Kyverno Pods are not gracefully terminated, or if there is a cluster outage, and policies were configure to [fail-closed](/docs/writing-policies/policy-settings/).

**Solution**: Delete the Kyverno validating and mutating webhook configurations and then restart Kyverno.

1. Delete the validating and mutating webhook configurations that instruct the API server to forward requests to Kyverno:

```sh
kubectl delete validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg
kubectl delete  mutatingwebhookconfiguration kyverno-resource-mutating-webhook-cfg
```

Note that these two webhook configurations are used for resources. Other Kyverno webhooks are for internal operations and typically do not need to be deleted.

2. Restart Kyverno

Either delete the Kyverno Pods or scale the Deployment down to zero and then up. For example, for an installation with three replicas in the default Namespace use:

```sh
kubectl scale deploy kyverno -n kyverno --replicas 0
kubectl scale deploy kyverno -n kyverno --replicas 3
```

3. Consider excluding namespaces

Use [Namespace selectors](/docs/installation/#namespace-selectors) to filter requests to system Namespaces. Note that this configuration bypasses all policy checks on select Namespaces and may violate security best practices. When excluding Namespaces, it is the user's responsibility to ensure other controls such as Kubernetes RBAC are configured since Kyverno cannot apply any policies to objects therein. For more information, see the [Security vs Operability](/docs/installation/#security-vs-operability) section. The Kyverno Namespace is excluded by default.

## Policies not applied

**Symptom**: My policies are created but nothing seems to happen when I create a resource that should trigger them.

**Solution**: There are a few moving parts that need to be checked to ensure Kyverno is receiving information from Kubernetes and is in good health.

1. Check and ensure the Kyverno Pod(s) are running. Assuming Kyverno was installed into the default Namespace of `kyverno`, use the command `kubectl -n kyverno get po` to check their status. The status should be `Running` at all times.
2. Check all the policies installed in the cluster to ensure they are all reporting `true` under the `READY` column.

    ```sh
    $ kubectl get cpol,pol -A
    NAME                                           BACKGROUND   VALIDATE ACTION   READY   AGE
    clusterpolicy.kyverno.io/check-image-keyless   true         Enforce           true    116s
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

5. For `validate` policies, ensure that `validationFailureAction` is set to `Enforce` if your expectation is that applicable resources should be blocked. Most policies in the samples library are purposefully set to `Audit` mode so they don't have any unintended consequences for new users. It could be that, if the prior steps check out, Kyverno is working fine only that your policy is configured to not immediately block resources.

6. Check and ensure you aren't creating a resource that is either excluded from Kyverno's processing by default, or that it hasn't been created in an excluded Namespace. Kyverno uses a ConfigMap by default called `kyverno` in the Kyverno Namespace to filter out some of these things. The key name is `resourceFilters` and more details can be found [here](/docs/installation/#resource-filters).

## Kyverno consumes a lot of resources

**Symptom**: Kyverno is using too much memory or CPU. How can I understand what is causing this?

**Solution**: Follow the steps on the [Kyverno wiki](https://github.com/kyverno/kyverno/wiki/Profiling-Kyverno-on-Kubernetes) for enabling memory and CPU profiling. Additionally, gather how many ConfigMap and Secret resources exist in your cluster by running the following command:

```sh
kubectl get cm,secret -A | wc -l
```

After gathering this information, [create an issue](https://github.com/kyverno/kyverno/issues/new/choose) in the Kyverno GitHub repository and reference it.

**Symptom**: I'm using AKS and Kyverno is using too much memory or CPU

**Solution**: On AKS the kyverno webhooks will be mutated by the AKS [Admissions Enforcer](https://learn.microsoft.com/en-us/azure/aks/faq#can-admission-controller-webhooks-impact-kube-system-and-internal-aks-namespaces) Plugin, that can lead to an endless update loop. To prevent that behaviour, you can set the annotation `"admissions.enforcer/disabled": true` to all kyverno webhooks. When installing via Helm, you can add the annotation with `config.webhookAnnotations`.

## Kyverno is slow to respond

**Symptom**: Kyverno's operation seems slow in either mutating resources or validating them, causing additional time to create resources in the Kubernetes cluster.

**Solution**: Check the Kyverno logs for messages about throttling. If many are found, this indicates Kyverno is making too many API calls in too rapid a succession which the Kubernetes API server will throttle. Increase the values, or set the [flags](/docs/installation/#container-flags), `--clientRateLimitQPS` and `--clientRateLimitBurst`. Try values `100` for each and increase as needed.

## Policies are partially applied

**Symptom**: Kyverno is working for some policies but not others. How can I see what's going on?

**Solution**: The first thing is to check the logs from the Kyverno Pod to see if it describes why a policy or rule isn't working.

1. Check the Pod logs from Kyverno. Assuming Kyverno was installed into the default Namespace called `kyverno` use the command `kubectl -n kyverno logs <kyverno_pod_name>` to show the logs. To watch the logs live, add the `-f` switch for the "follow" option.

2. If no helpful information is being displayed at the default logging level, increase the level of verbosity by editing the Kyverno Deployment. To edit the Deployment, assuming Kyverno was installed into the default Namespace, use the command `kubectl -n kyverno edit deploy kyverno`. Find the `args` section for the container named `kyverno` and either add the `-v` switch or increase to a higher level. The flag `-v=6` will increase the logging level to its highest. Take care to revert this change once troubleshooting steps are concluded.

## Kyverno exits

**Symptom**: I have a large cluster with many objects and many Kyverno policies. Kyverno is seen to sometimes crash.

**Solution**: In cases of very large scale, it may be required to increase the memory limit of the Kyverno Pod so it can keep track of these objects.

1. Edit the Kyverno Deployment and increase the memory limit on the `kyverno` container by using the command `kubectl -n kyverno edit deploy kyverno`. Change the `resources.limits.memory` field to a larger value. Continue to monitor the memory usage by using something like the [Kubernetes metrics-server](https://github.com/kubernetes-sigs/metrics-server#installation).

## Kyverno fails on GKE

**Symptom**: I'm using GKE and after installing Kyverno, my cluster is either broken or I'm seeing timeouts and other issues.

**Solution**: Private GKE clusters do not allow certain communications from the control planes to the workers, which Kyverno requires to receive webhooks from the API server. In order to resolve this issue, create a firewall rule which allows the control plane to speak to workers on the Kyverno TCP port which, by default at this time, is 9443.

## Kyverno fails on EKS

**Symptom**: I'm an EKS user and I'm finding that resources that should be blocked by a Kyverno policy are not. My cluster does not use the VPC CNI.

**Solution**: When using EKS with a custom CNI plug-in (ex., Calico), the Kyverno webhook cannot be reached by the API server because the control plane nodes, which cannot use a custom CNI, differ from the configuration of the worker nodes, which can. In order to resolve this, when installing Kyverno via Helm, set the `hostNetwork` option to `true`. See also [this note](https://cert-manager.io/docs/installation/compatibility/#aws-eks). AWS lists the alternate compatible CNI plug-ins [here](https://docs.aws.amazon.com/eks/latest/userguide/alternate-cni-plugins.html).

**Symptom**: When creating Pods or other resources, I receive similar errors like `Error from server (InternalError): Internal error occurred: failed calling webhook "validate.kyverno.svc-fail": Post "https://kyverno-svc.kyverno.svc:443/validate?timeout=10s": context deadline exceeded`.

**Solution**: When using EKS with the VPC CNI, problems may arise if the CNI plug-in is outdated. Upgrade the VPC CNI plug-in to a version supported and compatible with the Kubernetes version running in the EKS cluster.

## Client-side throttling

**Symptom**: Kyverno pods emit logs stating `Waited for <n>s due to client-side throttling`; the creation of mutated resources may be delayed.

**Solution**: Try increasing `clientRateLimitBurst` and `clientRateLimitQPS` (documented [here](https://kyverno.io/docs/installation/)) to `100` to begin with. If that doesn't resolve the problem, you can experiment with slowly increasing these values. Just bear in mind that higher values place more pressure on the Kubernetes API (the client-side throttling was implemented for a reason), which could result in cluster-wide latency, so proceed with caution.

## Policy definition not working

**Symptom**: My policy _seems_ like it should work based on how I have authored it but it doesn't.

**Solution**: There can be many reasons why a policy may fail to work as intended, assuming other policies work. One of the most common reasons is that the API server is sending different contents than what you have accounted for in your policy. To see the full contents of the AdmissionReview request the Kubernetes API server sends to Kyverno, add the `dumpPayload` [container flag](/docs/installation/#container-flags) set to `true` and check the logs. This has performance impact so it should be removed or set back to `false` when complete.

The second most common reason policies may fail to operate per design is due to variables. To see the values Kyverno is substituting for variables, increase logging to level `4` by setting the container flag `-v=4`. You can `grep` for the string `variable` (or use tools such as [stern](https://github.com/stern/stern)) and only see the values being substituted for those variables.
