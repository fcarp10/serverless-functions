
## hello-world

Function in bash that returns `Hello World!` string.

### Deploy and test:

```
faas deploy --image fcarp10/hello-world --name hello-world
curl http://127.0.0.1:8080/function/hello-world
```