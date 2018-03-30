# helm-chart-tutoral

A simple tutorial which deploys a simple REST service to kubernetes using helm.  

Try out the service
```
$ docker run -d -p 8080:8080 jimareed/helm-chart-tutorial
$ curl localhost:8080/test
[{"count":"4"}]
$ docker ps
$ docker stop <container-name>
```

Create a helm chart
```
$helm create chart
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
```

Install the chart
```
$helm install --name item-count ./chart --set service.type=NodePort
$helm ls
NAME         	REVISION	UPDATED                 	STATUS  	CHART              	NAMESPACE
item-count   	1       	Fri Mar 30 12:10:00 2018	DEPLOYED	chart-0.1.0        	default  
```

Try out the service
```
$ kubectl get pods
NAME                                                      READY     STATUS              RESTARTS   AGE
item-count-chart-5b99897f5f-k44vm                         0/1       Running             8          16m
$kubectl port-forward item-count-chart-5b99897f5f-k44vm 8081:8080
Forwarding from 127.0.0.1:8081 -> 8080
(from a new terminal session)
$curl localhost:8081
[{"count":"4"}]
```

Clean up after done
```
helm delete item-count
release "item-count" deleted
$ helm del --purge item-count
release "item-count" deleted
$docker system prune -a
```
