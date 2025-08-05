#!/bin/bash
#!/usr/bin/bash

machine_arch=$(uname -m)
case "${machine_arch}" in
    aarch64|arm64)
        docker_platform="linux/arm64"
        machine_arch=aarch64
        ;;
    x86_64)
        docker_platform="linux/amd64"
        ;;
    *)
        echo "ERROR: unsupported architecture: '${machine_arch}'"
        exit 1
        ;;
esac

cp src/requirements.txt src/almalinux
mkdir -p src/almalinux/config/etc/pki/ca-trust/source/anchors
cp src/DaverSomethingSomethingRootCA.crt src/almalinux/config/etc/pki/ca-trust/source/anchors

TOOLCHAIN_PREFIX="/opt/toolchain"
PKG_PREFIX="opt-toolchain-"

#         --no-cache \
docker build \
         --target conan-base \
         --platform ${docker_platform} \
         --tag "nexus.homelab/conan-base-almalinux:${machine_arch}-latest" \
         src/almalinux \
&& docker push \
            --platform ${docker_platform} \
            "nexus.homelab/conan-base-almalinux:${machine_arch}-latest" \
&& docker build \
            --target conan-bootstrap \
            --platform ${docker_platform} \
            --tag "nexus.homelab/conan-bootstrap-almalinux:${machine_arch}-latest" \
            src/almalinux \
&& docker push \
            --platform ${docker_platform} \
            "nexus.homelab/conan-bootstrap-almalinux:${machine_arch}-latest" \
&& docker build \
            --target conan-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${TOOLCHAIN_PREFIX}" \
            --platform ${docker_platform} \
            --tag "nexus.homelab/conan-build-almalinux:${machine_arch}-latest" \
            src/almalinux \
&& docker push \
            --platform ${docker_platform} \
            "nexus.homelab/conan-build-almalinux:${machine_arch}-latest" \
&& docker build \
            --target conan-docker-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${TOOLCHAIN_PREFIX}" \
            --platform ${docker_platform} \
            --tag "nexus.homelab/conan-docker-build-almalinux:${machine_arch}-latest" \
            src/almalinux \
&& docker push \
            --platform ${docker_platform} \
            "nexus.homelab/conan-docker-build-almalinux:${machine_arch}-latest" \

exit

PKG_PREFIX="opt+toolchain-"

cp src/requirements.txt src/ubuntu
mkdir -p src/ubuntu/config/etc/pki/ca-trust/source/anchors
cp src/DaverSomethingSomethingRootCA.crt src/ubuntu/config/etc/pki/ca-trust/source/anchors

#            --no-cache \
docker build \
            --file src/Dockerfile-ubuntu \
            --target conan-base \
            --platform ${docker_platform} \
            --tag "nexus.homelab/conan-base-ubuntu:${machine_arch}-latest" \
            src \
&& docker push \
            --platform ${docker_platform} \
            "nexus.homelab/conan-base-ubuntu:${machine_arch}-latest" \
&& docker build \
            --file src/Dockerfile-ubuntu \
            --target conan-bootstrap \
            --platform ${docker_platform} \
            --tag "nexus.homelab/conan-bootstrap-ubuntu:${machine_arch}-latest" \
            src \
&& docker push \
            --platform ${docker_platform} \
            "nexus.homelab/conan-bootstrap-ubuntu:${machine_arch}-latest" \

#&& docker build \
#            --file src/Dockerfile-ubuntu \
#            --target conan-build \
#            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
#            --build-arg TOOLCHAIN_PREFIX="${TOOLCHAIN_PREFIX}" \
#            --platform ${docker_platform} \
#            --tag "nexus.homelab/conan-build-ubuntu:${machine_arch}-latest" \
#            src \
#&& docker push \
#            --platform ${docker_platform} \
#            "nexus.homelab/conan-build-ubuntu:${machine_arch}-latest" \

