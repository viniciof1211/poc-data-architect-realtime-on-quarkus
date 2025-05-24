#!/usr/bin/env bash
# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
minikube start

# Install oc CLI
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
tar xvzf oc.tar.gz
sudo mv oc /usr/local/bin

# Login to OpenShift
oc login https://localhost:6443 --token=${OPENSHIFT_TOKEN}

# Apply manifests
oc new-project poc
oc apply -f k8s/namespace.yaml
oc apply -f k8s/quarkus-deployment.yaml
oc apply -f k8s/service.yaml
oc apply -f k8s/ingress.yaml