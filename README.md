# helm-chart-tutorial

This tutorial will walk through the following:
- create a helm chart and deploy a local docker image to your kubernetes cluster
- wire up two services to talk to each other

**Prerequisites**: install docker, kubernetes and helm and clone repo.

![Docker Compose To Helm](./tutorial.png)


Build the docker image locally which contains two services:
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
$ curl localhost:8080/items
[{"item":"apple"}, {"item":"orange"}, {"item":"pear"}]
$ curl localhost:8081/count
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
NAME                                                      READY     STATUS              RESTARTS   AGE
count-77fc7b58c9-7rrb4                                    0/1       Running             3          2m
items-8694fb7d76-595fx                                    0/1       CrashLoopBackOff    5          5m
```
port forward items service to test it:
```
$ kubectl port-forward items-8694fb7d76-595fx 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
```
open a new terminal session to try it out:
```
$curl localhost:8080/items
[{"item":"apple"}, {"item":"orange"}, {"item":"pear"}]
```
Now port forward the count service (after stopping the port forward of the items service):
```
$ kubectl port-forward count-77fc7b58c9-7rrb4 8080:8080
Forwarding from 127.0.0.1:8081 -> 8080
```
open a new terminal session and see that count is failing because we haven't connected the two services yet in Kubernetes:
```
$curl localhost:8080/count
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
          value: "http://items:8080"
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
**This part doesn't work yet, not sure what I'm doing wrong**
```
$ kubectl port-forward count-7ff6dff965-czwpz 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
(from a new terminal session)
$curl localhost:8080/count
http://items:8080/items error executing request
```


Clean up after done
```
$ helm delete items
release "items" deleted
$ helm del --purge items
release "items" deleted
$ helm delete count
release "count" deleted
$ helm del --purge count
release "count" deleted
```
