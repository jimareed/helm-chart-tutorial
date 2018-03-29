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
