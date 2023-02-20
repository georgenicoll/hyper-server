#!/bin/bash

echo "Deleting the existing kind cluster (if it exists)..."
kind delete cluster

echo "Creating kind cluster..."
kind create cluster --config kwasm-kind-cluster.yaml

echo "Adding helm repo and installing kwasm..."
helm repo add kwasm http://kwasm.sh/kwasm-operator/
helm install -n kwasm --create-namespace kwasm-operator kwasm/kwasm-operator

echo "Annotating kind-worker2..."
kubectl annotate node kind-worker2 kwasm.sh/kwasm-node=true

echo "Adding the kwasm runtimeClass..."
kubectl apply -f kwasm-runtimeclass.yaml

# See https://kind.sigs.k8s.io/docs/user/ingress/#ingress-kong
echo "Deploying the Kong Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/master/deploy/single/all-in-one-dbless.yaml
echo "Applying kind Kong deployment patch..."
kubectl patch deployment -n kong ingress-kong --patch-file kind-kong-deployment-patch.yaml
echo "Applying kind Kong service patch..."
kubectl patch service -n kong kong-proxy --patch-file kind-kong-service-patch.yaml

echo "Applying hyper server resources..."
kubectl apply -f kwasm-hyper-server-resources.yaml

echo "Done."