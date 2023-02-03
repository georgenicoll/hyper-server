#!/bin/bash
# krustlet should be available on the PATH before running this
echo "=== Deleting kind cluster"
kind delete cluster

echo "=== Removing kind and krustlet configurations"
rm -f ~/.kube/config
rm -fr ~/.krustlet

echo "=== Creating kind cluster"
kind create cluster

echo "=== Patching kindnet daemonset"
kubectl patch -n kube-system daemonset kindnet --patch-file kindnet-daemonset-patch.yaml

echo "=== Bootstrap Krustlet"
bash <(curl https://raw.githubusercontent.com/krustlet/krustlet/main/scripts/bootstrap.sh)

echo "=== Done"
echo ""
echo "Now Run:"
echo ""
echo "KUBECONFIG=~/.krustlet/config/kubeconfig \\"
echo "  krustlet-wasi \\"
echo "  --port 3000 \\"
echo "  --node-ip 172.17.0.1 \\"
echo "  --node-name=krustlet \\"
echo "  --bootstrap-file=${HOME}/.krustlet/config/bootstrap.conf"
echo ""
echo "==="