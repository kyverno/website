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
