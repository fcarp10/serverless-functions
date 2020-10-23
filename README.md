## Repository of OpenFaas functions


### Installation

Prerequisites

- curl
- arkade: `curl -sLS https://dl.get-arkade.dev | sudo sh`
- faas-cli: `curl -SLsf https://cli.openfaas.com | sudo sh`

Run the script `deploy.sh` to deploy K3s and install OpenFaas.



### Build functions

Example of how to build a function:

    cd inception/
    docker build -f Dockerfile -t fcarp10/figlet .



### Deploy and test functions

Example of how to deploy and test a function from the store:

    faas-cli store deploy NodeInfo
    curl http://127.0.0.1:8080/function/nodeinfo

