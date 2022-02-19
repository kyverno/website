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

Either delete the Kyverno Pods or scale the Deployment down to zero and then up. For example, for an installation with three replicas use:

```sh
kubectl scale deploy kyverno -n kyverno --replicas 0
kubectl scale deploy kyverno -n kyverno --replicas 3
```

3. Consider excluding namespaces

Use [Namespace selectors](/docs/installation/#namespace-selectors) to filter requests to system Namespaces. Note that this configuration bypasses all policy checks on select Namespaces, and may violate security best practices.

## Policies not applied

**Symptom**: My policies are created but nothing seems to happen when I create a resource that should trigger them.

**Solution**: There are a few moving parts that need to be checked to ensure Kyverno is receiving information from Kubernetes and is in good health.

1. Check and ensure the Kyverno Pod(s) are running. Assuming Kyverno was installed into the default Namespace of `kyverno`, use the command `kubectl -n kyverno get po` to check their status. The status should be `Running` at all times.
2. Kyverno registers as two types of webhooks with Kubernetes. Check the status of registered webhooks to ensure Kyverno is among them.

   ```sh
   $ kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations
    NAME                                                                                                  WEBHOOKS   AGE
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-policy-validating-webhook-cfg     1          46m
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-resource-validating-webhook-cfg   1          46m

    NAME                                                                                              WEBHOOKS   AGE
    mutatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-policy-mutating-webhook-cfg     1          46m
    mutatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-resource-mutating-webhook-cfg   1          46m
    mutatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-verify-mutating-webhook-cfg     1          46m
    ```

    The age should be consistent with the age of the currently running Kyverno Pod(s). If the age of these webhooks shows, for example, a few seconds old, Kyverno may be having trouble registering with Kubernetes.

3. Test that name resolution and connectivity to the Kyverno service works inside your cluster by starting a simple `busybox` Pod and trying to connect to Kyverno. Enter the `wget` command as shown below. If the response is not "remote file exists" then there is a network connectivity or DNS issue within your cluster. If your cluster was provisioned with [kubespray](https://github.com/kubernetes-sigs/kubespray), see if [this comment](https://github.com/jetstack/cert-manager/issues/2640#issuecomment-601872165) helps you.

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

4. For `validate` policies, ensure that `validationFailureAction` is set to `enforce` if your expectation is that applicable resources should be blocked. Most policies in the samples library are purposefully set to `audit` mode so they don't have any unintended consequences for new users. It could be that, if the prior steps check out, Kyverno is working fine only that your policy is configured to not immediately block resources.

5. Check and ensure you aren't creating a resource that is either excluded from Kyverno's processing by default, or that it hasn't been created in an excluded Namespace. Kyverno uses a ConfigMap by default called `kyverno` in the Kyverno Namespace to filter out some of these things. The key name is `resourceFilters` and more details can be found [here](/docs/installation/#resource-filters).

## Kyverno consumes a lot of resources

**Symptom**: Kyverno is using too much memory or CPU. How can I understand what is causing this?

**Solution**: Follow the steps on the [Kyverno wiki](https://github.com/kyverno/kyverno/wiki/Profiling-Kyverno-on-Kubernetes) for enabling memory and CPU profiling. Additionally, gather how many ConfigMap and Secret resources exist in your cluster by running the following command:

```sh
kubectl get cm,secret -A | wc -l
```

After gathering this information, [create an issue](https://github.com/kyverno/kyverno/issues/new/choose) in the Kyverno GitHub repository and reference it.

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

**Symptom**: I'm an EKS user and I'm finding that resources that should be blocked by a Kyverno policy are not.

**Solution**: When using EKS with a custom CNI, the Kyverno webhook cannot be reached by the API server because the control plane nodes, which cannot use a custom CNI, differ from the configuration of the worker nodes, which can. In order to resolve this, when installing Kyverno via Helm, set the `hostNetwork` option to `true`. See also [this note](https://cert-manager.io/docs/installation/compatibility/#aws-eks).
