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

## KWasm with kind

See [KWasm on github](https://github.com/KWasm).

### Set up and run in kind cluster:

Run the following commands (or just run [stand-up-kind-kwasm-cluster.sh](stand-up-kind-kwasm-cluster.sh)):

```bash
# Create the kind cluster with 2 worksers
kind create cluster --config kwasm-kind-cluster.yaml
# Add the kwasm helm repo and install the operator
helm repo add kwasm http://kwasm.sh/kwasm-operator/
helm install -n kwasm --create-namespace kwasm-operator kwasm/kwasm-operator
# Annotate the second node
kubectl annotate node kind-worker2 kwasm.sh/kwasm-node=true
# Add the kwasm crun runtime class
kubectl apply -f kwasm-runtimeclass.yaml
# Apply the hyper-server resources to the cluster
kubectl apply -f kwasm-hyper-server-resources.yaml
```
### Exercise it:

```bash
# port forward to the service
kubectl port-forward svc/hyper-server 3000:3000
```
