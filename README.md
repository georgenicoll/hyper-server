# hyper-server

Messing around with [hyper_wasi](https://docs.rs/crate/hyper_wasi/latest) and [wasi](https://wasi.dev/).

Shamelessly cribbed from: [WasmEdge/wasmedge_hyper_demo server](https://github.com/WasmEdge/wasmedge_hyper_demo/tree/main/server).

## Build

Requires the wasm32-wasi target...

```bash
rustup target add wasm32-wasi
cargo build --target wasm32-wasi --release
```
## Run

```bash
wasmedge target/wasm32-wasi/release/hyper-server.wasm
```
## Exercise it

```bash
curl localhost:3000/echo -XPOST -d 'Hello wasm world!'
curl localhost:3000/echo/reversed -XPOST -d '!dlrow msaw sdrawkcab olleH'
```
## Docker (wasmedge DockerSlim)

Build the Container

```bash
./docker-build-wasmedge-docker-slim.sh
```
Run the Container

```bash
./docker-run-wasmedge-docker-slim.sh
```
## Package wasm as OCI

### Get wasm-to-oci
```bash
export WASM_TO_OCI_VERSION=v0.1.2
curl -LO --output-dir temp https://github.com/engineerd/wasm-to-oci/releases/download/${WASM_TO_OCI_VERSION}/linux-amd64-wasm-to-oci
sudo cp temp/linux-amd64-wasm-to-oci /usr/local/bin/wasm-to-oci
sudo chmod a+x /usr/local/bin/wasm-to-oci
```

### Push to docker hub
```bash
./docker-push-wasm-to-oci.sh
```

### Make the package public

[hyper-server](https://github.com/users/georgenicoll/packages/container/package/hyper-server) -> Package Settings...

## Kubernetes (k3d)

### Install [k3d](https://k3d.io/v5.4.6/#installation)
```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

### [containerd-wasm-shims](https://github.com/deislabs/containerd-wasm-shims/tree/main/deployments/k3d) K3d Shim Deployment
```bash
k3d cluster create wasm-cluster --image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.3.2 -p "8081:80@loadbalancer" --agents 2
echo "waiting 60 seconds for cluster to be ready"
sleep 60
kubectl apply -f https://github.com/deislabs/containerd-wasm-shims/raw/main/deployments/workloads/runtime.yaml
kubectl apply -f https://github.com/deislabs/containerd-wasm-shims/raw/main/deployments/workloads/workload.yaml
echo "waiting 30 seconds for workload to be ready"
sleep 30
curl -v http://127.0.0.1:8081/spin/hello
curl -v http://127.0.0.1:8081/slight/hello
```

##### To Delete:
```
k3d cluster delete wasm-cluster
```

## Kubernetes (kind)

Taken from https://developer.okta.com/blog/2022/01/28/webassembly-on-kubernetes-with-rust and
https://docs.krustlet.dev/intro/.

### Prerequisites

- Docker
- kubectl
- kind (or similar)
- Rust tools

### Build krustlet

Install dependencies
```bash
sudo apt install libssl-dev
```

Get `just`:
```bash
cargo install just
```
Get the code:
```bash
git clone git@github.com:krustlet/krustlet.git
cd krustlet
```
Build it:
```bash
just build --release
```
Copy krustlet to a location in `$PATH`
```bash
sudo cp target/release/krustlet-wasi /usr/local/bin/
```

## Run in k8 ([kind](https://kind.sigs.k8s.io/))

### Run [kind-krustlet-reset.sh](kind-krustlet-reset.sh) to cleanup and run a king
```bash
kubectl apply -f k8s-wasm-resources.yaml
kubectl logs hello-wasm
kubectl port-forward hyper-server 8080:3000
```
This will do the following:
- Delete the currently running kind cluster (if there is one)
- Remove kind and Krustlet configuration
- Create a kind cluster
- Patch the kindnet daemonset to prevent it trying to run on the Krustlet node
- Create the Krustlet bootstrap configuation

### Wait for everything to start up
```bash
kubectl get pods -A
```

### Start the Krustlet node
This assumes that the `docker0` interface has IP `172.17.0.1` (check with `ip addr show docker0`):
```bash
KUBECONFIG=~/.krustlet/config/kubeconfig \
  krustlet-wasi \
  --port 3000 \
  --node-ip 172.17.0.1 \
  --node-name=krustlet \
  --bootstrap-file=${HOME}/.krustlet/config/bootstrap.conf
```

### Approve &lt;hostname&gt;-tls certificate
```bash
kubectl certificate approve $(hostname)-tls
```

### Check out the new node
```bash
kubectl get nodes -o wide
# Returns something like
# NAME                 STATUS   ROLES           AGE    VERSION         INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
# kind-control-plane   Ready    control-plane   69m    v1.25.3         172.18.0.2    <none>        Ubuntu 22.04.1 LTS   5.15.0-58-generic   containerd://1.6.9
# krustlet             Ready    <none>          116s   1.0.0-alpha.1   172.17.0.1    <none>        <unknown>            <unknown>           mvp
```
