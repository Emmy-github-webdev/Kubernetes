# Overview

## Kubernetes Components
The Kubernetes cluster components includes controller plan and one or more worker nodes. The key components that make up the Kubernetes cluster includes:
1. Node: Maintains running pods and providing the kubernetes environment runtime. The node components includes.
- Kubelet: Ensure pods are running including their containers
- Kube-proxy: Maintain the network rule on node to run the service
2. Control Plan: Manages the overall state of the clouster. The components inclues:
- API Server: Exposes the kubernetes HTTP API
- Etcd: Serves as the key value store for all API server data
- Kube-Controller manager: Runs controller to implement kubernetes API behavior
- Kube-scheduler: Responsible for assiging pod to the suitable node
![](kubernetes-cluster.png)

## Container Runtime
Softwares responsible for running containers includes:
1. CRI-O - Container Runtime Interface
2. Docker Engine
3. Containerd
4. Mirantis Container Runtime

## Objects in Kubernetes
Kubernetes objects are persistent entities in kubernetes system. The entities are used by kubernetes to represent the state of the cluster.
Specifically, they can describe:
- What containerized applications are running (and on which nodes)
- The resources available to those applications
- The policies around how those applications behave, such as restart policies, upgrades, and fault-tolerance.

To work with Kubernetes objects—whether to create, modify, or delete them—you'll need to use the Kubernetes API.For example ``kubectl``, ``Client libraries``.

Here's an example manifest that shows the required fields and object spec for a Kubernetes Deployment:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80

```
### Required field
In the manifest (YAML or JSON file) for the kubernetes object you want to create, you will need to set values for the following fields:
- _apiVersion_: Specify the version of Kubernetes you are using to create this opject
- _kind_: Specify the kind of object you want to create
- _metadata_: Specify the data that help uniquely identify the object e.g _name_, _UID_, and _namespace_ (optional)
- _spec_: Specify the state you desire for the object

### Server side field validation
The API server offers server side field validation that detects unrecognized or duplicate fileds in an object.

The ``kubectl`` tools uses the ``--validate`` flag to set the level of field validation. It accepts
- _true_ equivalent to _strict_: strict field validation, errors on validation failure
- _false_ equivalent to _ignore_: No server side field validation is performed
- _warn_: Errors are exposed as wanings rather than failing the request
The default validation setting for ``kubectl`` is ``--validation`` is ``--validation=true``.

## Pod
A Pod in Kubernetes is the smallest and simplest unit that Kubernetes runs. Think of a Pod like a small box that holds one or more containers that work together.

A Pod is a group of one or more containers, with shared storage and network resources, and a specification for how to run the containers.

Pods in a kubernetes clusters are used in two ways:
1. _Pods that run a single container_
2. _Pods that runs multiple containers that need to work together_

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```