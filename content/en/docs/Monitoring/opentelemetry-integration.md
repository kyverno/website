---
title: Opentelemetry Integration
description: Kyverno is instrumented with the Opentelemetry SDK. This helps us currently in exposing metrics and traces to an Opentelemetry Collector. This guide will show you how to set up a simple Opentelemetry Collector as a deployment and export Kyverno Metrics and Traces to it. This is just an example and must not be used in production.
weight: 65
---

## Opentelemetry Setup

We will work with a few yaml files are configurations to setup our collector in the kyverno namespace. The required configurations are listed below.

### Config file for Opentelemetry Collector

Create a ```configmap.yaml``` with the following content:
```yaml
---
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
- Here the prometheus exporter endpoint is set as **9090** which means prometheus will be able to scrape this service on the given endpoint to collect metrics.
- Similarly jaeger endpoint references a jaeger collector (at the default jaeger endpoint **14250**)


### The Collector Deployment

Create a ```deployment.yaml``` with the following content:
```yaml
---
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

This references the ```collector.yaml``` defined in configmap.yaml. Here we are using just a single replica. Ideally we will want a **Daemonset**. Check the Opentelemetry documentation for more deployment strategies.


### The Collector Service

Finally create a ```service.yaml``` with the following content:
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

This defined a service for the discovery of the collector deployment.


### Setting up Kyverno and passing required flags

In the ```install.yaml``` for Kyverno. 
- Pass the flag ```metricsPort``` to defined the Opentelemetry Collector endpoint for collecting metrics.
- Pass the flag ```otelConfig=grpc``` to export the metrics and traces to an opentelemetry collector on the metrics port endpoint


### Setting up a secure connection between Kyverno and the Collector

Kyverno also supports setting up a secure connection with the Opentelemetry Exporter using TLS on server-side (on the Collector). This will require you to create a certificate-key pair for the Opentelemetry Collector from some private CA and then saving these CA cert as a secret in your Kyverno namespace as with key as ```ca.pem```.

Considering you already have the server.pem and server-key.pem files along with the ca.pem file (you can configure these using a tool such as openssl or cfssl). Your Opentelmetry ```configmap.yaml``` and ```deployment.yaml``` will also change accordingly:

**configmap.yaml**
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

**deployment.yaml**

```yaml
---
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

This will ensure that Opentelemetry Collector only accept encrypted data on the receiver endpoint. 

Pass the flag ```transportCreds``` as the secret name containing the "ca.pem" file (Empty string means insecure connection will be used).

### Setting up Prometheus

- For the metrics backend you can install Prometheus on you cluster. For a general example we have a ready-made configuration for you. Install Promethues by running:

```kubectl apply -k github.com/kyverno/grafana-dashboard/examples/prometheus```

- Port-forward the Prometheus service to view the metrics on localhost.


### Setting up Jaeger

The traces are pushed to the Jaeger backend on port **14250**. To install Jaeger:

- First install the Jaeger Operator

```shell
kubectl create namespace observability
kubectl create -n observability -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.33.0/jaeger-operator.yaml
kubectl wait --for=condition=Available deployment --timeout=2m -n observability --all
```

- Then create a Jaeger resource configuration as shown below 
jaeger.yaml

```yaml
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger
  namespace: observability
```

- Install the Jaeger backend as
```shell
kubectl create -f jaeger.yaml
```

- Port-forward jaeger service on **16686** to view the traces.