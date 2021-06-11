
## payload-echo

This function returns back the string data received.

### Deploy and test:

```
faas deploy --image fcarp10/payload-echo --name payload-echo
curl http://127.0.0.1:8080/function/payload-echo -d '{"test":"hello world!","index":"123"}'
```
