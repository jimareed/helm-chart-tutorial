# helm-chart-tutoral

A simple tutorial which deploys a REST service to kubernetes using helm.  

Prerequisites: install docker, kubernetes and helm

Try out the service
```
$ docker run -d -p 8080:8080 jimareed/helm-chart-tutorial
Unable to find image 'jimareed/helm-chart-tutorial:latest' locally
latest: Pulling from jimareed/helm-chart-tutorial
...
Status: Downloaded newer image for jimareed/helm-chart-tutorial:latest
5c4cd3ea9cd520800e4d914a48e978f2af1a34acbb5e8f1779e8fc571607f3cc
$ curl localhost:8080/items
[{"item":"apple"}, {"item":"orange"}, {"item":"pear"}]
$ docker ps
CONTAINER ID        IMAGE                                                            COMMAND                  CREATED             STATUS              PORTS                    NAMES
5c4cd3ea9cd5        jimareed/helm-chart-tutorial                                     "/bin/sh -c collecti…"   55 seconds ago      Up 53 seconds       0.0.0.0:8080->8080/tcp   quirky_spence
$ docker stop quirky_spence
```

Create a helm chart
```
$helm create chart
Creating chart
$ls chart
Chart.yaml	charts		templates	values.yaml
```

Edit chart/values.yaml, set the docker image and change the port
```
$vi chart/values.yaml
(make the following changes)
image:
  repository: jimareed/helm-chart-tutorial
  tag: latest

  service:
    type: ClusterIP
    port: 8080  

    hosts:
      - items.local
```

Install the chart
```
$helm install --name items ./chart
NAME:   items
LAST DEPLOYED: Fri Mar 30 19:47:30 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME         TYPE      CLUSTER-IP      EXTERNAL-IP  PORT(S)         AGE
items-chart  NodePort  10.102.252.240  <none>       8080:31555/TCP  0s

==> v1beta2/Deployment
NAME         DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
items-chart  1        1        1           0          0s

==> v1/Pod(related)
NAME                          READY  STATUS             RESTARTS  AGE
items-chart-6f4bbf47cb-4rx8f  0/1    ContainerCreating  0         0s


NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services items-chart)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

$helm ls
NAME         	REVISION	UPDATED                 	STATUS  	CHART              	NAMESPACE
item-count   	1       	Fri Mar 30 12:10:00 2018	DEPLOYED	chart-0.1.0        	default  
```

Try out the service
```
$ kubectl get pods
NAME                                                      READY     STATUS              RESTARTS   AGE
items-chart-6f4bbf47cb-4rx8f                              0/1       Running             1          1m
$ kubectl port-forward items-chart-6f4bbf47cb-4rx8f 8081:8080
Forwarding from 127.0.0.1:8081 -> 8080
(from a new terminal session)
$curl localhost:8081/items
[{"item":"apple"}, {"item":"orange"}, {"item":"pear"}]
```

Clean up after done
```
helm delete item-count
release "item-count" deleted
$ helm del --purge item-count
release "item-count" deleted
$docker system prune -a
```
