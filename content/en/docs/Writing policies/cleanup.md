---
title: Cleanup
description: Automate the resource cleanup process by using a CleanupPolicy. 
weight: 67
---

Kyverno has the ability to cleanup (i.e., delete) existing resources in a cluster defined in a new policy called a `CleanupPolicy`. Cleanup policies come in both cluster-scoped and Namespaced flavors; a `ClusterCleanupPolicy` being cluster scoped and a `CleanupPolicy` being Namespaced. A cleanup policy uses the familiar `match`/`exclude` block to select and exclude resources which are subjected to the cleanup process. A `conditions{}` block (optional) uses common expressions similar to those found in [preconditions](/docs/writing-policies/preconditions/) and [deny rules](/docs/writing-policies/validate/#deny-rules) to query the contents of the selected resources in order to refine the selection process. And, lastly, a `schedule` field defines, in cron format, when the rule should run.

The cleanup controller runs decoupled from Kyverno in a separate Deployment. Cleanup is executed by a CronJob which is automatically created and managed by the cleanup controller. Each cleanup policy maps to one CronJob. When the scheduled time occurs, the CronJob calls to the cleanup controller to execute the cleanup process defined in the policy.

An example ClusterCleanupPolicy is shown below.

This cleanup policy removes Deployments which have the label `canremove: "true"` if they have less than two replicas on a schedule of every 5 minutes.

```yaml
apiVersion: kyverno.io/v2alpha1
kind: ClusterCleanupPolicy
metadata:
  name: cleandeploy
spec:
  match:
    any:
    - resources:
        kinds:
          - Deployment
        selector:
          matchLabels:
            canremove: "true"
  conditions:
    any:
    - key: "{{ request.object.spec.replicas }}"
      operator: LessThan
      value: 2
  schedule: "*/5 * * * *"
```

Because Kyverno follows the principal of least privilege, it may be necessary to grant the privileges needed in your case to the cleanup controller's ClusterRole. Creation of a (Cluster)CleanupPolicy will cause Kyverno to evaluate the permissions it needs and will warn if they are insufficient to successfully execute the desired cleanup.

```sh
Error from server: error when creating "ncleanpol.yaml": admission webhook "kyverno-cleanup-controller.kyverno.svc" denied the request: cleanup controller has no permission to delete kind Ingress
```

{{% alert title="Warning" color="warning" %}}
Be mindful of the validate policies in `enforce` mode in your cluster as the CronJobs and their spawned Jobs/Pods may be subjected to and potentially blocked. You may wish to exclude based on the label `app.kubernetes.io/managed-by`.
{{% /alert %}}

As cleanup policies are either updated or removed, the CronJobs are updated accordingly.
