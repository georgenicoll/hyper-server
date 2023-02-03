#!/bin/bash
# Need to login to ghcr.io first using a github access token with write:packages permissioned
# Example bash to do this:
# export GH_PAT=<token>
# echo $GH_PAT | docker login ghcr.io -u <Your GitHub username> --password-stdin
wasm-to-oci push target/wasm32-wasi/release/hyper-server.wasm ghcr.io/georgenicoll/hyper-server:latest