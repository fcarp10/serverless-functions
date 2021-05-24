
## Elasticsearch connector function

Elasticsearch connector function. 

Deploy and test:

```shell
faas deploy --image fcarp10/es-connect --name es-connect
```

Indexing documents example:

```shell
curl http://127.0.0.1:8080/function/es-connect -d '{"url":"http://10.42.0.18:9200/","index":"123","documentID":"1", "doc":{"key_ex":"value_ex"}}'
```

Querying example:

```shell
curl http://127.0.0.1:8080/function/es-connect -d '{"url":"http://10.42.0.18:9200/","index":"123", "query":{"query":{"match":{"key_ex":"value_ex"}}}}'
```

