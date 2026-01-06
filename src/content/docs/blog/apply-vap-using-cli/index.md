---
date: 2023-10-04
title: Applying Validating Admission Policies using Kyverno CLI
tags:
  - General
author: Mariam Fahmy
description: Using Kyverno CLI to apply Validating Admission Policies
---

The [Kyverno Command Line Interface (CLI)](/docs/kyverno-cli/) allows applying policies outside of Kubernetes clusters and can validate and test policy behavior prior to adding them to a cluster.

The two commands used for testing are `apply` and `test`:

- The `apply` command is used to perform a dry run on one or more policies for the given manifest(s).
- The `test` command is used to test a given set of resources against one or more policies to check the desired results defined in a special test manifest.

In this post, I will show you how you can apply/test Kubernetes ValidatingAdmissionPolicies that were first [introduced in 1.26](https://kubernetes.io/blog/2022/12/20/validating-admission-policies-alpha/) with the enhancements to the Kyverno CLI in v1.11.

## Applying ValidatingAdmissionPolicies using kyverno apply

In this section, you will create a ValidatingAdmissionPolicy that checks the number of Deployment replicas. You will then apply this policy to two Deployments, one of which violates the policy:

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

The following deployment satisfies the rules declared in the above policy.

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

Let's apply the policy to the resource using `kyverno apply` as follows.

```sh
kyverno apply ./check-deployment-replicas.yaml --resource deployment-pass.yaml
```

The output should be the following.

```sh
Applying 1 policy rule(s) to 1 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0
```

Let's try to create another deployment that violates the policy.

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

Then apply the policy to the resource as follows.

```sh
kyverno apply ./check-deployment-replicas.yaml --resource deployment-fail.yaml
```

The output should be as shown.

```sh
Applying 1 policy rule(s) to 1 resource(s)...

pass: 0, fail: 1, warn: 0, error: 0, skip: 0
```

## Testing ValidatingAdmissionPolicies using kyverno test

In this section, you will create a ValidatingAdmissionPolicy that ensures no `hostPath` volumes are in use for Deployments. You will then create two Deployments to test them against the policy and check the desired results.

To proceed, you need to create a directory containing the necessary manifests. In this example, I created a directory called `test-dir`.

Let's start with creating the policy.

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

Then, create the two Deployments, one of which violates the policy.

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

The tests are defined in a file named `kyverno-test.yaml` so you will create two tests, one for each Deployment and test them against the policy. Notice the use of a new field in the test manifest called `isValidatingAdmissionPolicy`.

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

Now, we’re ready to test the two Deployments against a ValidatingAdmissionPolicy.

```sh
kyverno test ./test-dir
```

The output should be as shown below.

```sh
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

This blog post explains how to apply ValidatingAdmissionPolicies to resources using the Kyverno CLI. With Kyverno, it's easy to apply Kubernetes ValidatingAdmissionPolicies in your CI/CD pipelines and to test new ValidatingAdmissionPolicies before they are deployed to your clusters. This is one of many exciting features coming with Kyverno v1.11.
