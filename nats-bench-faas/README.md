
## NATS bench function

Go function that implements `nats-bench`

Deploy and test:

```
faas deploy --image fcarp10/nats-bench-faas --name nats-bench-faas
curl http://127.0.0.1:8080/function/nats-bench-faas -d `{"url":"nats://demo.nats.io","subj":"topic-1","msg":"hello world!"}`
```

