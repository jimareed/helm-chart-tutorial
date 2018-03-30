# collection-count
REST API to count collections.

```
$docker build --tag collection-count .
Successfully built xxxx
Successfully tagged collection-count:latest
$ docker run -d -p 8080:8080 xxxx
$ curl localhost:8080/v1/collection-count
{"count":"4"}
$ docker stop <container-id>
```

Cleanup images after done

```
docker system prune -a
```

```
helm create chart
helm install --dry-run --debug ./chart
helm install --dry-run --debug ./chart --set service.internalPort=8080
helm install --name example ./chart --set service.type=NodePort
```
```
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services example-chart)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
http://192.168.65.3:32120

(change to localhost)
http://localhost:32120/
```
Edit values.yaml
```
image:
  repository: jimareed/collection-count
  tag: latest

  service:
    type: ClusterIP
    port: 8080  
```

```
helm install --name example2 ./chart --set service.type=NodePort
```
