
## payload-echo-rbes

This function forwards the payload received to either rabbitmq or elasticsearch.

### Deploy and test:

```shell
faas deploy --image fcarp10/payload-echo-rbes --name payload-echo-rbes
```

### Forwarding to rabbitmq example:

```shell
curl http://127.0.0.1:8080/function/payload-echo-rbes -d '{"rburl":"amqp://user:password@rabbitmq:5672/","event_timestamp":"2021-07-27T13:19:19.923274599+02:00", "exchangerb":"amq.topic", "routingkeyrb":"logstash","doc":{"key_ex":"value_ex"}}'
```

### Forwarding to elasticsearch example:

```shell
curl http://127.0.0.1:8080/function/payload-echo-rbes -d '{"esurl":"http://elasticsearch-master:9200", "event_timestamp":"2021-07-27T13:19:19.923274599+02:00","ides":"bench_kns", "pipees": "calculate_lag", "doces":"1" ,"doc":{"key_ex":"value_ex"}}'
```

### Echo example:

```shell
curl http://127.0.0.1:8080/function/payload-echo-rbes -d '{"event_timestamp":"2021-07-27T13:19:19.923274599+02:00","doc":{"key_ex":"value_ex"}}'
```
