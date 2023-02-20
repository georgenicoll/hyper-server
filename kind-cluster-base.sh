#!/bin/bash
# Intention is to call this file to set up a cluster with wasm, then perform specific commands
# ro customise the cluster further...

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

echo "Done base cluster setup."