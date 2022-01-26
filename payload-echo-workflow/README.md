
## payload-echo-workflow

This function forwards the payload received to other endpoints.

### Deploy and test:

```shell
faas deploy --image fcarp10/payload-echo-workflow --name payload-echo-workflow
```

### Forwarding to rabbitmq (example):

```shell
curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"rburl":"amqp://user:password@rabbitmq:5672/","event_timestamp":"2021-07-27T13:19:19.923274599+02:00", "exchangerb":"amq.topic", "routingkeyrb":"logstash","doc":{"key_ex":"value_ex"}}'
```

### Forwarding to elasticsearch (example):

```shell
curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"esurl":"http://elasticsearch-master:9200", "event_timestamp":"2021-07-27T13:19:19.923274599+02:00","ides":"bench_kns", "pipees": "calculate_lag", "doces":"1" ,"doc":{"key_ex":"value_ex"}}'
```

### Forwarding to payload-echo-workflow (example):

```shell
curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"fsurl":"http://127.0.0.1:8080/function/payload-echo-workflow", "event_timestamp":"2021-07-27T13:19:19.923274599+02:00","doc":{"key_ex":"value_ex"}, "forwards": 3}'
```

### Forwarding to client (example):

```shell
curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"event_timestamp":"2021-07-27T13:19:19.923274599+02:00","doc":{"key_ex":"value_ex"}}'
```
