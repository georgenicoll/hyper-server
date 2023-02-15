#!/bin/bash
echo "Run cargo wasm build..."
cargo build --target wasm32-wasi --release # NOTE: Probably should do this in the container
echo "Running docker build..."
docker build --tag georgenicoll/hyper-server-kwasm:latest -f Dockerfile.kwasm .
echo "Done."