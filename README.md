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

# KWasm with kind and various ingress

See:
- [KWasm on github](https://github.com/KWasm)
- [the kind ingress documentation](https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx)

## Ingress Types

### nginx ingress

```bash
# Will run the commands to set up the cluster with kwasm and nginx ingress
./kind-cluster-with-nginx.sh
```

### kong ingress

```bash
# Will run the commands to set up the cluster with kwasm and kong ingress
./kind-cluster-with-kong.sh
```

## Exercise it

```bash
# ingress is set up on host port 18080/18443
curl https://localhost:18443/hyper-server/echo -k -XPOST -d 'Hello wasm world!'
curl https://localhost:18443/hyper-server/echo/reversed -k -XPOST -d '!dlrow msaw sdrawkcab olleH'
```
