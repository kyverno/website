---
date: 2023-09-04
title: "Applying Validating Admission Policies using Kyverno CLI"
linkTitle: "Applying Validating Admission Policies using Kyverno CLI"
author: Mariam Fahmy
description: "Using Kyverno CLI to apply Validating Admission Policies"
---
The [Kyverno Command Line Interface (CLI)](https://kyverno.io/docs/kyverno-cli/) is designed to validate and test policy behavior to resources prior to adding them to a cluster.

One of the Kyverno CLI commands are apply and test commands.

1. The apply command is used to perform a dry run on one or more policies for the given manifest(s).
2. The test command is used to test a given set of resources against one or more policies to check the desired results.

Kyverno CLI now can be used to apply/test Kubernetes Validating Admission Policies that were first introduced in 1.26.

## Applying Validating Admission Policies using Kyverno apply
In this section, you will create a validating admission policy that checks the number of deployment replicas. You will then apply this policy to two deployments, one of which violates the policy:

```sh
cat << EOF > check-deployment-replicas.yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicy
metadata:
  name: check-deployments-replicas
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 2"
      message: "Replicas must be less than or equal 2"
EOF
```

The following deployment satisfies the rules declared in the above policy:
```sh
cat << EOF > deployment-pass.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-pass
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-pass
  template:
    metadata:
      labels:
        app: nginx-pass
    spec:
      containers:
      - name: nginx-server
        image: nginx
EOF
```

Let's apply the policy on the resource using kyverno apply as follows:
```sh
kyverno apply ./check-deployment-replicas.yaml --resource deployment-pass.yaml

Applying 1 policy rule(s) to 1 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 
```

Let's try to create another deployment that violates the policy:
```sh
cat << EOF > deployment-fail.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-fail
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-fail
  template:
    metadata:
      labels:
        app: nginx-fail
    spec:
      containers:
      - name: nginx-server
        image: nginx
EOF
```

Then apply the policy on the resource as follows:
```sh
kyverno apply ./check-deployment-replicas.yaml --resource deployment-fail.yaml 

Applying 1 policy rule(s) to 1 resource(s)...

pass: 0, fail: 1, warn: 0, error: 0, skip: 0
```

## Testing Validating Admission Policies using Kyverno test
In this section, you will create a validating admission policy that ensures no `hostPath` volumes are in use for deployments. You will then create two deployments to test them aganist the policy and check the desired results. 
To proceed, you need to create a directory containing the necessary manifests. In this example, I created a directory called `test-dir`.

Let's start with creating the policy:
```sh
cat << EOF > ./test-dir/disallow-host-path.yaml
apiVersion: admissionregistration.k8s.io/v1alpha1
kind: ValidatingAdmissionPolicy
metadata:
  name: disallow-host-path
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
    - apiGroups:   ["apps"]
      apiVersions: ["v1"]
      operations:  ["CREATE", "UPDATE"]
      resources:   ["deployments"]
  validations:
    - expression: "!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))"
      message: "HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset."
EOF
```

Then create the two deployments, one of which violates the policy:
```sh
cat << EOF > ./test-dir/deployments.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-pass
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
        volumeMounts:
          - name: temp
            mountPath: /scratch
      volumes:
      - name: temp
        emptyDir: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-fail
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
        volumeMounts:
          - name: udev
            mountPath: /data
      volumes:
      - name: udev
        hostPath:
          path: /etc/udev
EOF
```

The tests are written in a file name `kyverno-test.yaml` so you will create two tests, one for each deployment and test them aganist the policy.
```sh
cat << EOF > ./test-dir/kyverno-test.yaml
name: disallow-host-path-test
policies:
  - disallow-host-path.yaml
resources:
  - deployments.yaml
results:
  - policy: disallow-host-path
    resource: deployment-pass
    isValidatingAdmissionPolicy: true
    kind: Deployment
    result: pass
  - policy: disallow-host-path
    resource: deployment-fail
    isValidatingAdmissionPolicy: true
    kind: Deployment
    result: fail
EOF
```
Now, we’re ready to test the two deployments aganist validating admission policy.
```sh
kyverno test ./test-dir

Executing disallow-host-path-test...

│────│────────────────────│──────│────────────────────────────│────────│────────│
│ ID │ POLICY             │ RULE │ RESOURCE                   │ RESULT │ REASON │
│────│────────────────────│──────│────────────────────────────│────────│────────│
│  1 │ disallow-host-path │      │ Deployment/deployment-pass │ Pass   │ Ok     │
│  2 │ disallow-host-path │      │ Deployment/deployment-fail │ Pass   │ Ok     │
│────│────────────────────│──────│────────────────────────────│────────│────────│

Test Summary: 2 tests passed and 0 tests failed
```
As expected, the two tests passed because the actual result of each test matches the desired result as defined in the test manifest.

## Conclusion
This blog post explains how to apply validating admission policies to resources using Kyverno CLI.
