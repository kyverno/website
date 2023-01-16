---
title: Tracing with Grafana Tempo
description: Tracing with Grafana Tempo.
weight: 10
---

## Cluster Setup

TODO

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
  - role: worker
  - role: worker
EOF
```

## Ingress NGINX Setup

In order to access Grafana, we need an ingress controller, we can install `ingress-nginx` with the following command:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
sleep 15
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
```

## Grafana Setup

Setting up Grafana with Helm can be done with the following command:

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

Tempo is a tracing backend capable of receiving traces in OpenTelemetry format, it is developped and maintain by Grafana and integrates very well with it.

Setting up Tempo with Helm can be done with the following command:

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

Installing Kyverno with tracing enabled and pointing to the Tempo backend deployed above, we need to pass a couple of settings when installing the chart.

We can do it with the following command:

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

Now we can deploy the `kyverno-policies` helm chart to get a bunch of policies installed in the cluster.

```shell
helm upgrade --install kyverno-policies --namespace kyverno --create-namespace --wait \
  --devel --repo https://kyverno.github.io/kyverno kyverno-policies \
  --values - <<EOF
validationFailureAction: Enforce
EOF
```

Note that we set `validationFailureAction` to `Enforce`, this is because `Audit` policies are processed in a separate go rountine and will produce a separate trace from the main one (both traces are linked together but not with a parent/child relationship).

## Create a Pod and observe the corresponding trace

With everything in place we can create a `Pod` and find the corresponding trace in Grafana.

```shell
kubectl run nginx --image=nginx
```

After that, navigate to the [Grafana explore page](http://localhost/grafana/explore) and search for traces with `kyverno` service name and `ADMISSION POST /validate/fail` span name.

The list should show the trace for the previous `Pod` creation request:

<p align="center"><img src="../assets/walkthrough-tempo-1.png" height="300px"/></p>

Clicking on the trace will take you to the trace details, showing all spans covered by the `Pod` admission request:

<p align="center"><img src="../assets/walkthrough-tempo-2.png" height="300px"/></p>
