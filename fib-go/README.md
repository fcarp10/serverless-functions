
## fib-go

Recursive Fibonacci function in Go.

### Deploy and test:

```
faas deploy --image fcarp10/fib-go --name fib-go
curl http://127.0.0.1:8080/function/fib-go -d "10"
```