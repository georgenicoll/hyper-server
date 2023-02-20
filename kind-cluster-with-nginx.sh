#!/bin/bash

./kind-cluster-base.sh

#See https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx
echo "Setting up nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo "Waiting for nginx to be ready (will timeout in 3 mins)..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "Attempting to apply the hyper-server resources to the cluster..."
until kubectl apply -f kwasm-hyper-server-resources-nginx.yaml
do
  echo "Waiting for application to run through..."
  sleep 5
done

echo "Done."