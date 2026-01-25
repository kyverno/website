---
title: 'Kyverno Lacks Permissions'
weight: 140
description: >
  Troubleshoot and fix Kyverno's permission issues during policy creation
---

**Symptom**: Attempting to create a [mutate existing](/docs/policy-types/cluster-policy/mutate#mutate-existing-resources) or [generate](/docs/policy-types/cluster-policy/generate) policy and Kyverno throws an error similar to the one below:

```
Error from server: error when creating "my_cluster_policy.yaml": admission webhook "validate-policy.kyverno.svc" denied the request: path: spec.rules[0].generate..: system:serviceaccount:kyverno:kyverno-background-controller does not have permissions to 'create' resource source.toolkit.fluxcd.io/v1beta2/helmrepository//{{request.object.metadata.name}}. Grant proper permissions to the background controller
```

**Diagnose**: Use `kubectl` to assess whether the Kyverno background controller has the necessary permissions: `kubectl auth can-i create helmrepositories --as system:serviceaccount:kyverno:kyverno-background-controller`. If the response you get from this command is "no" then Kyverno will also receive the same.

**Solution**: The background controller processes all mutations on existing resources and generations. It ships with only a minimal set of permissions. Any additional permissions are up to the user to add. Kyverno performs permissions checks upon creation/update of policies processed by the background controller. If the required permissions are not found, the operation is prevented. This is to ensure a good user experience is maintained. See the page on customizing permissions [here](/docs/installation/customization#customizing-permissions) for instructions on how to easily add the permissions you require. If you have done this and still cannot proceed, likely causes include you targeting the wrong controller, one or more labels is wrong causing aggregation to not occur, or the permissions you have defined in the (Cluster)Role are incorrect (ex., specifying the resource name(s) using their singular form rather than plural). Fix the issues and re-run the `kubectl auth` command. Until it returns with a "yes" the permissions are not correct.
