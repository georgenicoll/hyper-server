#!/bin/bash

echo "Delete the current cluster (if it exists)..."
kind delete cluster

echo "Create the kind cluster with 2 workers..."
kind create cluster --config kwasm-kind-cluster.yaml

echo "Add the kwasm helm repo and install the operator"
helm repo add kwasm http://kwasm.sh/kwasm-operator/
helm install -n kwasm --create-namespace kwasm-operator kwasm/kwasm-operator

echo "Annotate the second node..."
kubectl annotate node kind-worker2 kwasm.sh/kwasm-node=true
echo "Add the kwasm crun runtime class..."
kubectl apply -f kwasm-runtimeclass.yaml

#See https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx
echo "Setting up nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo "Waiting for nginx to be ready (will timeout in 3 mins)..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "Apply the hyper-server resources to the cluster..."
kubectl apply -f kwasm-hyper-server-resources.yaml

#echo "Apply the kind ingress example resources to the cluster..."
#kubectl apply -f example-ingress.yaml

echo "Done."