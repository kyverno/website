---
date: 2023-11-13
title: "Using CEL Expressions in Kyverno Policies"
linkTitle: "Using CEL Expressions in Kyverno Policies"
author: Mariam Fahmy
description: "Using CEL Expressions in Kyverno Policies"
---
Kyverno, in simple terms, is a policy engine for Kubernetes that can be used to describe policies and validate resource requests against those policies. It allows us to create policies for our Kubernetes cluster on different levels. It enables us to validate, change, and create resources based on our defined policies.

A Kyverno policy is a collection of rules. Whenever we receive an API request to our Kubernetes cluster, we validate it with a set of rules.

A policy consists of different clauses, such as:
- Match: It selects resources that match the given criteria.
- Exclude: It selects all but excludes resources that match the specified criteria.

> Match and Exclude are used to select resources, users, user groups, service accounts, namespaced roles, and cluster-wide roles.

- Validate: It validates the properties of the new resource, and it is created if it matches what is declared in the rule.
- Mutate: It modifies matching resources.
- Generate: It creates additional resources.
- Verify Images: It verifies container image signatures using Cosign and Notary.

> Each rule can contain only a single validate, mutate, generate, or verifyImages child declaration.

In this post, I will show you how to write CEL expressions in Kyverno policies for resource validation. Common Expression Language (CEL) was first introduced to Kubernetes for the Validation rules for CustomResourceDefinitions, and then it was used by Kubernetes ValidatingAdmissionPolicies in 1.26.

## CEL Expressions in validate rules
### Creating a policy to disallow host paths for Deployments

The below policy ensures no hostPath volumes are in use for deployments.
```yaml
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-path
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: host-path
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        cel:
          expressions:
            - expression: "!has(object.spec.template.spec.volumes) || object.spec.template.spec.volumes.all(volume, !has(volume.hostPath))"
              message: "HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath must be unset."
EOF
```

`spec.rules.validate.cel` contains CEL expressions that use the Common Expression Language (CEL) to validate the request. If an expression evaluates to false, the validation check is enforced according to the `spec.validationFailureAction` field.

Now, let’s try deploying an app that uses a hostPath:
```yaml
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
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

We can see that our policy is enforced, great!
```
Error from server: error when creating "STDIN": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Deployment/default/nginx was blocked due to the following policies 

disallow-host-path:
  host-path: HostPath volumes are forbidden. The field spec.template.spec.volumes[*].hostPath
    must be unset.
```

### Creating a policy to check StatefulSet Namespaces
The below policy ensures that any statefulset is created in the production namespace
```yaml
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-statefulset-namespace
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: statefulset-namespace
      match:
        any:
        - resources:
            kinds:
              - StatefulSet
      validate:
        cel:
          expressions:
            - expression: "namespaceObject.metadata.name == 'production'"
              message: "The StatefulSet must be created in the 'production' namespace."
EOF
```

Let’s try creating a statefulset in the default namespace
```yaml
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: bad-statefulset
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: container2
        image: nginx
EOF
```
As expected, the statefulset creation is blocked because it violates the rule
```
Error from server: error when creating "STDIN": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource StatefulSet/default/bad-statefulset was blocked due to the following policies 

check-statefulset-namespace:
  statefulset-namespace: The StatefulSet must be created in the 'production' namespace.
```
Let's create a statefulset in the production namespace
```yaml
kubectl apply -f - << EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: good-statefulset
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: container2
        image: nginx
EOF
```
The statefulset is successfully created. Great!
```
statefulset.apps/good-statefulset created
```
In the previous two examples, we have used object in CEL expressions which refers to the incoming object and namespaceObject which refers to the namespace that the incoming object belongs to. 


Some other useful variables that we can use in CEL expressions are
1. oldObject: The existing object. The value is null for CREATE requests.
2. authorizer: It can be used to perform authorization checks.
3. authorizer.requestResource: A shortcut for an authorization check configured with the request resource (group, resource, (subresource), namespace, name).

## CEL Preconditions in Kyverno Policies

The below policy ensures the hostPort field is set to a value between 5000 and 6000 for pods whose `metadata.name` set to `nginx`
```yaml
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-port-range
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: host-port-range
      match:
        any:
        - resources:
            kinds:
              - Pod
      celPreconditions:
          - name: "first match condition in CEL"
            expression: "object.metadata.name.matches('nginx')"
      validate:
        cel:
          expressions:
          - expression: "object.spec.containers.all(container, !has(container.ports) || container.ports.all(port, !has(port.hostPort) || (port.hostPort >= 5000 && port.hostPort <= 6000)))"
            message: "The only permitted hostPorts are in the range 5000-6000."
EOF
```
`spec.rules.celPreconditions` are CEL expressions. All celPreconditions must be evaluated to true for the resource to be evaluated. Therefore, any pod with nginx in its metadata.name will be evaluated.

Let’s try deploying an Apache server with hostPort set to 80.
```yaml
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: apache
spec:
  containers:
  - name: apache-server
    image: httpd
    ports:
    - containerPort: 8080
      hostPort: 80
EOF
```
You’ll see that it’s successfully created because the validation rule wasn’t applied on the new pod as it doesn’t satisfy the celPreconditions. That’s exactly what we need.
```
pod/apache created
```
Let’s try deploying an Nginx server with hostPort set to 80.
```yaml
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx-server
    image: nginx
    ports:
    - containerPort: 8080
      hostPort: 80
EOF
```
Since the new pod satisfies the celPreconditions, the validation rule will be applied. As a result, the creation of the pod will be blocked as it violates the rule.
```
Error from server: error when creating "STDIN": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Pod/default/nginx was blocked due to the following policies 

disallow-host-port-range:
  host-port-range: The only permitted hostPorts are in the range 5000-6000.
```

## Parameter Resources in Kyverno Policies

The below policy ensures the deployment replicas are less than a specific value. This value is defined in a parameter resource.
```yaml
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-deployment-replicas
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: deployment-replicas
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        cel:
          paramKind: 
            apiVersion: rules.example.com/v1
            kind: ReplicaLimit
          paramRef:
            name: "replica-limit-test.example.com"
            parameterNotFoundAction: "Deny"
          expressions:
            - expression: "object.spec.replicas <= params.maxReplicas"
              messageExpression:  "'Deployment spec.replicas must be less than ' + string(params.maxReplicas)"
EOF
```
The `cel.paramKind` and `cel.paramRef` specify the resource used to parameterize this policy. For this example, it is configured by `ReplicaLimit` custom resources.

The ReplicaLimit could be as follows:
```yaml
kubectl apply -f - <<EOF
apiVersion: rules.example.com/v1
kind: ReplicaLimit
metadata:
  name: "replica-limit-test.example.com"
maxReplicas: 3
EOF
```
Here’s the corresponding custom resource definition:
```yaml
kubectl apply -f - <<EOF
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: replicalimits.rules.example.com
spec:
  group: rules.example.com
  names:
    kind: ReplicaLimit
    plural: replicalimits
  scope: Namespaced
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            apiVersion:
              type: string
            kind:
              type: string
            metadata:
              type: object
            maxReplicas:
              type: integer
EOF
```
Now, let’s try deploying an app with five replicas.
```yaml
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 5
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
EOF
```
As expected, the deployment creation will be blocked because it violates the rule.
```
Error from server: error when creating "STDIN": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Deployment/default/nginx was blocked due to the following policies 

check-deployment-replicas:
  deployment-replicas: Deployment spec.replicas must be less than 3
```
Let’s try deploying an app with two replicas.
```yaml
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
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
EOF
```
The deployment is created successfully. Great!
```
deployment.apps/nginx created
```

## CEL Variables in Kyverno Policies
If an expression grows too complicated, or part of the expression is reusable and computationally expensive to evaluate. We can extract some parts of the expressions into variables. A variable is a named expression that can be referred later as variables in other expressions.

The order of variables is important because a variable can refer to other variables defined before it. This ordering prevents circular references.

The below policy enforces that image repo names match the environment defined in its namespace. It enforces that all containers of deployment have the image repo match the environment label of its namespace except for "exempt" deployments or any containers that do not belong to the "example.com" organization (e.g., common sidecars). For example, if the namespace has a label of {"environment": "staging"}, all container images must be either staging.example.com/* or do not contain "example.com" at all, unless the deployment has {"exempt": "true"} label.
```yaml
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: image-matches-namespace-environment.policy.example.com
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: image-matches-namespace-environment
      match:
        any:
        - resources:
            kinds:
              - Deployment
      validate:
        cel:
          variables:
            - name: environment
              expression: "'environment' in namespaceObject.metadata.labels ? namespaceObject.metadata.labels['environment'] : 'prod'"
            - name: exempt
              expression: "has(object.metadata.labels) && 'exempt' in object.metadata.labels && object.metadata.labels['exempt'] == 'true'"
            - name: containers
              expression: "object.spec.template.spec.containers"
            - name: containersToCheck
              expression: "variables.containers.filter(c, c.image.contains('example.com/'))"
          expressions:
            - expression: "variables.exempt || variables.containersToCheck.all(c, c.image.startsWith(variables.environment + '.'))"
              messageExpression: "'only ' + variables.environment + ' images are allowed in namespace ' + namespaceObject.metadata.name"
EOF
```
Let’s start with creating a namespace that has a label of environment: staging
```yaml
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: staging-ns
  labels:
    environment: staging
EOF
```
And then create a deployment whose image is example.com/nginx in the staging-ns namespace
```yaml
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-fail
  namespace: staging-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: container2
        image: example.com/nginx
EOF
```
As expected, the deployment creation will be blocked since its image must be staging.example.com/nginx

Let's try setting the deployment image to staging.example.com/nginx instead
```yaml
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-pass
  namespace: staging-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: container2
        image: staging.example.com/nginx
EOF
```
The deployment is created successfully. Great!
```
deployment.apps/deployment-pass created
```

## Auto-Gen Rules for CEL Expressions
Since Kubernetes has many higher-level controllers that directly or indirectly manage Pods: Deployment, DaemonSet, StatefulSet, Job, and CronJob resources, it’d be inefficient to write a policy that targets Pods and every higher-level controller. Kyverno solves this issue by supporting the automatic generation of policy rules for higher-level controllers from a rule written exclusively for a Pod.

For example, when creating a validation policy like below, which disallows latest image tags, the policy applies to all resources capable of generating Pods.

```yaml
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
spec:
 validationFailureAction: Enforce
  rules:
  - name: disallow-latest-tag
    match:
      any:
      - resources:
          kinds:
          - Pod
    validate:
        cel:
          expressions:
            - expression: "object.spec.containers.all(container, !container.image.contains('latest'))"
              message: "Using a mutable image tag e.g. 'latest' is not allowed."
EOF
```
Once the policy is created, these other resources can be shown in auto-generated rules which Kyverno adds to the policy under the status object.

```yaml
status:
  autogen:
    rules:
    - exclude:
        resources: {}
      generate:
        clone: {}
        cloneList: {}
      match:
        any:
        - resources:
            kinds:
            - DaemonSet
            - Deployment
            - Job
            - StatefulSet
            - ReplicaSet
            - ReplicationController
        resources: {}
      mutate: {}
      name: autogen-disallow-latest-tag
      validate:
        cel:
          expressions:
          - expression: object.spec.template.spec.containers.all(container, !container.image.contains('latest'))
            message: Using a mutable image tag e.g. 'latest' is not allowed.
    - exclude:
        resources: {}
      generate:
        clone: {}
        cloneList: {}
      match:
        any:
        - resources:
            kinds:
            - CronJob
        resources: {}
      mutate: {}
      name: autogen-cronjob-disallow-latest-tag
      validate:
        cel:
          expressions:
          - expression: object.spec.jobTemplate.spec.template.spec.containers.all(container,
              !container.image.contains('latest'))
            message: Using a mutable image tag e.g. 'latest' is not allowed.
```
Let's try creating an nginx deployment with the latest tag.
```yaml
kubectl apply -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
EOF
```
As expected the deployment creation is blocked.
```
Error from server: error when creating "STDIN": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Deployment/default/nginx-deployment was blocked due to the following policies 

disallow-latest-tag:
  autogen-disallow-latest-tag: Using a mutable image tag e.g. 'latest' is not allowed.
```

## Conclusion 
This blog post explains how to use CEL expressions in Kyverno policies to validate resources covering all the features introduced in Kubernetes ValidatingAdmissionPolicies. 
Stay tuned for our next post, where we'll show you how to generate Kubernetes ValidatingAdmissionPolicies from Kyverno policies.
