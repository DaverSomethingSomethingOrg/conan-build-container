FROM ubuntu:latest AS build-base

USER root

COPY qemu-aarch64-static /usr/bin/qemu-aarch64-static

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y

RUN apt-get install --no-install-recommends -y \
    git \
    sudo \
    wget \
    vim \
    python3 \
    python3-pip

COPY requirements.txt /tmp
RUN pip install --no-cache-dir  --break-system-packages -r /tmp/requirements.txt

FROM build-base AS bootstrap-base
RUN apt-get install --no-install-recommends -y \
    make \
    cmake \
    binutils \
    gcc \
    g++
