# Serverless functions

Repository of serverless functions ([Docker images](https://hub.docker.com/repositories/fcarp10)).

Generic functions
- `fib-fn`: calculates the recursive Fibonacci number of the specified value.
- `sleep-fn`: sleeps for a time duration specified in milliseconds.

[Here](openfaas-functions/) for OpenFaaS specific functions


### Build

Update version tags in `versions.txt`

Run `docker_build.sh -h` to print help. Example:

```shell
foo@bar:~$./docker_build.sh --user fcarp10 --image fib-fn
```