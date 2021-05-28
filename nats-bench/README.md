
## nats-bench

Go function that implements `nats-bench`. It returns the results in CSV format. 

### Deploy and test:

```shell
faas deploy --image fcarp10/nats-bench --name nats-bench

curl http://127.0.0.1:8080/function/nats-bench -d '{"url":"nats://demo.nats.io","numPubs":2,"numSubs":2, "numMsgs":10000, "msgSize":128, "topic":"benchmark"}'
```

