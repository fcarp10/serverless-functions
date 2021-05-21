
## Elasticsearch connector function

Elasticsearch connector function. 

Deploy and test:

```shell
faas deploy --image fcarp10/es-connect --name es-connect

curl http://127.0.0.1:8080/function/es-connect -d '{}'
```

