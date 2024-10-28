---
title: Quick Start Guides
linkTitle: Quick Start Guides
weight: 20
description: >
  An introduction to Kyverno policy and rule types
---

This section is intended to provide you with some quick guides on how to get Kyverno up and running and demonstrate a few of Kyverno's seminal features. There are quick start guides which focus on validation, mutation, as well as generation allowing you to select the one (or all) which is most relevant to your use case.

These guides are intended for proof-of-concept or lab demonstrations only and not recommended as a guide for production. Please see the [installation page](../installation/_index.md) for more complete information on how to install Kyverno in production.

First, install Kyverno from the latest release manifest.

```sh
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.12.0/install.yaml
```

Next, select the quick start guide in which you are interested. Alternatively, start at the top and work your way down.

## Validate Resources

In the validation guide, you will see how simple an example Kyverno policy can be which ensures a label called `team` is present on every Pod. Validation is the most common use case for policy and functions as a "yes" or "no" decision making process. Resources which are compliant with the policy are allowed to pass ("yes, this is allowed") and those which are not compliant may not be allowed to pass ("no, this is not allowed"). An additional effect of these validate policies is to produce Policy Reports. A [Policy Report](../policy-reports/_index.md) is a custom Kubernetes resource, produced and managed by Kyverno, which shows the results of policy decisions upon allowed resources in a user-friendly way.

Add the policy below to your cluster. It contains a single validation rule that requires that all Pods have the `team` label. Kyverno supports different rule types to validate, mutate, generate, cleanup, and verify image configurations. The field `failureAction` is set to `Enforce` to block Pods that are non-compliant. Using the default value `Audit` will report violations but not block requests.

```yaml
kubectl create -f- << EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  rules:
  - name: check-team
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
      failureAction: Enforce
      message: "label 'team' is required"
      pattern:
        metadata:
          labels:
            team: "?*"
EOF
```

Try creating a Deployment without the required label.

```sh
kubectl create deployment nginx --image=nginx
```

You should see an error.

```sh
error: failed to create deployment: admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Deployment/default/nginx was blocked due to the following policies:

require-labels:
  autogen-check-team: 'validation error: label ''team'' is
    required. Rule autogen-check-team failed at path /spec/template/metadata/labels/team/'
```

In addition to the error returned, Kyverno also produces an Event in the same Namespace which contains this information.

{{% alert title="Note" color="info" %}}
Kyverno may be configured to exclude system Namespaces like `kube-system` and `kyverno`. Make sure you create the Deployment in a user-defined Namespace or the `default` Namespace (for testing only).
{{% /alert %}}

Note that how although the policy matches on Pods, Kyverno blocked the Deployment you just created. This is because Kyverno intelligently applies policies written exclusively for Pods, using its [rule auto-generation](../writing-policies/autogen.md) feature, to all standard Kubernetes Pod controllers including the Deployment above.

Now, create a Pod with the required label.

```sh
kubectl run nginx --image nginx --labels team=backend
```

This Pod configuration is compliant with the policy and is allowed.

Now that the Pod exists, wait just a few seconds longer and see what other action Kyverno took. Run the following command to retrieve the Policy Report that Kyverno just created.

```sh
kubectl get policyreport -o wide
```

Notice that there is a single Policy Report with just one result listed under the "PASS" column. This result is due to the Pod we just created having passed the policy.

```sh
NAME                                   KIND         NAME     PASS   FAIL   WARN   ERROR   SKIP   AGE
89044d72-8a1e-4af0-877b-9be727dc3ec4   Pod          nginx    1      0      0      0       0      15s
```

If you were to describe the above policy report you would see more information about the policy and resource.

```yaml
Results:
  Message:  validation rule 'check-team' passed.
  Policy:   require-labels
  Resources:
    API Version:  v1
    Kind:         Pod
    Name:         nginx
    Namespace:    default
    UID:          07d04dc0-fbb4-479a-b049-a3d63342b354
  Result:         pass
  Rule:           check-team
  Scored:         true
  Source:         kyverno
  Timestamp:
    Nanos:    0
    Seconds:  1683759146
```

Policy reports are helpful in that they are both user- and tool-friendly, based upon an open standard, and separated from the policies which produced them. This separation has the benefit of report access being easy to grant and manage for other users who may not need or have access to Kyverno policies.

Now that you've experienced validate policies and seen a bit about policy reports, clean up by deleting the policy you created above.

```sh
kubectl delete clusterpolicy require-labels
```

Congratulations, you've just implemented a validation policy in your Kubernetes cluster! For more details on validation policies, see the [validate section](../writing-policies/validate.md).

## Mutate Resources

Mutation is the ability to change or "mutate" a resource in some way prior to it being admitted into the cluster. A mutate rule is similar to a validate rule in that it selects some type of resource (like Pods or ConfigMaps) and defines what the desired state should look like.

Add this Kyverno mutate policy to your cluster. This policy will add the label `team` to any new Pod and give it the value of `bravo` but only if a Pod does not already have this label assigned. Kyverno has the ability to perform basic "if-then" logical decisions in a very easy way making policies trivial to write and read. The `+(team)` notation uses a Kyverno anchor to define the behavior Kyverno should take if the label key is not found.

```yaml
kubectl create -f- << EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-labels
spec:
  rules:
  - name: add-team
    match:
      any:
      - resources:
          kinds:
          - Pod
    mutate:
      patchStrategicMerge:
        metadata:
          labels:
            +(team): bravo
EOF
```

Let's now create a new Pod which does not have the desired label defined.

```sh
kubectl run redis --image redis
```

{{% alert title="Note" color="info" %}}
Kyverno may be configured to exclude system Namespaces like `kube-system` and `kyverno`. Make sure you create the Pod in a user-defined Namespace or the `default` Namespace (for testing only).
{{% /alert %}}

Once the Pod has been created, get the Pod to see if the `team` label was added.

```sh
kubectl get pod redis --show-labels
```

You should see that the label `team=bravo` has been added by Kyverno.

Try one more Pod, this time one which does already define the `team` label.

```sh
kubectl run newredis --image redis -l team=alpha
```

Get this Pod back and check once again for labels.

```sh
kubectl get pod newredis --show-labels
```

This time, you should see Kyverno did not add the `team` label with the value defined in the policy since one was already found on the Pod.

Now that you've experienced mutate policies and seen how logic can be written easily, clean up by deleting the policy you created above.

```sh
kubectl delete clusterpolicy add-labels
```

Congratulations, you've just implemented a mutation policy in your Kubernetes cluster! For more details on mutate policies, see the [mutate section](../writing-policies/mutate.md).

## Generate Resources

Kyverno has the ability to generate (i.e., create) a new Kubernetes resource based upon a definition stored in a policy. Like both validate and mutate rules, Kyverno generate rules use similar concepts and structures to express policy. The generation ability is both powerful and flexible with one of its most useful aspects being, in addition to the initial generation, it has the ability to continually synchronize the resources it has generated. Generate rules can be a powerful automation tool and can solve many common challenges faced by Kubernetes operators. Let's look at one such use case in this guide.

We will use a Kyverno generate policy to generate an image pull secret in a new Namespace.

First, create this Kubernetes Secret in your cluster which will simulate a real image pull secret.

```sh
kubectl -n default create secret docker-registry regcred \
  --docker-server=myinternalreg.corp.com \
  --docker-username=john.doe \
  --docker-password=Passw0rd123! \
  --docker-email=john.doe@corp.com
```
By default, Kyverno is [configured with minimal permissions](../installation/customization.md#role-based-access-controls) and does not have access to security sensitive resources like Secrets. You can provide additional permissions using cluster role aggregation. The following role permits the Kyverno background-controller to create (clone) secrets.

```yaml
kubectl create -f- << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno:secrets:manage
  labels:
    rbac.kyverno.io/aggregate-to-background-controller: "true"
rules:
- apiGroups:
  - ''
  resources:
  - secrets
  verbs:
  - create
EOF
```

Next, create the following Kyverno policy. The `sync-secrets` policy will match on any newly-created Namespace and will clone the Secret we just created earlier into that new Namespace.

```yaml
kubectl create -f- << EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-secrets
spec:
  rules:
  - name: sync-image-pull-secret
    match:
      any:
      - resources:
          kinds:
          - Namespace
    generate:
      apiVersion: v1
      kind: Secret
      name: regcred
      namespace: "{{request.object.metadata.name}}"
      synchronize: false
      clone:
        namespace: default
        name: regcred
EOF
```

Create a new Namespace to test the policy.

```sh
kubectl create ns mytestns
```

Get the Secrets in this new Namespace and see if `regcred` is present.

```sh
kubectl -n mytestns get secret
```

You should see that Kyverno has generated the `regcred` Secret using the source Secret from the `default` Namespace as the template. If you wish, you may also modify the source Secret and watch as Kyverno synchronizes those changes down to wherever it has generated it.

With a basic understanding of generate policies, clean up by deleting the policy you created above.

```sh
kubectl delete clusterpolicy sync-secrets
```

Congratulations, you've just implemented a generation policy in your Kubernetes cluster! For more details on generate policies, see the [generate section](../writing-policies/generate.md).


