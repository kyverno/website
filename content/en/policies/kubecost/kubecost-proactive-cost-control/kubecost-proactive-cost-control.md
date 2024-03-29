---
title: "Kubecost Proactive Cost Control"
category: Kubecost
version: 1.11.0
subject: Deployment
policyType: "validate"
description: >
    Kubecost Enterprise allows users to define budgets for Namespaces and clusters as well as predict the cost of new Deployments based on historical cost data. By combining these abilities, users can achieve proactive cost controls for clusters with Kubecost installed by denying Deployments which would exceed the remaining configured monthly budget, if applicable. This policy checks for the creation of Deployments and compares the predicted cost of the Deployment to the remaining amount in the monthly budget, if one is found. If the predicted cost is greater than the remaining budget, the Deployment is denied. This policy requires Kubecost Enterprise at a version of 1.108 or greater.
---

## Policy Definition
<a href="https://github.com/kyverno/policies/raw/main//kubecost/kubecost-proactive-cost-control/kubecost-proactive-cost-control.yaml" target="-blank">/kubecost/kubecost-proactive-cost-control/kubecost-proactive-cost-control.yaml</a>

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: kubecost-proactive-cost-control
  annotations:
    policies.kyverno.io/title: Kubecost Proactive Cost Control
    policies.kyverno.io/category: Kubecost
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Deployment
    policies.kyverno.io/minversion: 1.11.0
    kyverno.io/kyverno-version: 1.11.4
    kyverno.io/kubernetes-version: "1.26"
    policies.kyverno.io/description: >-
      Kubecost Enterprise allows users to define budgets for Namespaces and clusters
      as well as predict the cost of new Deployments based on historical cost data.
      By combining these abilities, users can achieve proactive cost controls for
      clusters with Kubecost installed by denying Deployments which would exceed the
      remaining configured monthly budget, if applicable. This policy checks for the creation of
      Deployments and compares the predicted cost of the Deployment to the remaining amount
      in the monthly budget, if one is found. If the predicted cost is greater than the remaining
      budget, the Deployment is denied. This policy requires Kubecost Enterprise
      at a version of 1.108 or greater.
spec:
  validationFailureAction: Audit
  rules:
  - name: enforce-monthly-namespace-budget
    match:
      any:
      - resources:
          kinds:
          - Deployment
          operations:
          - CREATE
    # First, check if this Namespace is subject to a budget.
    # If it is not, always allow the Deployment.
    preconditions:
      all:
      - key: "{{ budget }}"
        operator: NotEquals
        value: nobudget
    context:
    # Get the budget of the destination Namespace. Select the first budget returned which matches the Namespace.
    # If no budget is found, set budget to "nobudget".
    - name: budget
      apiCall:
        method: GET
        service:
          url: http://kubecost-cost-analyzer.kubecost:9090/model/budgets
        jmesPath: "data[?values.namespace[?contains(@,'{{ request.namespace }}')]] | [0] || 'nobudget'"
    # Call the prediction API and pass it the Deployment from the admission request. Extract the totalMonthlyRate.
    - name: predictedMonthlyCost
      apiCall:
        method: POST
        data:
        - key: apiVersion
          value: "{{ request.object.apiVersion }}"
        - key: kind
          value: "{{ request.object.kind }}"
        - key: spec
          value: "{{ request.object.spec }}"
        service:
          url: http://kubecost-cost-analyzer.kubecost:9090/model/prediction/speccost?clusterID=cluster-one&defaultNamespace=default
        jmesPath: "[0].costChange.totalMonthlyRate"
    # Calculate the budget that remains from the window by subtracting the currentSpend from the spendLimit.
    - name: remainingBudget
      variable:
        jmesPath: subtract(budget.spendLimit,budget.currentSpend)
    validate:
      message: >-
        This Deployment, which costs ${{ round(predictedMonthlyCost, `2`) }} to run for a month,
        will overrun the remaining budget of ${{ round(remainingBudget,`2`) }}. Please seek approval or request
        a Policy Exception.
      # Deny the request if the predictedMonthlyCost is greater than the remainingBudget.
      deny:
        conditions:
          all:
          - key: "{{ predictedMonthlyCost }}"
            operator: GreaterThan
            value: "{{ remainingBudget }}"

```
