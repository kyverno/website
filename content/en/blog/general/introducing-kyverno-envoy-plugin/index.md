---
date: 2024-06-04
title: Kyverno-Envoy-Plugin - Kyverno policies based authorization plugin for Envoy 
linkTitle: Kyverno-Envoy-Plugin - Kyverno policies based authorizaiton plugin for Envoy
author: Sanskar Gurdasani
description: Make external authorization easy with kyverno-envoy-plugin.
---

![Kyverno-Envoy-Plugin](logo.png)

While microservices offer benefits by breaking applications into smaller, independent parts, they also introduce new challenges offcourse microservies improve productivity of individual development. Managing service discovery, authentication, and authorization across multiple microservices can be complex. These tasks become even more intricate due to the diverse and short-lived nature of microservice environments.

As more organizations move to using microservices, there is an increasing need for separate authentication and authorization mechanisms that work across different microservices.

In this blog post, we will introduce [kyverno-envoy-plugin](https://github.com/kyverno/kyverno-envoy-plugin), how it works and you can use this version of kyverno to enforce fine-grained, context-aware access control policies with Envoy without modifying your microservice or application code.

## What is Envoy?

[Envoy](https://www.envoyproxy.io/docs/envoy/latest/intro/what_is_envoy) is a Layer 7 proxy and communication bus tailored for large-scale, modern service-oriented architectures. Starting from version 1.7.0, Envoy includes an [External Authorization filter](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/security/ext_authz_filter.html) that interfaces with an authorization service to check if the incoming request is authorized or not. This functionality allows authorization decisions to be offloaded to an external service, which can access the request context. The request context includes details such as the origin and destination of the network activity, as well as specifics of the network request (e.g., HTTP request). This information enables the external service to make a well-informed decision regarding the authorization of the incoming request processed by Envoy.

## What is Kyverno-Envoy-Plugin?

[Kyverno-envoy](https://github.com/kyverno/kyverno-envoy-plugin) plugin extends [Kyverno-json](https://kyverno.github.io/kyverno-json/latest/) with a gRPC server that implements [Envoy External Authorization API](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/security/ext_authz_filter.html). This allows you to enforce Kyverno policies on incoming and outgoing traffic in a service mesh environment, providing an additional layer of security and control over your applications. You can use this version of Kyverno to enforce fine-grained, context-aware access control policies with Envoy without modifying your microservice.

## How does this work?

In addition to the Envoy sidecar, your application pods will include a kyverno-envoy component, either as a sidecar or as a separate pod. This kyverno-envoy will be configured to communicate with the Kyverno-envoy-plugin gRPC server. When Envoy receives an API request intended for your microservice, it consults the Kyverno-envoy-plugin server to determine whether the request should be permitted.

Performing policy evaluations locally with Envoy is advantageous, as it eliminates the need for an additional network hop for authorization checks, thus enhancing both performance and availability.

The kyverno-envoy-plugin can be deployed with Envoy-based sevice meshes such as [Istio](https://istio.io/), [Gloo](https://gloo.solo.io/), [Kuma](https://kuma.io/) etc.

## Getting started 

In this blog, we will deploy the kyverno-envoy-plugin as a sidecar container next to the application container. The plugin will handle authorizing incoming requests to the application. Additionally, [documentation](https://kyverno.github.io/kyverno-envoy-plugin/dev/) is provided for deploying the plugin as a separate pod.

Before we can look at Kyverno-Envoy-Plugin we need a Kubernetes cluster. We can create a local cluster with [minikube](https://minikube.sigs.k8s.io/docs/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

### Create a local cluster

Start minikube cluster with the following command:

```sh
minikube start
```
### Install kyverno-envoy sidecar with application 

Install application with envoy and kyverno-envoy-plugin as a sidecar container.

```sh
$ kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno-envoy-plugin/main/quick_start.yaml 
```
The `applicaition.yaml` manifest defines the following resource:

- The Deployment includes an example Go application that provides information of books in the library books collection and exposes APIs to `get`, `create` and `delete` books collection. Check this out for more information about the [Go test application](https://github.com/Sanskarzz/kyverno-envoy-demos/tree/main/test-application) . 

- The Deployment also includes a kyverno-envoy-plugin sidecar container in addition to the Envoy sidecar container. When Envoy recevies API request destined for the Go test applicaiton, it will check with kyverno-envoy-plugin to decide if the request should be allowed and the kyverno-envoy-plugin sidecar container is configured to query Kyverno-json engine for policy decisions on incoming requests.

- A ConfigMap `policy-config` is used to pass the policy to kyverno-envoy-plugin sidecar in the namespace `default` where the application is deployed .

- A ConfigMap `envoy-config` is used to pass an Envoy configuration with an External Authorization Filter to direct authorization checks to the kyverno-envoy-plugin sidecar. 

- The Deployment also includes an init container that install iptables rules to redirect all container traffic to the Envoy proxy sidecar container , more about init container can be found [here](https://github.com/kyverno/kyverno-envoy-plugin/tree/main/demo/standalone-envoy/envoy_iptables)

### Make Test application accessible in the cluster .

```console 
kubectl expose deployment testapp --type=NodePort --name=testapp-service --port=8080
```
 
### Set the `SERVICE_URL` environment variable to the service's IP/port.

minikube:

```sh
export SERVICE_PORT=$(kubectl get service testapp -o jsonpath='{.spec.ports[?(@.port==8080)].nodePort}')
export SERVICE_HOST=$(minikube ip)
export SERVICE_URL=$SERVICE_HOST:$SERVICE_PORT
echo $SERVICE_URL
```
### Calling the sample test application and verify the authorization 

For convenience, we’ll want to store Alice’s and Bob’s tokens in environment variables. Here bob is assigned the admin role and alice is assigned the guest role.

```bash 
export ALICE_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjIyNDEwODE1MzksIm5iZiI6MTUxNDg1MTEzOSwicm9sZSI6Imd1ZXN0Iiwic3ViIjoiWVd4cFkyVT0ifQ.ja1bgvIt47393ba_WbSBm35NrUhdxM4mOVQN8iXz8lk"
export BOB_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjIyNDEwODE1MzksIm5iZiI6MTUxNDg1MTEzOSwicm9sZSI6ImFkbWluIiwic3ViIjoiWVd4cFkyVT0ifQ.veMeVDYlulTdieeX-jxFZ_tCmqQ_K8rwx2OktUHv5Z0"
```

The policy we passed to kyverno-envoy-plugin sidecar in the ConfigMap `policy-config` is configured to check the conditions of the incoming request and denies the request if the user is a guest and the request method is `POST` at the `/book` path.

```yaml
apiVersion: json.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
    name: checkrequest
spec:
    rules:
    - name: deny-guest-request-at-post
        assert:
        any:
        - message: "POST method calls at path /book are not allowed to guests users"
            check:
            request:
                http:
                    method: POST
                    headers:
                        authorization:
                            (split(@, ' ')[1]):
                                (jwt_decode(@ , 'secret').payload.role): admin
                    path: /book                             
        - message: "GET method call is allowed to both guest and admin users"
            check:
            request:
                http:
                    method: GET
                    headers:
                        authorization:
                            (split(@, ' ')[1]):
                                (jwt_decode(@ , 'secret').payload.role): admin
                    path: /book 
        - message: "GET method call is allowed to both guest and admin users"
            check:
            request:
                http:
                    method: GET
                    headers:
                        authorization:
                            (split(@, ' ')[1]):
                                (jwt_decode(@ , 'secret').payload.role): guest
                    path: /book               
```

Check for `Alice` which can get book but cannot create book.

```bash
curl -i -H "Authorization: Bearer "$ALICE_TOKEN"" http://$SERVICE_URL/book
```
```bash
curl -i -H "Authorization: Bearer "$ALICE_TOKEN"" -d '{"bookname":"Harry Potter", "author":"J.K. Rowling"}' -H "Content-Type: application/json" -X POST http://$SERVICE_URL/book
```
Check the `Bob` which can get book also create the book 

```bash
curl -i -H "Authorization: Bearer "$BOB_TOKEN"" http://$SERVICE_URL/book
```

```bash
curl -i -H "Authorization: Bearer "$BOB_TOKEN"" -d '{"bookname":"Harry Potter", "author":"J.K. Rowling"}' -H "Content-Type: application/json" -X POST http://$SERVICE_URL/book
```

Check on logs 
```bash
kubectl logs "$(kubectl get pod -l app=testapp -o jsonpath={.items..metadata.name})" -c kyverno-envoy-plugin -f
```
First , third and last request is passed but second request is failed.

```console 
sanskar@sanskar-HP-Laptop-15s-du1xxx:~$ kubectl logs "$(kubectl get pod -l app=testapp -n demo -o jsonpath={.items..metadata.name})" -n demo -c kyverno-envoy-plugin -f
Starting HTTP server on Port 8000
Starting GRPC server on Port 9000
Request is initialized in kyvernojson engine .
2024/04/26 17:11:42 Request passed the deny-guest-request-at-post policy rule.
Request is initialized in kyvernojson engine .
2024/04/26 17:22:11 Request violation: -> POST method calls at path /book are not allowed to guests users
 -> any[0].check.request.http.headers.authorization.(split(@, ' ')[1]).(jwt_decode(@ , 'secret').payload.role): Invalid value: "guest": Expected value: "admin"
-> GET method call is allowed to both guest and admin users
 -> any[1].check.request.http.headers.authorization.(split(@, ' ')[1]).(jwt_decode(@ , 'secret').payload.role): Invalid value: "guest": Expected value: "admin"
 -> any[1].check.request.http.method: Invalid value: "POST": Expected value: "GET"
-> GET method call is allowed to both guest and admin users
 -> any[2].check.request.http.method: Invalid value: "POST": Expected value: "GET"
Request is initialized in kyvernojson engine .
2024/04/26 17:23:13 Request passed the deny-guest-request-at-post policy rule.
Request is initialized in kyvernojson engine .
2024/04/26 17:23:55 Request passed the deny-guest-request-at-post policy rule.
```

### Configuration 

To deploy Kyverno-Envoy include the following container in your kubernetes Deployments:

```yaml
- name: kyverno-envoy-plugin
  image: sanskardevops/plugin:0.0.34
  imagePullPolicy: IfNotPresent
  ports:
    - containerPort: 8181
    - containerPort: 9000
  volumeMounts:
    - readOnly: true
  args:
    - "serve"
    - "--policy=/policies/policy.yaml"
    - "--address=:9000"
    - "--healthaddress=:8181"
  livenessProbe:
    httpGet:
      path: /health
      scheme: HTTP
      port: 8181
    initialDelaySeconds: 5
    periodSeconds: 5
  readinessProbe:
    httpGet:
      path: /health
      scheme: HTTP
      port: 8181
    initialDelaySeconds: 5
    periodSeconds: 5  
```

## Conclusion

This blog post demonstrated how the Kyverno-Envoy-Plugin can be effectively used to make external authorization decisions for incoming requests in a microservice architecture. By leveraging the power of Kyverno policies and Envoy's External Authorization filter, you can achieve fine-grained, context-aware access control without modifying your application code. This approach not only simplifies the management of security policies but also enhances the security posture of your services by ensuring that authorization checks are consistently applied across your microservices.

The Kyverno-Envoy-Plugin provides a robust solution for organizations looking to enforce policy-driven access controls in their service meshes. By following the steps outlined in this guide, you can easily deploy and configure the plugin, allowing you to take full advantage of Kyverno's policy capabilities in conjunction with Envoy's powerful proxy features.

For further exploration, you can checkout:

- 🔗 Check out the project on GitHub: https://github.com/kyverno/kyverno-envoy-plugin
- 📚 Browse the documentation: https://kyverno.github.io/kyverno-envoy-plugin



