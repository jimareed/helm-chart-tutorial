# helm-chart-tutorial

This tutorial will walk through the following:
- create a helm chart and deploy a local docker image to your Kubernetes cluster
- wire up two services to talk to each other

**Prerequisites**: install docker, Kubernetes and helm and clone repo.

![Docker Compose To Helm](./tutorial.png)

Developing and testing a microservice doesn't require Kubernetes.  A lot of developers are using docker-compose to setup a simple docker development environment.  This tutorial starts at the point where you have completed development of your microservice and now you want integrate and test it with other services in Kubernetes.  Here are the steps to build, test and deploy two services (that talk to each other) in Kubernetes using Helm.

Start by building the docker image locally which contains two services:
```
$ make build-docker
./build-docker.sh helm-chart-tutorial latest Dockerfile
Sending build context to Docker daemon  564.7kB
Step 1/19 : FROM golang:1.10-alpine AS builder
1.10-alpine: Pulling from library/golang
ff3a5c916c92: Already exists
f32d2ea73378: Pull complete
dbfec4c268d3: Pull complete
...Successfully built 9bbd346d2575
Successfully tagged helm-chart-tutorial:latest
```
Try out the services in Docker:
```
$ docker-compose up -d
Creating network "helmcharttutorial_default" with the default driver
Creating items ... done
Creating count ... done
```
```
$ curl localhost:8081/items
[{"item":"apple"}, {"item":"orange"}, {"item":"pear"}]
$ curl localhost:8082/count
{"count":"3"}
```
```
$ docker-compose down
Stopping count ... done
Stopping items ... done
Removing count ... done
Removing items ... done
```
Now we will create helm charts and deploy to Kubernetes.
First, create the helm charts:
```
$mkdir charts
$cd charts
$helm create items
Creating items
$helm create count
Creating count
$ls items
Chart.yaml	charts		templates	values.yaml
```

Edit values.yaml, set the docker image and change the port:
```
$vi items/values.yaml
(make the following changes)
image:
  repository: helm-chart-tutorial
  tag: latest

  service:
    type: ClusterIP
    port: 8080  
```
```
$vi count/values.yaml
(make the following changes)
image:
  repository: helm-chart-tutorial
  tag: latest

  service:
    type: ClusterIP
    port: 8080  
```

Edit deployment.yaml, set the containerPort:
```
$vi count/templates/deployment.yaml
(make the following changes)
              containerPort: {{ .Values.service.port }}
```
```
$vi items/templates/deployment.yaml
(make the following changes)
              containerPort: {{ .Values.service.port }}
```


Install the charts:
```
$ helm install --name items ./items
NAME:   items
LAST DEPLOYED: Mon Apr  2 15:19:50 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME   TYPE       CLUSTER-IP   EXTERNAL-IP  PORT(S)   AGE
items  ClusterIP  10.107.6.71  <none>       8080/TCP  0s

==> v1beta2/Deployment
NAME   DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
items  1        1        1           0          0s

==> v1/Pod(related)
NAME                   READY  STATUS   RESTARTS  AGE
items-978c7c9b8-5s9dg  0/1    Pending  0         0s


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=items,release=items" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80
```
```
$ helm install --name count ./count
NAME:   count
LAST DEPLOYED: Mon Apr  2 15:20:09 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)   AGE
count  ClusterIP  10.108.209.188  <none>       8080/TCP  0s

==> v1beta2/Deployment
NAME   DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
count  1        1        1           0          0s

==> v1/Pod(related)
NAME                    READY  STATUS   RESTARTS  AGE
count-749f87dfd5-6h4hh  0/1    Pending  0         0s


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=count,release=count" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80
```
```
$helm ls
NAME         	REVISION	UPDATED                 	STATUS  	CHART              	NAMESPACE
count        	1       	Sun Apr  1 09:39:07 2018	DEPLOYED	count-0.1.0        	default  
items        	1       	Sun Apr  1 09:36:21 2018	DEPLOYED	items-0.1.0        	default  
```

Try out the service:
```
$ kubectl get pods
NAME                     READY     STATUS    RESTARTS   AGE
count-7b96855cd9-dhqbp   1/1       Running   0          7m
items-7b9ccd5fb8-qwlzg   1/1       Running   0          20m
```
port forward items service to test it:
```
$ kubectl port-forward items-7b9ccd5fb8-qwlzg 8081:8080
Forwarding from 127.0.0.1:8081 -> 8080
```
open a new terminal session to try it out:
```
$curl localhost:8081/items
[{"item":"apple"}, {"item":"orange"}, {"item":"pear"}]
```
Now port forward the count service (after stopping the port forward of the items service):
```
$ kubectl port-forward count-7b96855cd9-dhqbp 8082:8080
Forwarding from 127.0.0.1:8082 -> 8080
```
open a new terminal session and see that count is failing because we haven't connected the two services yet in Kubernetes:
```
$curl localhost:8082/count
/items error executing request
```

reconfigure the count service to pass the items service URL using an environment variable:
```
$vi count/templates/deployment.yaml
(make the following changes)
spec:
  containers:
    - name: {{ .Chart.Name }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      env:
        - name: ITEMS_SERVICE_URL
          value: "{{ .Values.itemsUrl }}"
```
Add itemsUrl to values.yaml.  Since the count service is running inside the Kubernetes cluster we can use the service name to lookup the host.
```
$vi count/values.yaml
(add the following line)
itemsUrl: http://items:8080
```

Upgrade the helm release to incorporate the configuration changes:
```
$ helm upgrade count ./count
Release "count" has been upgraded. Happy Helming!
LAST DEPLOYED: Tue Apr  3 09:21:24 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME   TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
count  ClusterIP  10.102.76.224  <none>       8080/TCP  35m

==> v1beta2/Deployment
NAME   DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
count  1        2        1           0          35m

==> v1/Pod(related)
NAME                    READY  STATUS   RESTARTS  AGE
count-6cb47ccd9c-wtlwz  0/1    Running  12        35m
count-7ff6dff965-czwpz  0/1    Pending  0         0s


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=count,release=count" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80
  ```

Port forward the count service, open a new terminal session and verify that the services are connected:
```
$ kubectl port-forward count-7ff6dff965-czwpz 8082:8080
Forwarding from 127.0.0.1:8082 -> 8080
(from a new terminal session)
$curl localhost:8082/count
{"count":"3"}
```


Clean up after done
```
$ helm del --purge items
release "items" deleted
$ helm del --purge count
release "count" deleted
```
