---
date: 2023-12-12
title: Kyverno Chainsaw - The ultimate end to end testing tool!
linkTitle: Kyverno Chainsaw - The ultimate end to end testing tool
description: Have fun testing Kubernetes operators!.
draft: false
---

Creating Kubernetes operators is hard, testing Kubernetes operators is also hard.
Of course creating, maintaining and testing a Kubernetes operator is even harder.

It often requires writing and maintaining additional code to get proper end to end testing, it takes time, is a cumbersome process, and making changes becomes a pain.
All this often leads to poor operator testing and can impact the operator quality.

Today we are extremely proud to release the first stable version of Kyverno Chainsaw, a tool to make end to end testing Kubernetes operators entirely declarative, simple and almost fun.

In this blog post, we will introduce [Chainsaw](https://github.com/kyverno/chainsaw), how it works, and what problems it is solving.
Hopefully after reading it you will never consider writing end to end tests the same !

## What are Kubernetes operators ?

Kubernetes operators are described in this [Kubernetes documentation page](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/).

> Operators are software extensions to Kubernetes that make use of custom resources to manage applications and their components. Operators follow Kubernetes principles, notably the control loop.

They often rely on Custom Resource Definitions and continuously reconcile the cluster state with the spec of Custom Resources.

## How do we test a Kubernetes operator ?

An operator is essentially responsible for watching certain resources in a cluster and react to maintain a state matching the spec described in the Custom Resources.

Testing an operator boils down to creating, updating or deleting certain resources and veriify the state of the cluster changes accordingly.


For example, an operator could be responsible for managing role bindings and service accounts in a cluster based on a simplified definition of permissions. This operator exists, see [rbac-manager](https://github.com/FairwindsOps/rbac-manager) from FairWinds.

In the next sections of this blog post I will demonstrate how Chainsaw can help testing the [rbac-manager](https://github.com/FairwindsOps/rbac-manager) operator.

## Getting started

Before we can look at Chainsaw we need a Kubernetes cluster with `rbac-manager` installed.
We can create a local cluster with [KinD](https://kind.sigs.k8s.io) and use [Helm](https://helm.sh) to install the operator.

```sh
# create a cluster
$ kind create cluster

# deploy rbac-manager
$ helm install rbac-manager --repo https://charts.fairwinds.com/stable rbac-manager --namespace rbac-manager --create-namespace
```

Once the operator installed, you should see a new Custom Resource Definition in the cluster:

```sh
$ kubectl get crd

NAME                                         CREATED AT
rbacdefinitions.rbacmanager.reactiveops.io   2023-12-12T12:20:19Z
```

## Install Chainsaw

Chainsaw can be installed in [different ways](https://kyverno.github.io/chainsaw/latest/install/). If you are using MacOS or Linux, the simplest solution is to use [brew](https://brew.sh/).

```sh
# add the chainsaw tap
$ brew tap kyverno/chainsaw https://github.com/kyverno/chainsaw

# install chainsaw
$ brew install kyverno/chainsaw/chainsaw
```

## What is a test ?

To put it simply, a test can be represented as **an ordered sequence of test steps**.

Test steps within a test are run sequentially: **if any of the test steps fail, the entire test is considered failed**.

A test step can consist in one or more operations:

- To delete resources present in a cluster
- To create or update resources in a cluster
- To assert one or more resources in a cluster meet the expectations (or the opposite)
- To run arbitrary commands or scripts

In Chainsaw, tests are entirely declarative and created with yaml files.

## Our first test

In this first test, we're going to create an `RBACDefinition` and verify the `rbac-manager` operator created the corresponding `ClusterRoleBinding` in the cluster.

### RBACDefinition

The `RBACDefinition` below states that the service account `rbac-manager/test-rbac-manager` should be bound to a `test-rbac-manager` cluster role.

```sh
$ cat > resources.yaml << EOF
apiVersion: rbacmanager.reactiveops.io/v1beta1
kind: RBACDefinition
metadata:
  name: rbac-manager-definition
rbacBindings:
  - name: admins
    subjects:
      - kind: ServiceAccount
        name: test-rbac-manager
        namespace: rbac-manager
    clusterRoleBindings:
      - clusterRole: test-rbac-manager
EOF
```

### ClusterRoleBinding

If we apply the `RBACDefinition` definition above, the operator is expected to create the corresponding `ClusterRoleBinding`.

```sh
$ cat > expected.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    rbac-manager: reactiveops
  ownerReferences:
  - apiVersion: rbacmanager.reactiveops.io/v1beta1
    kind: RBACDefinition
    name: rbac-manager-definition
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: test-rbac-manager
subjects:
- kind: ServiceAccount
  name: test-rbac-manager
  namespace: rbac-manager
EOF
```

An important point in this manifest is that it doesn't contain a name. This manifest won't be used by Chainsaw to create resources in the cluster but to verify that a resource in the cluster exists and matches with this definition.

### Finally writing the test file

To summarize, the test we want to write should do:

1. Apply the `RBACDefinition` in the cluster
1. Verify the corresponding `ClusterRoleBinding` is created by the operator
1. Cleanup and move to the next test

Such a Chainsaw test can be written like this:

```sh
$ cat > chainsaw-test.yaml << EOF
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: clusterrolebindings
spec:
  steps:
  - try:
    # create resources in the cluster
    - apply:
        file: resources.yaml
    # verify the operator reacted as expected
    - assert:
        file: expected.yaml
EOF
```

Please note that the file containing the test is named `chainsaw-test.yaml`.

### Invoking Chainsaw

To execute the test we just created against the local cluster, we need to invoke Chainsaw with the `test` command.

```sh
$ chainsaw test

Version: 0.1.0
Loading default configuration...
- Using test file: chainsaw-test.yaml
- TestDirs [.]
- SkipDelete false
- FailFast false
- ReportFormat ''
- ReportName 'chainsaw-report'
- Namespace ''
- FullName false
- IncludeTestRegex ''
- ExcludeTestRegex ''
- ApplyTimeout 5s
- AssertTimeout 30s
- CleanupTimeout 30s
- DeleteTimeout 15s
- ErrorTimeout 30s
- ExecTimeout 5s
Loading tests...
- clusterrolebindings (.)
Running tests...
=== RUN   chainsaw
=== PAUSE chainsaw
=== CONT  chainsaw
=== RUN   chainsaw/clusterrolebindings
=== PAUSE chainsaw/clusterrolebindings
=== CONT  chainsaw/clusterrolebindings
    | 13:41:26 | clusterrolebindings | @setup   | CREATE    | OK    | v1/Namespace @ chainsaw-ample-racer
    | 13:41:26 | clusterrolebindings | step-1   | TRY       | RUN   |
    | 13:41:26 | clusterrolebindings | step-1   | APPLY     | RUN   | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:41:26 | clusterrolebindings | step-1   | CREATE    | OK    | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:41:26 | clusterrolebindings | step-1   | APPLY     | DONE  | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:41:26 | clusterrolebindings | step-1   | ASSERT    | RUN   | rbac.authorization.k8s.io/v1/ClusterRoleBinding @ *
    | 13:41:26 | clusterrolebindings | step-1   | ASSERT    | DONE  | rbac.authorization.k8s.io/v1/ClusterRoleBinding @ *
    | 13:41:26 | clusterrolebindings | step-1   | TRY       | DONE  |
    | 13:41:26 | clusterrolebindings | @cleanup | DELETE    | RUN   | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:41:26 | clusterrolebindings | @cleanup | DELETE    | OK    | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:41:26 | clusterrolebindings | @cleanup | DELETE    | DONE  | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:41:26 | clusterrolebindings | @cleanup | DELETE    | RUN   | v1/Namespace @ chainsaw-ample-racer
    | 13:41:26 | clusterrolebindings | @cleanup | DELETE    | OK    | v1/Namespace @ chainsaw-ample-racer
    | 13:41:31 | clusterrolebindings | @cleanup | DELETE    | DONE  | v1/Namespace @ chainsaw-ample-racer
--- PASS: chainsaw (0.00s)
    --- PASS: chainsaw/clusterrolebindings (5.28s)
PASS
Tests Summary...
- Passed  tests 1
- Failed  tests 0
- Skipped tests 0
Done.
```

Chainsaw will discover tests and run them, either concurrently or sequentially depending on the tool and tests configuration.

## A more advanced test

In the test above, we only covered the creation of `RBACDefinition` resources. While it's a good starting point, we also want to test updates and deletion.
If we delete an `RBACDefinition` resource for example, the corresponding `ClusterRoleBinding` should be deleted from the cluster by the operator.

Chainsaw can easily do that, we just need to add two more steps to our test to delete the `RBACDefinition` and verify the ClusterRoleBinding is deleted accordingly.

```sh
$ cat > chainsaw-test.yaml << EOF
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: clusterrolebindings
spec:
  steps:
  - try:
    # create resources in the cluster
    - apply:
        file: resources.yaml
    # verify the operator reacted as expected
    - assert:
        file: expected.yaml
    # delete previously created resources
    - delete:
        ref:
          apiVersion: rbacmanager.reactiveops.io/v1beta1
          kind: RBACDefinition
          name: rbac-manager-definition
    # make sure expected resources have been deleted
    - error:
        file: expected.yaml
EOF
```

### Running Chainsaw again

If we execute this new test, Chainsaw will now verify that deleting a resource has the expected effect in the cluster.

```sh
$ chainsaw test

Version: 0.1.0
Loading default configuration...
- Using test file: chainsaw-test.yaml
- TestDirs [.]
- SkipDelete false
- FailFast false
- ReportFormat ''
- ReportName 'chainsaw-report'
- Namespace ''
- FullName false
- IncludeTestRegex ''
- ExcludeTestRegex ''
- ApplyTimeout 5s
- AssertTimeout 30s
- CleanupTimeout 30s
- DeleteTimeout 15s
- ErrorTimeout 30s
- ExecTimeout 5s
Loading tests...
- clusterrolebindings (.)
Running tests...
=== RUN   chainsaw
=== PAUSE chainsaw
=== CONT  chainsaw
=== RUN   chainsaw/clusterrolebindings
=== PAUSE chainsaw/clusterrolebindings
=== CONT  chainsaw/clusterrolebindings
    | 13:50:35 | clusterrolebindings | @setup   | CREATE    | OK    | v1/Namespace @ chainsaw-causal-cobra
    | 13:50:35 | clusterrolebindings | step-1   | TRY       | RUN   |
    | 13:50:35 | clusterrolebindings | step-1   | APPLY     | RUN   | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:50:35 | clusterrolebindings | step-1   | CREATE    | OK    | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:50:35 | clusterrolebindings | step-1   | APPLY     | DONE  | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:50:35 | clusterrolebindings | step-1   | ASSERT    | RUN   | rbac.authorization.k8s.io/v1/ClusterRoleBinding @ *
    | 13:50:35 | clusterrolebindings | step-1   | ASSERT    | DONE  | rbac.authorization.k8s.io/v1/ClusterRoleBinding @ *
    | 13:50:35 | clusterrolebindings | step-1   | DELETE    | RUN   | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:50:35 | clusterrolebindings | step-1   | DELETE    | OK    | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:50:35 | clusterrolebindings | step-1   | DELETE    | DONE  | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:50:35 | clusterrolebindings | step-1   | ERROR     | RUN   | rbac.authorization.k8s.io/v1/ClusterRoleBinding @ *
    | 13:50:35 | clusterrolebindings | step-1   | ERROR     | DONE  | rbac.authorization.k8s.io/v1/ClusterRoleBinding @ *
    | 13:50:35 | clusterrolebindings | step-1   | TRY       | DONE  |
    | 13:50:35 | clusterrolebindings | @cleanup | DELETE    | RUN   | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:50:35 | clusterrolebindings | @cleanup | DELETE    | DONE  | rbacmanager.reactiveops.io/v1beta1/RBACDefinition @ rbac-manager-definition
    | 13:50:35 | clusterrolebindings | @cleanup | DELETE    | RUN   | v1/Namespace @ chainsaw-causal-cobra
    | 13:50:35 | clusterrolebindings | @cleanup | DELETE    | OK    | v1/Namespace @ chainsaw-causal-cobra
    | 13:50:40 | clusterrolebindings | @cleanup | DELETE    | DONE  | v1/Namespace @ chainsaw-causal-cobra
--- PASS: chainsaw (0.00s)
    --- PASS: chainsaw/clusterrolebindings (5.32s)
PASS
Tests Summary...
- Passed  tests 1
- Failed  tests 0
- Skipped tests 0
Done.
```

## Conclusion

In this short blog post we demonstrated how Chainsaw can be useful to test Kubernetes operators.

Chainsaw can go a lot deeper and offers much more features than what we demonstrated here.

If you're writing an operator, chances are you need to write end to end tests and this can be painful. Chainsaw can help tremendously focusing on the tests needed rather than messing with writing and maintaining a test framework.

Using it within the Kyverno project helped improve the test coverage by orders of magnitude. Converting issues into end to end tests is often a matter of copying-and-pasting a couple of manifests. Such simplicity guarantees more than just fixing issues but prevents regressions by having a test that continuously verifies they don't happen again.

🔗 Check out the project on GitHub: https://github.com/kyverno/chainsaw

📚 Browse the documentation: https://kyverno.github.io/chainsaw
