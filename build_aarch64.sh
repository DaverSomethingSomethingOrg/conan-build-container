#!/usr/bin/bash

cp src/qemu-aarch64-static src/almalinux-aarch64
cp src/qemu-aarch64-static src/ubuntu-aarch64

cp src/requirements.txt src/almalinux-aarch64
cp src/requirements.txt src/ubuntu-aarch64

docker build --no-cache --target build-base --tag ghcr.io/daversomethingsomethingorg/conan-almalinux:aarch64-latest src/almalinux-aarch64 \
&& docker push ghcr.io/daversomethingsomethingorg/conan-almalinux:aarch64-latest \
&& docker build --target bootstrap-base --tag ghcr.io/daversomethingsomethingorg/bootstrap-almalinux:aarch64-latest src/almalinux-aarch64 \
&& docker push ghcr.io/daversomethingsomethingorg/bootstrap-almalinux:aarch64-latest

docker build --no-cache --target build-base --tag ghcr.io/daversomethingsomethingorg/conan-ubuntu:aarch64-latest src/ubuntu-aarch64 \
&& docker push ghcr.io/daversomethingsomethingorg/conan-ubuntu:aarch64-latest \
&& docker build --target bootstrap-base --tag ghcr.io/daversomethingsomethingorg/bootstrap-ubuntu:aarch64-latest src/ubuntu-aarch64 \
&& docker push ghcr.io/daversomethingsomethingorg/bootstrap-ubuntu:aarch64-latest
