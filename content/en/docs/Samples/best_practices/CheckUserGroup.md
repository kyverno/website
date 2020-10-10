
---
title: "Check userID, groupIP & fsgroup"
linkTitle: "Check userID, groupIP & fsgroup"
weight: 4
description: >

---

All processes inside the pod can be made to run with specific user and groupID by setting runAsUser and runAsGroup respectively. fsGroup can be specified to make sure any file created in the volume with have the specified groupID. These options can be used to validate the IDs used for user and group.

This policy matches and mutates pods with `emptyDir` and `hostPath` volumes, to add the `safe-to-evict` annotation if it is not specified.


## Additional Information

## Policy YAML 

````yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: validate-userid-groupid-fsgroup
spec:
  rules:
  - name: validate-userid
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "User ID should be 1000"
      pattern:
        spec:
          securityContext:
            runAsUser: '1000'
  - name: validate-groupid
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Group ID should be 3000"
      pattern:
        spec:
          securityContext:
            runAsGroup: '3000'
  - name: validate-fsgroup
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "fsgroup should be 2000"
      pattern:
        spec:
          securityContext:
            fsGroup: '2000'
````

## Install Policy

```bash
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/samples/best_practices/policy_validate_user_group_fsgroup_id.yaml
```

## Test Policy

