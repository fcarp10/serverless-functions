
This function forwards JSON payloads to a specific url.

Case 1: The function forwards payload to `dst` url, this process is repeated N
times which value is specified in `length`:
    
```shell
foo@bar:~$ curl http://127.0.0.1:8080/function/payload-echo -d '{"dst":"http://127.0.0.1:8080/function/payload-echo","doc":{"test":"hello world!"}, "length": 10}'
{"doc":{"test":"hello world!"},"dst":"http://127.0.0.1:8080/function/payload-echo","length":0}
```

Case 2: If no destination url is specified, then the function returns the payload:
    
```shell
foo@bar:~$ curl http://127.0.0.1:8080/function/payload-echo -d '{"test":"hello world!"}'
{"test":"hello world!"}
```

Case 3: If destination is `none`, then the function returns `{}`:
    
```shell
foo@bar:~$ curl http://127.0.0.1:8080/function/payload-echo -d '{"dst":"none", "test":"hello world!"}'
{}
```