---
title: "Grafana Dashboard" 
description: A ready-to-use dashboard for Kyverno metrics.
weight: 60
---

## Grafana Dashboard

### Setup

#### With Helm Chart

* If your Grafana is configured with the discovery sidecar, set `grafana.enabled` value to `true`.
* If you're using Grafana Operator, set `grafana.enabled` to `true` and `grafana.grafanaDashboard.enabled` value to `true`.

See more configuration options [here](https://github.com/kyverno/kyverno/tree/main/charts/kyverno#grafana).

#### Without Helm Chart

* Download the dashboard's JSON and save it in `kyverno-dashboard.json`

```sh
curl -fsS https://raw.githubusercontent.com/kyverno/kyverno/main/charts/kyverno/charts/grafana/dashboard/kyverno-dashboard.json -o kyverno-dashboard.json
```

* Open your Grafana portal and go to the option of importing a dashboard.

![Dashboard step 1](dashboard-first-step.png)

* Go to the "Upload JSON file" button, select the `kyverno-dashboard.json` which you got in the first step and click on Import.

![Dashboard step 2](dashboard-second-step.png)

* Configure the fields according to your preferences and click on Import.

![Dashboard step 3](dashboard-third-step.png)

* And your dashboard will be ready in front of you.

![Dashboard example 1](dashboard-example-1.png)

![Dashboard example 2](dashboard-example-2.png)

### Tutorial

```sh
kind create cluster
```

Add Helm repositories.

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 
helm repo add kyverno https://kyverno.github.io/kyverno/ 
```

Update Helm repositories.

```sh
helm repo update    
```

Install Kyverno and the kube-prometheus-stack Helm chart.

```sh
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace 
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

kubectl -n monitoring get po -l "release"
```

Create the ServiceMonitor resource.


Add the following contents to a file named `service-monitor.yaml`.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app.kubernetes.io/instance: monitoring
    chart: kube-prometheus-stack-51.2.0
    heritage: Helm
    release: monitoring
  name: service-monitor-kyverno-service
  namespace: monitoring
spec:
  endpoints:
  - interval: 60s
    path: /metrics
    scheme: http
    targetPort: 8000
    tlsConfig:
      insecureSkipVerify: true
  namespaceSelector:
    matchNames:
    - kyverno
  selector:
    matchLabels:
      app.kubernetes.io/instance: kyverno
```

Add the appropriate labels.

```sh
kubectl label ns kyverno app.kubernetes.io/instance=kyverno                                                               
kubectl label ns kyverno app.kubernetes.io/name=kyverno
```

Create the ServiceMonitor.

```sh
kubectl apply -f service-monitor.yaml
```

Restart Deployments and StatefulSets in the `monitoring` Namespace.

```sh
kubectl rollout restart deploy,sts -n monitoring
```

Check services in the `monitoring` Namespace.

```sh
kubectl get svc -n monitoring             
                                                                                                            
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
monitoring-kube-prometheus-prometheus     ClusterIP   10.96.238.189   <none>        9090/TCP,8080/TCP            4h16m
```

Port forward the `monitoring-kube-prometheus-prometheus` Service to a local port.

```sh
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 81:9090 -n monitoring                                                       

Forwarding from 127.0.0.1:81 -> 9090
Forwarding from [::1]:81 -> 9090
```

Similarly, port forward the `monitoring-grafana` Service to another local port.

```sh
kubectl get svc -n monitoring               
                                                                             
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
monitoring-grafana                        ClusterIP   10.96.188.20    <none>        80/TCP                       4h19m

kubectl port-forward svc/monitoring-grafana -n monitoring 82:3000

Forwarding from 127.0.0.1:82 -> 3000
Forwarding from [::1]:82 -> 3000
```

Go to Prometheus on port 9090 and check status -> Targets -> Filter for kyverno (to see if metrics are getting scraped)

Go to Grafana on port 3000 -> Dashboards -> New ->  import -> Upload file that you get from running the below command -> Data type = Prometheus -> import

```sh
curl https://raw.githubusercontent.com/kyverno/grafana-dashboard/master/grafana/dashboard.json -o kyverno-dashboard.json
```
