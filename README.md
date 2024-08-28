# Serverless functions

Repository of serverless functions ([Docker images](https://hub.docker.com/repositories/fcarp10)).

Generic functions
- `hello-world`: replies with the string "Hello, World!" (HTTP GET).
- `fib-fn`: calculates the recursive Fibonacci number of the specified value.
- `payload-echo`: replies with whatever string is sent to it.
- `payload-recv`: receives whatever string is sent to it and replies with HTTP 200.
- `sleep-fn`: sleeps for a time duration specified in milliseconds.

[Here](openfaas-functions/) for OpenFaaS specific functions


### Build

Update version tags in `versions.txt`

Run `docker_build.sh -h` to print help. Example:

```shell
foo@bar:~$./docker_build.sh --user fcarp10 --image fib-fn
```
