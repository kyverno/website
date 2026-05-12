---
date: 2026-05-13
title: Getting Started with Kyverno - From Zero to Your First Policy
tags:
  - General
authors:
  - name: Kirti Goyal
excerpt: A beginner-friendly guide to setting up Kyverno locally using kind, kubectl, Helm, and Docker on macOS.
draft: true
---

When I first started exploring Kyverno, I found myself jumping between different docs, tools, and setup steps trying to understand how everything connected together.

This guide is intended to make that experience simpler for new users getting started locally on macOS.

By the end, you'll have a running Kubernetes cluster, Kyverno installed, and your first policy enforcing rules in real time.

> **Note:** This guide uses Kyverno v1.17.x (compatible with Kubernetes v1.32–v1.35) and
> the `policies.kyverno.io/v1` APIs.

## What you'll have by the end

- A local Kubernetes cluster running on your Mac
- Kyverno installed and active
- A working policy that blocks non-compliant resources in real time

Let's go.

## Before you start

Open your terminal. On Mac: press Cmd + Space, type "Terminal", hit enter. You'll be
running all the commands in this guide from here.

## The tools you need

Here's everything we're installing and what each one actually does:

1. Docker Desktop: Runs the containers that make up your local cluster
2. Homebrew: Package manager for your terminal — like the App Store but for dev tools
3. kubectlCLI: for talking to your Kubernetes cluster
4. kind: Spins up a real Kubernetes cluster locally inside Docker
5. Helm: Package manager for Kubernetes — like Homebrew but for Kubernetes tools

## Step 1: Install Docker Desktop

kind uses Docker containers as Kubernetes nodes, so Docker has to come first. Everything
else depends on it.
Download and install [Docker Desktop](https://docs.docker.com/get-docker/).
After installation, open Docker Desktop and wait for the engine to start. You'll know it's
ready when you see the green dot in your menu bar.

![Docker Desktop running](./assets/docker-running.png)

Verify it's working in your terminal:

```bash
docker --version
```

Expected output:
`Docker version 27.x.x, build xxxxxxx`

```bash
docker ps
```

If Docker is running, this returns an empty table. If it errors, Docker isn't running yet,
you can go back and open Docker Desktop first.

## Step 2: Install Homebrew

Homebrew is basically the App Store for your terminal. Instead of downloading installers
and clicking through setup wizards, you just run brew install and it handles everything.
Check if you already have it:

```bash
brew --version
```

If it's not installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Step 3: Install kubectl

kubectl is the command-line tool for talking to the Kubernetes cluster. Think of it like
a remote control, you tell it what to do and it sends the instructions to your cluster.
You'll use this for everything: applying policies, checking resources, reading output.

```bash
brew install kubectl
```

Verify:

```bash
kubectl version --client
```

## Step 4: Install kind

kind stands for Kubernetes IN Docker. It spins up a real Kubernetes cluster
locally using Docker containers as nodes. There is no need of cloud account, virtual machines, infrastructure setup. You can think of it like a pocket-sized Kubernetes cluster that lives entirely on your laptop.

```bash
brew install kind
```

Verify:

```bash
kind version
```

## Step 5: Install Helm

Helm is a package manager for Kubernetes. It's like Homebrew but for Kubernetes
tools. Instead of manually applying a bunch of YAML files to install something, you run
one Helm command and it handles everything like the install, the configuration, the namespace setup.

```bash
brew install helm
```

Verify:

```bash
helm version
```

## Step 6: Create a local cluster

All the tools that we need are now ready. Now let's actually spin up a cluster.

```bash
kind create cluster --name kyverno-demo
```

This takes about a minute. kind is pulling the Kubernetes node image and setting everything
up inside Docker. Once it's done, you can verify if the cluster is up:

```bash
kubectl cluster-info
kubectl get nodes
```

![Kind cluster node ready](./assets/cluster-ready.png)

You should see one node in Ready state. If it shows NotReady,you can wait 30 seconds and run
it again as it just needs a moment to fully initialize.
You now have a real, working Kubernetes cluster running entirely on your Mac.

## Step 7: Install Kyverno

Now the main event.
First, add the Kyverno Helm repository. This is like adding a new source in Homebrew so
it knows where to find Kyverno's packages:

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

Then install Kyverno into its own dedicated namespace:

```bash
helm install kyverno kyverno/kyverno \
  -n kyverno --create-namespace
```

## Step 8: Verify the installation

```bash
kubectl get pods -n kyverno
```

Don't worry if things take a little time at first. That's completely normal. Because Kubernetes spins up containers in stages and you'll see the pods moving through different states before they are running:

### What you'll see while it's starting up:

```text
kyverno-admission-controller-xxx    0/1   Init:0/1            0   5s
kyverno-background-controller-xxx   0/1   ContainerCreating   0   5s
kyverno-cleanup-controller-xxx      0/1   PodInitializing     0   8s
kyverno-reports-controller-xxx      0/1   PodInitializing     0   8s
```

Give it 30–60 seconds and run the command again. Once everything is ready, all four pods
should show Running:

### Wait Until

![Kyverno pods running](./assets/kyverno-pods-running.png)

Here's what each component does:

- **admission-controller** — This is the main one. It intercepts every incoming resource request before Kubernetes accepts it. This is where the policies actually run.

- **background-controller** — It handles generate and mutate-existing policies that run
  outside of the admission flow

- **cleanup-controller** — It handles scheduled deletion policies

- **reports-controller** — It manages policy reports so one can see what passed and failed

If all four are `Running`, Kyverno is active and ready.

**Something not right?**
If any pod is stuck in `Pending` or `Error` after a few minutes, run:

```bash
kubectl describe pod <pod-name> -n kyverno
```

_Most common cause:_ Docker isn't running or the cluster didn't start cleanly.
Try deleting and recreating the cluster:

```bash
kind delete cluster --name kyverno-demo
kind create cluster --name kyverno-demo
```

Kyverno is now running as an **admission controller** inside your cluster. Think of it like a bouncer at the door and every resource that tries to enter your cluster has to get past
Kyverno first.
That means every time you run:

```bash
kubectl apply -f something.yaml
```

That request goes to the Kubernetes API server and Kyverno intercepts it before
Kubernetes accepts it. Your resource only gets created if Kyverno says it's allowed.

At that checkpoint, Kyverno can:

- Allow the resource through
- Block it if it breaks a rule
- Modify it automatically before it's stored

## Step 9: Apply your first policy

Let's write a real rule: every Pod must have a label called `app`.

Create a file called `policy.yaml`:

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-app-label
spec:
  validationActions:
    - Deny # Block the request if the rule isn't met
      # Swap to Audit if you want to observe without blocking
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: ['CREATE']
        resources: ['pods'] # This policy only applies to Pods
  validations:
    - message: "label 'app' is required"
      expression: "'app' in object.metadata.?labels.orValue([])"
      # object = the resource being evaluated, this is always your starting point in CEL
      # .?labels safely handles pods that have no labels at all
      # .orValue([]) returns an empty list instead of erroring if labels don't exist
```

Apply it:

```bash
kubectl apply -f policy.yaml
```

Expected output:

![policy created](./assets/policy-created.png)

## Step 10: Let's test it

This is the fun part. First let's create a Pod without the required label and watch Kyverno block it.

Create `pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-no-label
spec:
  containers:
    - name: nginx
      image: nginx
```

```bash
kubectl apply -f pod.yaml
```

**You should see:**

```text
Error from server: admission webhook "validate.kyverno.svc" denied the request:
label 'app' is required
```

![Policy denied by Kyverno](./assets/policy-denied.png)

Kyverno intercepted the request and blocked it before the Pod was ever created. That's
exactly how Kyverno works.

## Step 11: Let's Fix it and try again

Update `pod.yaml` to add the missing label:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-no-label
  labels:
    app: demo # required label — now it's here
spec:
  containers:
    - name: nginx
      image: nginx
```

```bash
kubectl apply -f pod.yaml
```

**Expected output:**

![Pod successfully created](./assets/policy-success.png)

That's it. Pod goes through.

### What just happened?

You just ran a complete policy lifecycle:

1. Tried to create a resource → **denied**
2. Fixed the resource → **allowed**

This is exactly how Kyverno works in real clusters. You write the rule once. Every resource
that comes in gets checked automatically, every time, no exceptions. The best part is that nobody has to remember anything manually.

### Want to try this without a local cluster?

You can experiment with Kyverno policies directly in your browser:
[playground.kyverno.io](https://playground.kyverno.io)

Paste any policy and resource and see exactly what Kyverno would do. This is great for quickly testing CEL expressions before applying them to a real cluster.

### What's next - the five policy types

This guide covered `ValidatingPolicy` which the most fundamental one. Kyverno can do a lot more than just validate.

- **ValidatingPolicy:** Enforce rules like allow or deny resources
- **MutatingPolicy:** Automatically modify resources before they're stored
- **GeneratingPolicy:** Create new resources when something happens
- **DeletingPolicy:** Clean up resources on a schedule
- **ImageValidatingPolicy:** Verify container image signatures for supply chain security

## The best way to learn from here

Don't just follow guides. Intentionally break things.
You can change the **CEL expression**. Create resources that should fail. Create ones that should pass.
Watch what Kyverno does at each step. That's genuinely how it clicks and not just from reading, but from seeing the deny and allow cycle play out in your own terminal.
The cluster is local. Nothing is at risk. Feel free to break things.
