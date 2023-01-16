---
title: Tracing with Grafana Tempo
description: Tracing with Grafana Tempo.
weight: 10
---

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
