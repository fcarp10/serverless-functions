#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

function log {
    if [[ $1 == "IF" ]]; then
        printf "${BLUE}INFO:${NO_COLOR} %s \n" "$2"
    elif [[ $1 == "OK" ]]; then
        printf "${GREEN}SUCCESS:${NO_COLOR} %s \n" "$2"
    elif [[ $1 == "WR" ]]; then
        printf "${ORANGE}WARNING:${NO_COLOR} %s \n" "$2"
    else
        printf "${RED}FAILED:${NO_COLOR} %s \n" "$2"
    fi
}

log "IF" "checking curl, arkade, faas-cli..."
command -v curl >/dev/null 2>&1 || { log "ER" "curl not found, aborting."; exit 1; }
command -v arkade >/dev/null 2>&1 || { log "ER" "arkade not found, please install 'curl -sLS https://dl.get-arkade.dev | sudo sh', aborting."; exit 1; }
command -v faas-cli >/dev/null 2>&1 || { log "ER" "faas-cli not found, please install 'curl -SLsf https://cli.openfaas.com | sudo sh', aborting."; exit 1; }
log "OK" "tools already installed"

log "IF" "installing k3s..."
curl -sfL https://get.k3s.io | sh -
sudo chmod -R 777 /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
log "IF" "waiting for k3s to start..."
sleep 30 

log "IF" "installing openfaas..."
arkade install openfaas
log "IF" "waiting for openfaas to start..."
sleep 30 

kubectl rollout status -n openfaas deploy/gateway
kubectl port-forward -n openfaas svc/gateway 8080:8080 &
log "IF" "please wait..."
sleep 10 
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
echo -n $PASSWORD | faas-cli login --username admin --password-stdin
log "OK" "K3s and OpenFaas successfully installed"

faas-cli store deploy NodeInfo
MAX_ATTEMPTS=10
for ((i=0;i<$MAX_ATTEMPTS;i++)); do
    if [[ $(curl -o /dev/null -s -w "%{http_code}\n" http://127.0.0.1:8080/function/nodeinfo) -eq 200 ]]; then
        log "OK" "function is successfully running"
        faas-cli rm nodeinfo
        break
    else
        log "NO" "function is not running yet"
        if [[ $i -eq 10 ]] ; then
            log "NO" "exiting, some problem ocurred when deploying the function"
            break
        fi
    fi
done
