#!/bin/sh
minikube start driver=docker

export TIMEOUT=2592000s

arkade install openfaas \
  --set gateway.upstreamTimeout=$TIMEOUT \
  --set gateway.writeTimeout=$TIMEOUT \
  --set gateway.readTimeout=$TIMEOUT \
  --set faasnetes.writeTimeout=$TIMEOUT \
  --set faasnetes.readTimeout=$TIMEOUT \
  --set queueWorker.ackWait=$TIMEOUT

kubectl rollout status -n openfaas deploy/gateway
kubectl port-forward -n openfaas svc/gateway 8080:8080 &
kubectl get deployments -n openfaas -l "release=openfaas, app=openfaas"
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
echo -n $PASSWORD | faas-cli login --username admin --password-stdin
echo $PASSWORD
