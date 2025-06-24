#!/usr/bin/bash

machine_arch=$(uname -m)
case "${machine_arch}" in
    aarch64|arm64)
        docker_platform="linux/arm64"
        ;;
    x86_64)
        docker_platform="linux/amd64"
        ;;
    *)
        echo "ERROR: unsupported architecture: '${machine_arch}'"
        exit 1
        ;;
esac

PKG_PREFIX="opt-toolchain-"
TOOLCHAIN_PREFIX="/opt/toolchain"

docker build \
         --no-cache \
         --file src/Dockerfile-almalinux \
         --target conan-base \
         --platform ${docker_platform} \
         --tag ghcr.io/daversomethingsomethingorg/conan-base-almalinux:latest \
         src \
&& docker push \
            --platform ${docker_platform} \
            ghcr.io/daversomethingsomethingorg/conan-base-almalinux:latest \
&& docker build \
            --file src/Dockerfile-almalinux \
            --target conan-bootstrap \
            --platform ${docker_platform} \
            --tag ghcr.io/daversomethingsomethingorg/conan-bootstrap-almalinux:latest \
            src \
&& docker push \
            --platform ${docker_platform} \
            ghcr.io/daversomethingsomethingorg/conan-bootstrap-almalinux:latest \
&& docker build \
            --file src/Dockerfile-almalinux \
            --target conan-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${TOOLCHAIN_PREFIX}" \
            --platform ${docker_platform} \
            --tag ghcr.io/daversomethingsomethingorg/conan-build-almalinux:latest \
            src \
&& docker push \
            --platform ${docker_platform} \
            ghcr.io/daversomethingsomethingorg/conan-build-almalinux:latest \

docker build \
            --no-cache \
            --file src/Dockerfile-ubuntu \
            --target conan-base \
            --platform ${docker_platform} \
            --tag ghcr.io/daversomethingsomethingorg/conan-base-ubuntu:latest \
            src \
&& docker push \
            --platform ${docker_platform} \
            ghcr.io/daversomethingsomethingorg/conan-base-ubuntu:latest \
&& docker build \
            --file src/Dockerfile-ubuntu \
            --target conan-bootstrap \
            --platform ${docker_platform} \
            --tag ghcr.io/daversomethingsomethingorg/conan-bootstrap-ubuntu:latest \
            src \
&& docker push \
            --platform ${docker_platform} \
            ghcr.io/daversomethingsomethingorg/conan-bootstrap-ubuntu:latest \
&& docker build \
            --file src/Dockerfile-ubuntu \
            --target conan-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${TOOLCHAIN_PREFIX}" \
            --platform ${docker_platform} \
            --tag ghcr.io/daversomethingsomethingorg/conan-build-ubuntu:latest \
            src \
&& docker push \
            --platform ${docker_platform} \
            ghcr.io/daversomethingsomethingorg/conan-build-ubuntu:latest
