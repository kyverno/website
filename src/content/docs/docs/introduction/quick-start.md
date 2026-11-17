---
title: Kyverno Quick Start
linkTitle: Quick Start Guides
sidebar:
  order: 20
excerpt: An introduction to Kyverno policy and rule types
---

This section is intended to provide you with some quick guides on how to get Kyverno up and running and demonstrate a few of Kyverno's seminal features. There are quick start guides which focus on validation, mutation, as well as generation allowing you to select the one (or all) which is most relevant to your use case.

These guides are intended for proof-of-concept or lab demonstrations only and not recommended as a guide for production. Please see the [installation page](/docs/installation/installation) for more complete information on how to install Kyverno in production.

These guides require **Kyverno v1.17.0 or later**, the first verified release serving `policies.kyverno.io/v1` for the `ValidatingPolicy`, `MutatingPolicy`, and `GeneratingPolicy` resources. Kyverno v1.16.0 serves these policy resources only at `v1alpha1`, not `v1`.

First, install the current Kyverno release using Helm:

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

Next, select the quick start guide in which you are interested. Alternatively, start at the top and work your way down.

The validation and mutation examples do not require registry credentials or Secrets. The generation example is a separate, lab-only Secret demonstration.

## Validate Resources

In the validation guide, you will see how simple an example Kyverno policy can be which ensures a label called `team` is present on every Pod. Validation is the most common use case for policy and functions as a "yes" or "no" decision making process. Resources which are compliant with the policy are allowed to pass ("yes, this is allowed") and those which are not compliant may not be allowed to pass ("no, this is not allowed").

Add the policy below to your cluster. It contains a single validation rule that requires all Pods in `quick-start-validation` to have the `team` label. Kyverno supports different policy types to validate, mutate, generate, cleanup, and verify image configurations. The `validationActions` field is set to `Deny` to block Pods that are non-compliant.

Create a namespace for this example. All Pods in this example will be in this namespace.

```sh
kubectl create namespace quick-start-validation
```

```sh
kubectl create -f- << EOF
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-labels
spec:
  validationActions:
    - Deny
  autogen:
    podControllers:
      controllers:
        - deployments
  matchConstraints:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: quick-start-validation
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  validations:
    - message: "label 'team' is required"
      expression: "has(object.metadata.labels) && has(object.metadata.labels.team) && object.metadata.labels.team != ''"
EOF
```

Try creating a Deployment without the required label.

```sh
kubectl -n quick-start-validation create deployment nginx --image=nginx
```

The admission request should be denied with the message `label 'team' is required`.

Although the policy matches on Pods, Kyverno can also apply it to Pod controllers such as Deployments using [auto-generation](/docs/policy-types/validating-policy#autogen).

Now, create a Pod with the required label.

```sh
kubectl -n quick-start-validation run nginx --image registry.k8s.io/pause:3.10 --labels team=backend
```

This Pod configuration is compliant with the policy and is allowed.

Now that you've experienced validation, clean up by deleting the policy and namespace you created above.

```sh
kubectl delete validatingpolicy require-labels
kubectl delete namespace quick-start-validation
```

Deleting the namespace also removes the Deployment (if it was allowed) and the Pod created in this workflow.

Congratulations, you've just implemented a validation policy in your Kubernetes cluster! For more details on validation policies, see the [ValidatingPolicy section](/docs/policy-types/validating-policy).

## Mutate Resources

Mutation is the ability to change or "mutate" a resource in some way prior to it being admitted into the cluster. A mutate rule is similar to a validate rule in that it selects some type of resource (like Pods or ConfigMaps) and defines what the desired state should look like.

Add this Kyverno mutate policy to your cluster. This policy will add the label `team` to any new Pod and give it the value of `bravo` but only if a Pod does not already have this label assigned. Kyverno uses CEL expressions to perform conditional logic, making policies easy to write and read.

Create a namespace for this example.

```sh
kubectl create namespace quick-start-mutation
```

```sh
kubectl create -f- << EOF
apiVersion: policies.kyverno.io/v1
kind: MutatingPolicy
metadata:
  name: add-labels
spec:
  matchConstraints:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: quick-start-mutation
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE', 'UPDATE']
        resources: ['pods']
  matchConditions:
    - name: team-label-missing
      expression: '!has(object.metadata.labels) || !has(object.metadata.labels.team)'
  mutations:
    - patchType: ApplyConfiguration
      applyConfiguration:
        expression: >
          Object{
            metadata: Object.metadata{
              labels: Object.metadata.labels{
                team: "bravo"
              }
            }
          }
EOF
```

Let's now create a new Pod which does not have the desired label defined.

```sh
kubectl -n quick-start-mutation run redis --image registry.k8s.io/pause:3.10
```

Once the Pod has been created, get the Pod to see if the `team` label was added.

```sh
kubectl -n quick-start-mutation get pod redis --show-labels
```

You should see that the label `team=bravo` has been added by Kyverno.

Try one more Pod, this time one which does already define the `team` label.

```sh
kubectl -n quick-start-mutation run newredis --image registry.k8s.io/pause:3.10 -l team=alpha
```

Get this Pod back and check once again for labels.

```sh
kubectl -n quick-start-mutation get pod newredis --show-labels
```

This time, you should see Kyverno did not add the `team` label with the value defined in the policy since one was already found on the Pod.

Now that you've experienced mutate policies and seen how logic can be written easily, clean up by deleting the policy you created above.

```sh
kubectl delete mutatingpolicy add-labels
kubectl delete namespace quick-start-mutation
```

Deleting the namespace also removes both Pods created in this workflow.

Congratulations, you've just implemented a mutation policy in your Kubernetes cluster! For more details on mutate policies, see the [MutatingPolicy section](/docs/policy-types/mutating-policy).

## Generate Resources

Kyverno can generate (create) a Kubernetes resource based upon a definition stored in a policy. This example copies an image pull Secret once into one lab namespace.

:::caution[Lab-only Secret and permissions]
Use only the synthetic values below. Do not paste real registry credentials into a terminal command, shell history, a shared cluster, or this guide. Real registry credentials are sensitive; use a dedicated Secret-management workflow outside this demonstration.

Kyverno's background-controller normally has no access to Secrets. The two RoleBindings below grant it only `get` access to the named source Secret in `quick-start-source` and `get`/`create` access to Secrets within the single destination namespace, `quick-start-generated`. This is still sensitive lab-only access: do not use these example permissions in production.
:::

Create the source namespace and a dummy image pull Secret. The `.invalid` domain and placeholder password are not real registry credentials and cannot authenticate to a registry.

```sh
kubectl create namespace quick-start-source
kubectl -n quick-start-source create secret docker-registry regcred \
  --docker-server=registry.example.invalid \
  --docker-username=demo-user \
  --docker-password=replace-with-non-sensitive-placeholder \
  --docker-email=demo@example.invalid
```

Create a Role and RoleBinding that allow the background-controller to read only the source Secret named `regcred`.

```sh
kubectl apply -f- << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kyverno-quick-start-source-secret
  namespace: quick-start-source
rules:
- apiGroups:
  - ''
  resources:
  - secrets
  resourceNames:
  - regcred
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kyverno-quick-start-source-secret
  namespace: quick-start-source
subjects:
- kind: ServiceAccount
  name: kyverno-background-controller
  namespace: kyverno
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kyverno-quick-start-source-secret
---
apiVersion: v1
kind: Namespace
metadata:
  name: quick-start-generated
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kyverno-quick-start-generated-secret
  namespace: quick-start-generated
rules:
- apiGroups:
  - ''
  resources:
  - secrets
  resourceNames:
  - regcred
  verbs:
  - get
- apiGroups:
  - ''
  resources:
  - secrets
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kyverno-quick-start-generated-secret
  namespace: quick-start-generated
subjects:
- kind: ServiceAccount
  name: kyverno-background-controller
  namespace: kyverno
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kyverno-quick-start-generated-secret
EOF
```

The source Role is limited to reading `regcred`. In the destination namespace, the controller can read only `regcred` and create Secrets. Kubernetes RBAC cannot restrict `create` by resource name, so keep this namespace dedicated to the example. Create the policy below after both Roles and RoleBindings exist. It matches only the update that first adds the readiness label as `true`, so later namespace updates do not rerun generation.

```sh
kubectl create -f- << EOF
apiVersion: policies.kyverno.io/v1
kind: GeneratingPolicy
metadata:
  name: sync-secrets
spec:
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['UPDATE']
        resources: ['namespaces']
  matchConditions:
    - name: destination-namespace-ready
      expression: "object.metadata.name == 'quick-start-generated' && object.metadata.labels.exists(k, k == 'quick-start.kyverno.io/ready' && object.metadata.labels[k] == 'true') && (!has(oldObject.metadata.labels) || !oldObject.metadata.labels.exists(k, k == 'quick-start.kyverno.io/ready'))"
  variables:
    - name: targetNs
      expression: 'object.metadata.name'
    - name: sourceSecret
      expression: 'resource.Get("v1", "secrets", "quick-start-source", "regcred")'
  generate:
    - expression: 'generator.Apply(variables.targetNs, [variables.sourceSecret])'
EOF
```

Wait for the policy to be ready, then enable generation by updating the destination namespace label.

```sh
kubectl wait --for='jsonpath={.status.conditionStatus.ready}=true' generatingpolicy/sync-secrets --timeout=120s
kubectl label namespace quick-start-generated quick-start.kyverno.io/ready=true
```

Get the generated Secret:

```sh
kubectl wait --for=create secret/regcred -n quick-start-generated --timeout=120s
kubectl -n quick-start-generated get secret
```

You should see that Kyverno generated `regcred` from the source Secret in `quick-start-source`.

With a basic understanding of generate policies, clean up all resources created by this example.

```sh
kubectl delete generatingpolicy sync-secrets
kubectl -n quick-start-generated delete secret regcred --ignore-not-found
kubectl -n quick-start-generated delete rolebinding kyverno-quick-start-generated-secret
kubectl -n quick-start-generated delete role kyverno-quick-start-generated-secret
kubectl -n quick-start-source delete rolebinding kyverno-quick-start-source-secret
kubectl -n quick-start-source delete role kyverno-quick-start-source-secret
kubectl -n quick-start-source delete secret regcred
kubectl delete namespace quick-start-generated quick-start-source
```

Congratulations, you've just implemented a generation policy in your Kubernetes cluster! For more details on generate policies, see the [GeneratingPolicy section](/docs/policy-types/generating-policy).

When you finish all the guides, remove the Kyverno release and its namespace from a dedicated lab cluster:

```sh
helm uninstall kyverno -n kyverno
kubectl delete namespace kyverno
```

Helm retains some Kyverno CRDs after uninstall. Keep any remaining CRDs on a shared cluster; to remove them from an isolated lab, delete the disposable cluster instead of deleting CRDs that may contain other policies or resources.
