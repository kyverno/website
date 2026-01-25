---
title: 'Policies Not Applied'
linkTitle: 'Policies Not Applied'
description: >
  Troubleshoot and fix issues where Kyverno policies are not applied.
weight: 20
---

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
    NAME                                                                                                        WEBHOOKS       AGE
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-cleanup-validating-webhook-cfg             1          5d21h
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-policy-validating-webhook-cfg              1          5d21h
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-exception-validating-webhook-cfg           1          5d21h
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-resource-validating-webhook-cfg            1          5d21h
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-global-context-validating-webhook-cfg      1          5d21h
    validatingwebhookconfiguration.admissionregistration.k8s.io/kyverno-ttl-validating-webhook-cfg                 1          5d21h

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

6. Check and ensure you aren't creating a resource that is either excluded from Kyverno's processing by default, or that it hasn't been created in an excluded Namespace. Kyverno uses a ConfigMap by default called `kyverno` in the Kyverno Namespace to filter out some of these things. The key name is `resourceFilters` and more details can be found [here](/docs/installation/customization#resource-filters).

7. Check the same ConfigMap and ensure that the user/principal or group responsible for submission of your resource is not being excluded. Check the `excludeGroups` and `excludeUsernames` and others if they exist.
