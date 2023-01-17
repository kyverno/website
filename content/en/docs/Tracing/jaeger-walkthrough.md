---
title: Tracing Tutorial with Jaeger
description: A short proof-of-concept tutorial of tracing using Jaeger.
weight: 10
---

This walkthrough shows how to create a local cluster and deploy a number of components, including an [ingress-nginx](https://github.com/kubernetes/ingress-nginx) ingress controller, and [Jaeger](https://www.jaegertracing.io) to store, query and visualise traces.

On the prepared cluster we will deploy Kyverno with tracing enabled and a couple of policies.

Finally we will exercise the Kyverno webhooks by creating a Pod, then we will use Grafana to find and examine the corresponding trace.

Please note that **this walkthrough uses [kind](https://kind.sigs.k8s.io) to create a local cluster** with a specific label on the control plane node.
This is necessary as we are using an [ingress-nginx](https://github.com/kubernetes/ingress-nginx) deployment specifically crafted to work with kind.
All other components setup should not be kind specific but may require different configuration depending on the target cluster.

## Cluster Setup

In this first step we are going to create a local cluster using [kind](https://kind.sigs.k8s.io).

The created cluster will have two nodes, one master node and one worker node.
Note that the master node maps host ports `80` and `443` to the container node.
If those ports are already in use they can be changed by editing the `hostPort` stanza in the config manifest below.

To create the local cluster, run the following command:

```shell
kind create cluster --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |-
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
  - role: worker
EOF
```

## Ingress NGINX Setup

In order to access Grafana from our browser, we need to deploy an ingress controller.

We are going to install [ingress-nginx](https://github.com/kubernetes/ingress-nginx) with the following command:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
sleep 15
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
```

## Jaeger Setup

[Jaeger](https://www.jaegertracing.io) will allow us to store, search and visualise traces.

Jaeger is made of multiple components and is capable of using multiple storage solutions like Elasticsearch or Cassandra. In this tutorial we will deploy an all-in-one version of Jaeger and storage will be done in memory.

We can deploy Jaeger using Helm with the following command:

```shell
helm upgrade --install jaeger --namespace monitoring --create-namespace --wait \
  --repo https://jaegertracing.github.io/helm-charts jaeger \
  --values - <<EOF
storage:
  type: none
provisionDataStore:
  cassandra: false
agent:
  enabled: false
collector:
  enabled: false
query:
  enabled: false
allInOne:
  enabled: true
  ingress:
    enabled: true
    hosts:
      - localhost
EOF
```

At this point Jaeger UI should be available at http://localhost.

## Kyverno Setup

We now need to install Kyverno with tracing enabled and pointing to our Jaeger collector.

We can deploy Kyverno using Helm with the following command:

```shell
helm upgrade --install kyverno --namespace kyverno --create-namespace --wait \
  --devel --repo https://kyverno.github.io/kyverno kyverno \
  --values - <<EOF
# kyverno controller
extraArgs:
  # enable tracing
  - --enableTracing
  # jaeger backend url
  - --tracingAddress=jaeger-collector.monitoring
  # jaeger backend port for opentelemetry traces
  - --tracingPort=4317

# cleanup controller
cleanupController:
  tracing:
    # enable tracing
    enabled: true
    # jaeger backend url
    address: jaeger-collector.monitoring
    # jaeger backend port for opentelemetry traces
    port: 4317
EOF
```

## Kyverno policies Setup

Finally we need to deploy some policies in the cluster so that Kyverno can configure admission webhooks accordingly.

We are going to deploy the `kyverno-policies` helm chart (with the `Baseline` profile of PSS) using the following command:

```shell
helm upgrade --install kyverno-policies --namespace kyverno --create-namespace --wait \
  --devel --repo https://kyverno.github.io/kyverno kyverno-policies \
  --values - <<EOF
validationFailureAction: Enforce
EOF
```

Note that we are setting `validationFailureAction` to `Enforce` because `Audit`-mode policies are processed asynchronously and will produce a separate trace from the main one (both traces are linked together though, but not with a parent/child relationship).

## Create a Pod and observe the corresponding trace

With everything in place we can exercise the Kyverno admission webhooks by creating a Pod and locating the corresponding trace in Jaeger.

Run the following command to create a Pod:

```shell
kubectl run nginx --image=nginx
```

After that, navigate to the [Jaeger UI](http://localhost) and search for traces with the following criteria:
- Service: `kyverno`, every trace defines a service name and all traces coming from Kyverno will use the `kyverno` service name
- Operation: `ADMISSION POST /validate/fail`, every span defines a span name and root spans created by Kyverno when receiving an admission request have their name computed from the http operation and path (`ADMISSION <HTTP OPERATION> <HTTP PATH>`. The `/validate/fail` path indicates indicates that it's a validating webhook that was configured to fail the admission request in case of error. Fail mode is the default).

The list should show the trace for the previous Pod creation request:

<p align="center"><img src="../assets/walkthrough-jaeger-1.png" height="300px"/></p>

Clicking on the trace will take you to the trace details, showing all spans covered by the Pod admission request:

<p align="center"><img src="../assets/walkthrough-jaeger-2.png" height="300px"/></p>

The trace shows individual spans of all the policies that were just installed, with child spans for every rule that was checked (but not necessarily evaluated).
The sum of all spans equals the trace time or the entire time Kyverno spent processing the Pod admission request.
