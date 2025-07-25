---
title: OpenTelemetry
description: OpenTelemetry integration in Kyverno.
weight: 61
---

## OpenTelemetry Setup

Setting up OpenTelemetry requires configuration of a few YAML files. The required configurations are listed below.

### Install Cert-Manager

Install Cert-Manager by following the [documentation](https://cert-manager.io/docs/installation/).

### Config file for OpenTelemetry Collector

Create a `configmap.yaml` file in the `kyverno` Namespace with the following content:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: collector-config
  namespace: kyverno
data:
  collector.yaml: |
    receivers:
      otlp:
        protocols: 
          grpc:
            endpoint: ":8000"
    processors:
      batch:
        send_batch_size: 10000
        timeout: 5s
    extensions:
      health_check: {}
    exporters:
      jaeger:
        endpoint: "jaeger-collector.observability.svc.cluster.local:14250"
        tls:
          insecure: true
      prometheus:
        endpoint: ":9090"
      logging:
        loglevel: debug
    service:
      extensions: [health_check]
      pipelines:
        traces:
          receivers: [otlp]
          processors: []
          exporters: [jaeger, logging]
        metrics:
          receivers: [otlp]
          processors: [batch]
          exporters: [prometheus, logging]
```

- Here the Prometheus exporter endpoint is set as 9090 which means Prometheus will be able to scrape this service on the given endpoint to collect metrics.
- Similarly, the Jaeger endpoint references a Jaeger collector at the default Jaeger endpoint 14250.

### The Collector Deployment

Create a `deployment.yaml` file in the `kyverno` Namespace with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opentelemetrycollector
  namespace: kyverno
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: opentelemetrycollector
  template:
    metadata:
      labels:
        app.kubernetes.io/name: opentelemetrycollector
    spec:
      containers:
      - name: otelcol
        args:
        - --config=/conf/collector.yaml
        image: otel/opentelemetry-collector:0.50.0
        volumeMounts:
        - name: collector-config
          mountPath: /conf
      volumes:
      - configMap:
          name: collector-config
          items:
          - key: collector.yaml
            path: collector.yaml
        name: collector-config
```

This references the collector defined in the `configmap.yaml` above. Here we are using a Deployment with just a single replica. Ideally, a DaemonSet is preferred. Check the [OpenTelemetry documentation](https://opentelemetry.io/docs/instrumentation/go/getting-started) for more deployment strategies.

### The Collector Service

Finally, create a `service.yaml` file in the `kyverno` Namespace with the following content:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: opentelemetrycollector
  namespace: kyverno
spec:
  ports:
  - name: otlp-grpc
    port: 8000
    protocol: TCP
    targetPort: 8000
  - name: metrics
    port: 9090
    protocol: TCP
    targetPort: 9090
  selector:
    app.kubernetes.io/name: opentelemetrycollector
  type: ClusterIP
```

This defines a Service for the discovery of the collector Deployment.

### Setting up Kyverno and passing required flags

See the [installation instructions](/docs/installation/_index.md) for Kyverno. Depending on the method used, the following flags must be passed.

- Pass the flag `metricsPort` to defined the OpenTelemetry Collector endpoint for collecting metrics.
- Pass the flag `otelConfig=grpc` to export the metrics and traces to an OpenTelemetry collector on the metrics port endpoint

### Setting up a secure connection between Kyverno and the collector

Kyverno also supports setting up a secure connection with the OpenTelemetry exporter using TLS on the server-side (on the collector). This will require you to create a certificate-key pair for the OpenTelemetry collector from some private CA and then saving the certificate as a Secret in your Kyverno Namespace with key named `ca.pem`.

Considering you already have the `server.pem` and `server-key.pem` files along with the `ca.pem` file (you can configure these using a tool such as OepnSSL or cfssl). Your OpenTelemetry `configmap.yaml` and `deployment.yaml` files will also change accordingly:

`configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: collector-config
  namespace: kyverno
data:
  collector.yaml: |
    receivers:
      otlp:
        protocols: 
          grpc:
            endpoint: ":8000"
            tls:
              cert_file: /etc/ssl/certs/server/server.pem
              key_file: /etc/ssl/certs/server/server-key.pem
              ca_file: /etc/ssl/certs/ca/ca.pem
    processors:
      batch:
        send_batch_size: 10000
        timeout: 5s
    extensions:
      health_check: {}
    exporters:
      jaeger:
        endpoint: "jaeger-collector.observability.svc.cluster.local:14250"
        tls:
          insecure: true
      prometheus:
        endpoint: ":9090"
      logging:
        loglevel: debug
    service:
      extensions: [health_check]
      pipelines:
        traces:
          receivers: [otlp]
          processors: []
          exporters: [jaeger, logging]
        metrics:
          receivers: [otlp]
          processors: [batch]
          exporters: [prometheus, logging]
```

`deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opentelemetrycollector
  namespace: kyverno
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: opentelemetrycollector
  template:
    metadata:
      labels:
        app.kubernetes.io/name: opentelemetrycollector
    spec:
      containers:
      - name: otelcol
        args:
        - --config=/conf/collector.yaml
        image: otel/opentelemetry-collector:0.50.0
        volumeMounts:
        - name: collector-config
          mountPath: /conf
        - name: otel-collector-secrets
          mountPath: /etc/ssl/certs/server
        - name: root-ca
          mountPath: /etc/ssl/certs/ca
      volumes:
      - configMap:
          name: collector-config
          items:
          - key: collector.yaml
            path: collector.yaml
        name: collector-config
      - secret:
          secretName: otel-collector-secrets
        name: otel-collector-secrets
      - secret:
          secretName: root-ca
        name: root-ca
```

This will ensure that the OpenTelemetry collector can only accept encrypted data on the receiver endpoint.

Pass the flag `transportCreds` as the Secret name containing the `ca.pem` file (Empty string means insecure connection will be used).

### Setting up Prometheus

- For the metrics backend, you can install Prometheus on you cluster. For a general example, we have a ready-made configuration for you. Install Prometheus by running:

```sh
kubectl apply -k github.com/kyverno/grafana-dashboard/examples/prometheus
```

- Port-forward the Prometheus service to view the metrics on localhost.

```sh
kubectl port-forward svc/prometheus-server 9090:9090 -n kyverno
```

### Setting up Jaeger

The traces are pushed to the Jaeger backend on port 14250. To install Jaeger:

First install the Jaeger Operator. Replace the version as needed.

```sh
kubectl create namespace observability
kubectl create -n observability -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.33.0/jaeger-operator.yaml
kubectl wait --for=condition=Available deployment --timeout=2m -n observability --all
```

Create a Jaeger resource configuration as shown below

`jaeger.yaml`

```yaml
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger
  namespace: observability
```

Install the Jaeger backend

```sh
kubectl create -f jaeger.yaml
```

Port-forward the Jaeger Service on 16686 to view the traces.

```sh
kubectl port-forward svc/jaeger-query 16686:16686 -n observability
```
