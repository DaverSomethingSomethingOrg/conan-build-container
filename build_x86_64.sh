#!/usr/bin/bash

cp src/requirements.txt src/almalinux-x86_64
cp src/requirements.txt src/ubuntu-x86_64

docker build --no-cache --target build-base --tag ghcr.io/daversomethingsomethingorg/conan-almalinux:x86_64-latest src/almalinux-x86_64 \
&& docker push ghcr.io/daversomethingsomethingorg/conan-almalinux:x86_64-latest \
&& docker build --target bootstrap-base --tag ghcr.io/daversomethingsomethingorg/bootstrap-almalinux:x86_64-latest src/almalinux-x86_64 \
&& docker push ghcr.io/daversomethingsomethingorg/bootstrap-almalinux:x86_64-latest

docker build --no-cache --target build-base --tag ghcr.io/daversomethingsomethingorg/conan-ubuntu:x86_64-latest src/ubuntu-x86_64 \
&& docker push ghcr.io/daversomethingsomethingorg/conan-ubuntu:x86_64-latest \
&& docker build --target bootstrap-base --tag ghcr.io/daversomethingsomethingorg/bootstrap-ubuntu:x86_64-latest src/ubuntu-x86_64 \
&& docker push ghcr.io/daversomethingsomethingorg/bootstrap-ubuntu:x86_64-latest
