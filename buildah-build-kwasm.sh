#!/bin/bash
echo "Run cargo wasm build..."
cargo build --target wasm32-wasi --release # NOTE: Probably should do this in the container
echo "Running buildah build..."
buildah build --annotation "module.wasm.image/variant=compat-smart" -t georgenicoll/hyper-server-buildah-kwasm -f Dockerfile.kwasm .
echo "Done."
