#!/bin/bash

###############################################################################
# Author	:	Francisco Carpio
# Github	:	https://github.com/fcarp10
###############################################################################
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
###############################################################################

BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

function log() {
    if [[ $1 == "INFO" ]]; then
        printf "${BLUE}INFO:${NO_COLOR} %s \n" "$2"
    elif [[ $1 == "DONE" ]]; then
        printf "${GREEN}SUCCESS:${NO_COLOR} %s \n" "$2"
    elif [[ $1 == "WARN" ]]; then
        printf "${ORANGE}WARNING:${NO_COLOR} %s \n" "$2"
    else
        printf "${RED}FAILED:${NO_COLOR} %s \n" "$2"
    fi
}

log "INFO" "checking tools..."
command -v curl >/dev/null 2>&1 || {
    log "ERROR" "curl not found, aborting."
    exit 1
}
command -v faas >/dev/null 2>&1 || {
    log "ERROR" "faas-cli not found, please install 'curl -SLsf https://cli.openfaas.com | sudo sh', aborting."
    exit 1
}
command -v helm >/dev/null 2>&1 || {
    log "ERROR" "helm not found, please install 'curl -sSLf https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash', aborting."
    exit 1
}
log "DONE" "tools already installed"

####### k3s #######
log "INFO" "installing k3s..."
curl -sfL https://get.k3s.io | sh -
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/k3s-config && sudo chown $USER: ~/.kube/k3s-config && export KUBECONFIG=~/.kube/k3s-config
log "INFO" "waiting for k3s to start..."
sleep 30
log "INFO" "done"

####### openfaas #######
log "INFO" "deploying openfaas..."
export TIMEOUT=2m
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm install openfaas openfaas/openfaas \
    --namespace openfaas \
    --set functionNamespace=openfaas-fn \
    --set generateBasicAuth=true \
    --set gateway.upstreamTimeout=$TIMEOUT \
    --set gateway.writeTimeout=$TIMEOUT \
    --set gateway.readTimeout=$TIMEOUT \
    --set faasnetes.writeTimeout=$TIMEOUT \
    --set faasnetes.readTimeout=$TIMEOUT \
    --set queueWorker.ackWait=$TIMEOUT

log "INFO" "waiting for openfaas to start..."
sleep 30

kubectl rollout status -n openfaas deploy/gateway
kubectl port-forward -n openfaas svc/gateway 8080:8080 &
log "INFO" "please wait..."
sleep 10
PASSWORD=$(
    kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode
    echo
)
echo -n $PASSWORD | faas-cli login --username admin --password-stdin
log "DONE" "openfaas deployed successfully"

log "INFO" "testing openfaas..."
faas store deploy NodeInfo
MAX_ATTEMPTS=10
for ((i = 0; i < $MAX_ATTEMPTS; i++)); do
    if [[ $(curl -o /dev/null -s -w "%{http_code}\n" http://127.0.0.1:8080/function/nodeinfo) -eq 200 ]]; then
        log "DONE" "function is running successfully"
        faas rm nodeinfo
        break
    else
        log "WARN" "function is not running yet"
        if [[ $i -eq 10 ]]; then
            log "ERROR" "problem ocurred while deploying the function, exiting..."
            break
        fi
    fi
done
