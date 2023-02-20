#!/bin/bash

./kind-cluster-base.sh

echo "Applying kong resources..."
# See https://kind.sigs.k8s.io/docs/user/ingress/#ingress-kong
kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/master/deploy/single/all-in-one-dbless.yaml
echo "Apply kong ingress patch..."
kubectl patch deployment -n kong ingress-kong --patch-file kind-kong-ingress-patch.yaml
echo "Apply kong service patch..."
kubectl patch service -n kong kong-proxy --patch-file kind-kong-service-patch.yaml
echo "Waiting for kong ingress to come up..."
until kubectl wait --namespace kong --for=condition=ready pod --selector=app=ingress-kong --timeout=10s
do
  echo "Still waiting..."
  sleep 5
done

echo "Attempting to apply the hyper-server resources to the cluster..."
until kubectl apply -f kwasm-hyper-server-resources-kong.yaml
do
  echo "Waiting for application to run through..."
  sleep 5
done

echo "Done."