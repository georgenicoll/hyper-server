#!/bin/bash
docker run \
    --name hyper-server \
    -p 3000:3000 \
    -it --rm \
    georgenicoll/hyper-server-wasmedge-docker:latest
