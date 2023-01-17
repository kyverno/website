---
title: Tracing with Grafana Tempo
description: Tracing with Grafana Tempo.
weight: 10
---

This walkthrough shows how to create a local cluster and deploy a number of components, including an ingress controller, Grafana and the Tempo backend to store traces.

On the prepared cluster we will deploy Kyverno with tracing enabled and a couple of policies.

Finally we will exercise the Kyverno webhook by creating a pod to find and examine the corresponding trace in Grafana.

Please note that this walkthrough uses KinD to create the cluster with a specific label on the control plane node.
This is necessary as we are using an `ingress-nginx` deployment specifically crafted to work with KinD.
All other components setup are not KinD specific.

## Cluster Setup

In this first step we are going to create a local cluster using KinD.

The created cluster will have two nodes, one master node and one worker node.
The master node maps host ports 80 and 443 to the container node, if those ports are already in use they can be changed by editing the `hostPort` stanza in the config manifest below.

To create the local cluster run the following command:

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

In order to access Grafana, we need to deploy an ingress controller.

We are going to install `ingress-nginx` with the following command:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
sleep 15
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
```

## Grafana Setup

Grafana is going to allow us to explore traces.

We can deploy Grafana using Helm with the following command:

```shell
helm upgrade --install grafana --namespace monitoring --create-namespace --wait \
  --repo https://grafana.github.io/helm-charts grafana \
  --values - <<EOF
adminPassword: admin
sidecar:
  enableUniqueFilenames: true
  dashboards:
    enabled: true
    searchNamespace: ALL
    provider:
      foldersFromFilesStructure: true
  datasources:
    enabled: true
    searchNamespace: ALL
grafana.ini:
  server:
    root_url: "%(protocol)s://%(domain)s:%(http_port)s/grafana"
    serve_from_sub_path: true
ingress:
  enabled: true
  path: /grafana
  hosts: []
EOF
```

At this point Grafana should be available at http://localhost/grafana (log in with `admin` / `admin`).

## Tempo Setup

Tempo is a tracing backend capable of receiving traces in OpenTelemetry format, it is developped and maintained by Grafana and integrates very well with it.

We can deploy Tempo using Helm with the following command:

```shell
helm upgrade --install tempo --namespace monitoring --create-namespace --wait \
  --repo https://grafana.github.io/helm-charts tempo \
  --values - <<EOF
tempo:
  searchEnabled: true
EOF
```

To make Tempo available in Grafana, we need to register it as a Grafana data source:

```shell
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    grafana_datasource: "1"
  name: tempo-datasource
  namespace: monitoring
data:
  tempo-datasource.yaml: |-
    apiVersion: 1
    datasources:
    - name: Tempo
      type: tempo
      access: proxy
      url: "http://tempo.monitoring:3100"
      version: 1
      isDefault: false
EOF
```

## Kyverno Setup

At this point we have a running cluster with Grafana and Tempo backend installed and we can access Grafana through an ingress controller.

We need to install Kyverno with tracing enabled and pointing to our Tempo backend.

We can deploy Kyverno using Helm with the following command:

```shell
helm upgrade --install kyverno --namespace kyverno --create-namespace --wait \
  --devel --repo https://kyverno.github.io/kyverno kyverno \
  --values - <<EOF
# kyverno controller
extraArgs:
  # enable tracing
  - --enableTracing
  # tempo backend url
  - --tracingAddress=tempo.monitoring
  # tempo backend port for opentelemetry traces
  - --tracingPort=4317

# cleanup controller
cleanupController:
  tracing:
    # enable tracing
    enabled: true
    # tempo backend url
    address: tempo.monitoring
    # tempo backend port for opentelemetry traces
    port: 4317
EOF
```

## Kyverno policies Setup

Finally we need to deploy a couple of policies in the cluster to configure the Kyverno admission webhooks.

We are going to deploy the `kyverno-policies` helm chart (using the `Baseline` profile) using the following command:

```shell
helm upgrade --install kyverno-policies --namespace kyverno --create-namespace --wait \
  --devel --repo https://kyverno.github.io/kyverno kyverno-policies \
  --values - <<EOF
validationFailureAction: Enforce
EOF
```

Note that we are setting `validationFailureAction` to `Enforce`, this is because `Audit` policies are processed asynchronously and will produce a separate trace from the main one (both traces are linked together though, but not with a parent/child relationship).

## Create a Pod and observe the corresponding trace

With everything in place we can exercise the Kyverno admission webhooks by creating a `Pod` and find the corresponding trace in Grafana.

Run the following command to create a `Pod`:

```shell
kubectl run nginx --image=nginx
```

After that, navigate to the [Grafana explore page](http://localhost/grafana/explore) and search for traces with based on the following criterias:
- Service name: `kyverno`, every trace define a service name and all traces coming from Kyverno will use the `kyverno` service name
- Span name: `ADMISSION POST /validate/fail`, every span define a span name and root spans created by Kyverno when receiving an admission request have their name computed from the http operation and path (`ADMISSION <HTTP OPERATION> <HTTP PATH>`).

Alternatively you can browse http://localhost/grafana/explore?left={"queries":[{"queryType":"nativeSearch","serviceName":"kyverno","spanName":"ADMISSION POST /validate/fail"}]}, that should open the Grafana explore page showing the search tab configured with the criterias mentioned above.

The list should show the trace for the previous `Pod` creation request:

<p align="center"><img src="../assets/walkthrough-tempo-1.png" height="300px"/></p>

Clicking on the trace will take you to the trace details, showing all spans covered by the `Pod` admission request:

<p align="center"><img src="../assets/walkthrough-tempo-2.png" height="300px"/></p>

The trace shows individual spans of all the policies that were just installed, with child spans for every rule that was checked (but not evaluated).
The sum of all spans equals the trace time or the entire time Kyverno spent processing the Pod.
