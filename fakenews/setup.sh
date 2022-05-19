#!/bin/sh
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo docker run hello-world

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo adduser userfaas

sudo usermod -aG sudo userfaas

su -- userfaas

sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

sudo usermod -aG docker onyeoma
newgrp docker 
#docker run hello-world

minikube start –driver=docker

minikube kubectl -- get po -A

sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

echo "$(<kubectl.sha256) kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4
kubectl expose deployment hello-minikube --type=NodePort --port=8080
kubectl get services hello-minikube

minikube service hello-minikube

curl -sL https://cli.openfaas.com | sudo sh

curl -SLsf https://dl.get-arkade.dev/ | sudo sh

arkade install openfaas

kubectl rollout status -n openfaas deploy/gateway

kubectl port-forward -n openfaas svc/gateway 8080:8080 &
kubectl -n openfaas get deployments -l "release=openfaas, app=openfaas"
kubectl get svc -o wide gateway-external -n openfaas
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
echo -n $PASSWORD | faas-cli login --username admin –password-stdin
echo $PASSWORD




