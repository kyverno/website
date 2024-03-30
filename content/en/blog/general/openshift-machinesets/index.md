---
date: 2023-07-28
title: "Simplifying OpenShift MachineSet Management Using Kyverno"
linkTitle: "Simplifying OpenShift MachineSet Management Using Kyverno"
author: Andrew Block
description: "Using Kyverno to mutate OpenShift MachineSet resources for easier automation."
---

_(Guest post from Red Hat Distinguished Architect, [Andrew Block](https://twitter.com/sabre1041))_

Managing infrastructure in a declarative fashion is one of the core principles that should be adopted when operating in any environment. In OpenShift, this paradigm for managing the underlying Node infrastructure is accomplished using the [Machine API](https://docs.openshift.com/container-platform/4.13/machine_management/index.html). This extension of the upstream [Cluster API project](https://cluster-api.sigs.k8s.io/) enables the provisioning and management of instances once the OpenShift cluster finishes deploying.

While Machines are individual hosts provisioned as Nodes, cluster administrators typically interact with them via an abstraction -- a MachineSet. A MachineSet represents a group of compute instances that not only share similar traits, such as the definition of the desired cloud provider, but they can be scaled based on the desired number of instances.

While MachineSets provide a mechanism for managing Machines at scale and represent a set of purpose-built instances within an OpenShift environment, there are limitations that inhibit one from being able to fully manage them declaratively.

## Challenges Surrounding Declarative MachineSets

MachineSets are used within OpenShift in environments which are integrated with a cloud provider, such as Amazon Web Services, Microsoft Azure, and VMware vSphere. Even though there are specific differences as they relate to the individual provider being used, the remainder of the MachineSet definition is the same.

The following is an example of a MachineSet that could be used to represent OpenShift Infrastructure nodes:

```yaml
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: <infrastructure_id> 
    machine.openshift.io/cluster-api-machine-role: infra 
    machine.openshift.io/cluster-api-machine-type: infra 
  name: <infrastructure_id>-infra 
  namespace: openshift-machine-api
spec:
  replicas: 1
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: <infrastructure_id> 
      machine.openshift.io/cluster-api-machineset: <infrastructure_id>-infra 
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: <infrastructure_id> 
        machine.openshift.io/cluster-api-machine-role: infra 
        machine.openshift.io/cluster-api-machine-type: infra
        machine.openshift.io/cluster-api-machineset: <infrastructure_id>-infra
    spec:
      metadata:
        labels:
          node-role.kubernetes.io/infra: ""
      providerSpec:
        # Provider specific implementation
        ...
```

While the majority of the MachineSet definition is straightforward, notice the placeholder value denoted by <infrastructure_id>. An OpenShift Infrastructure ID refers to the cluster ID and is a value that is generated at cluster installation that contains the name of the cluster appended by a randomly generated value. Since this value is distinct per cluster, it becomes a challenge to specify the MachineSet definition which could be managed via GitOps prior to cluster creation as one would not be able to ascertain the generated cluster ID.

Several workarounds have been implemented within the community to address this challenge and range from populating GitOps repositories dynamically as the cluster is being provisioned, to a [dedicated operator](https://github.com/noseka1/gitops-friendly-machinesets-operator) which dynamically updates the MachineSet after it is created. However, instead of leveraging a workaround or needing to deploy an operator just to inject a single property, other options should be considered.

## Overcoming MachineSet Limitations Using Kyverno

Even though these approaches described in the prior section do work, they either require additional processes to be performed or limit the types of GitOps management styles that can be implemented. Wouldn’t it be great if the contents of a MachineSet were updated as they are created in the cluster without either having to change how the MachineSet definitions are managed via GitOps or retroactively updating the MachineSet within the cluster after they are created? Fortunately, this challenge related to Infrastructure IDs can be overcome thanks to Kyverno!

Kyverno is a policy engine for Kubernetes that can be used to validate, mutate, generate, and cleanup Kubernetes resources as well as verify container images. Similar to most policy engines for Kubernetes, Kyverno makes use of Validating and Mutating Admission webhooks which enable the introspection of resources prior to being persisted within etcd.

So, given that Kyverno could be used to solve this challenge, what would this look like? Many of the other workarounds including those mentioned previously make use of looking up the Cluster ID from the value stored within the cluster. The Infrastructure ID is stored within a Custom Resource called Infrastructure which includes infrastructure-related details specific to the cluster. The Infrastructure ID can be retrieved by those with elevated cluster level access by executing the following command:

```sh
$ oc get -o jsonpath='{.status.infrastructureName}{"\n"}' infrastructure cluster
```

With an understanding how to obtain the required information from the cluster, let’s see how Kyverno can be used to retrieve the Infrastructure ID from the cluster and inject it within the MachineSet as it is created.

Kyverno policies can make use of variables that are retrieved from the results from invoking [Kubernetes API service calls](/docs/writing-policies/external-data-sources/#variables-from-kubernetes-api-server-calls). Given that the resource and the particular property within the resource is known containing the Infrastructure ID, the following in a context can be used to query the Infrastructure resource from within the cluster and set the variable named infraid based on the JMESPath expression for the obtained resource containing the Infrastructure ID:

```yaml
context:
- name: cluster
    apiCall:
    urlPath: /apis/config.openshift.io/v1/infrastructures/cluster
- name: infraid
    variable:
    jmesPath: cluster.status.infrastructureName
```

Notice how the jmesPath field references the cluster variable which represents the result from the API service call. Traversing through the data structure enables accessing the Infrastructure ID found within the infrastructureName property.

Now that Infrastructure ID has been assigned to a variable, the next step is to take this variable and inject it into the incoming MachineSet resource. Modifications to resources in Kyverno are achieved using one or more [mutation rules](/docs/writing-policies/mutate/). Mutations can leverage either a RFC 6902 JSON Patch or a strategic merge patch. While a JSON patch does provide the ability to perform fine-grained modification of resources, as shown in the MachineSet example in a prior section, the Infrastructure ID has the potential to be located at varying locations within the MachineSet definition. To manage a dynamic set of Infrastructure ID parameters regardless of their locations within a MachineSet, the Kyverno-specific [replace_all](/docs/writing-policies/jmespath/#replace_all) filter can be used to accomplish this task.

```yaml
mutate:
  patchesJson6902: |-
    - op: replace
      path: /metadata
      value: {{ replace_all(to_string(request.object.metadata),'TEMPLATE', infraid) }}
    - op: replace
      path: /spec
      value: {{ replace_all(to_string(request.object.spec),'TEMPLATE', infraid) }}
```

The mutate rules above specify that all instances of the word “TEMPLATE” that are found within the spec and metadata properties of a MachineSet will be replaced by the infraid variable that was specified earlier.

Putting all of the pieces together, the final ClusterPolicy resource is shown below:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: inject-infrastructurename
  annotations:
    policies.kyverno.io/title: Inject Infrastructure Name
    policies.kyverno.io/category: OpenShift
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.10.0
    policies.kyverno.io/minversion: 1.10.0
    kyverno.io/kubernetes-version: "1.26"
    policies.kyverno.io/subject: MachineSet
    policies.kyverno.io/description: >-
      A required component of a MachineSet is the infrastructure name which is a random string
      created in a separate resource. It can be tedious or impossible to know this for each
      MachineSet created. This policy fetches the value of the infrastructure name from the
      Cluster resource and replaces all instances of TEMPLATE in a MachineSet with that name.
spec:
  schemaValidation: false
  rules:
  - name: replace-template
    match:
      any:
      - resources:
          kinds:
          - machine.openshift.io/v1beta1/MachineSet
          operations:
          - CREATE
    context:
    - name: cluster
      apiCall:
        urlPath: /apis/config.openshift.io/v1/infrastructures/cluster
    - name: infraid
      variable:
        jmesPath: cluster.status.infrastructureName
    mutate:
      patchesJson6902: |-
        - op: replace
          path: /metadata
          value: {{ replace_all(to_string(request.object.metadata),'TEMPLATE', infraid) }}
        - op: replace
          path: /spec
          value: {{ replace_all(to_string(request.object.spec),'TEMPLATE', infraid) }}
```

Assuming Kyverno is deployed to your OpenShift cluster, the ClusterPolicy can be added to enable the desired MachineSet functionality. All that needs to be done now is to update your existing MachineSet manifests that you have specified declaratively, such as in a GitOps repository, and replace the hard-coded Infrastructure ID with the word TEMPLATE. You are free to choose a word other than TEMPLATE to represent the value that should be replaced by the Infrastructure ID. When doing so, be sure to update the value in the ClusterPolicy and in the MachineSet definition. 

MachineSets offer the advantage of defining and managing a set of OpenShift Machine profiles, but require that the Cluster ID represented as the Infrastructure ID be present within the definition. Thanks to the dynamic set of capabilities provided by Kyverno, managing MachineSets within OpenShift just got a whole lot easier. The ClusterPolicy shown previously is also available on [Artifact Hub](https://artifacthub.io/packages/kyverno/kyverno-policies/inject-infrastructurename) and the [policy library](/content/en/policies/openshift/inject-infrastructurename/inject-infrastructurename.md) for easy reference and consumption.
