# OpenFaas functions

Examples of OpenFaas functions which have been updated to work with
[of-watchdog](https://github.com/openfaas/of-watchdog#1-http-modehttp) using the `http` mode.


## User guide 

### Install OpenFaas
#### Prerequisites

- curl
- arkade: `curl -sLS https://dl.get-arkade.dev | sudo sh`
- faas-cli: `curl -SLsf https://cli.openfaas.com | sudo sh`

Run the script `deploy.sh` to deploy K3s and install OpenFaas.

### Deploy and test

Example of how to deploy and test a function from the store:

    faas store deploy NodeInfo
    curl http://127.0.0.1:8080/function/nodeinfo


