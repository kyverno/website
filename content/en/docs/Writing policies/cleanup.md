---
title: Cleanup Rules
description: >
  Remove Kubernetes resources. 
weight: 70
---

{{% alert title="Warning" color="warning" %}}
Cleanup policies are an **alpha** feature. It is not ready for production usage and there may be breaking changes. Normal semantic versioning and compatibility rules will not apply.
{{% /alert %}}

Kyverno has the ability to cleanup (i.e., delete) existing resources in a cluster defined in a new policy called a `CleanupPolicy`. Cleanup policies come in both cluster-scoped and Namespaced flavors; a `ClusterCleanupPolicy` being cluster scoped and a `CleanupPolicy` being Namespaced. A cleanup policy uses the familiar `match`/`exclude` block to select and exclude resources which are subjected to the cleanup process. A `conditions{}` block (optional) uses common expressions similar to those found in [preconditions](/docs/writing-policies/preconditions/) and [deny rules](/docs/writing-policies/validate/#deny-rules) to query the contents of the selected resources in order to refine the selection process. And, lastly, a `schedule` field defines, in cron format, when the rule should run.

{{% alert title="Note" color="info" %}}
Since cleanup policies always operate against existing resources in a cluster, policies created with `subjects`, `Roles`, or `ClusterRoles` in the `match`/`exclude` block are not allowed since this information is only known at admission time.
{{% /alert %}}

The cleanup controller runs decoupled from Kyverno in a separate Deployment. Cleanup is executed by a CronJob which is automatically created and managed by the cleanup controller. Each cleanup policy maps to one CronJob. When the scheduled time occurs, the CronJob calls to the cleanup controller to execute the cleanup process defined in the policy. As cleanup policies are either updated or removed, the CronJobs are updated accordingly.

An example ClusterCleanupPolicy is shown below. This cleanup policy removes Deployments which have the label `canremove: "true"` if they have less than two replicas on a schedule of every 5 minutes.

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
    - key: "{{ target.spec.replicas }}"
      operator: LessThan
      value: 2
  schedule: "*/5 * * * *"
```

Values from resources to be evaluated during a policy may be referenced with `target.*` similar to [mutate existing rules](/docs/writing-policies/mutate/#mutate-existing-resources).

Because Kyverno follows the principal of least privilege, depending on the resources you wish to remove it may be necessary to grant additional permissions to the cleanup controller. Kyverno will assist in informing you if additional permissions are required by validating them at the time a new cleanup policy is installed. See the [Customizing Permissions](http://localhost:1313/docs/installation/customization/#customizing-permissions) section for more details.

{{% alert title="Warning" color="warning" %}}
Be mindful of the validate policies in `Enforce` mode in your cluster as the CronJobs and their spawned Jobs/Pods may be subjected to and potentially blocked. You may wish to exclude based on the label `app.kubernetes.io/managed-by`.
{{% /alert %}}
