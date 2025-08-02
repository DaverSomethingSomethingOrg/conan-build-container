#!/bin/bash
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

cp src/requirements.txt src/almalinux
mkdir -p src/almalinux/config/etc/pki/ca-trust/source/anchors
cp src/DaverSomethingSomethingRootCA.crt src/almalinux/config/etc/pki/ca-trust/source/anchors

PKG_PREFIX="opt-toolchain-"
TOOLCHAIN_PREFIX="/opt/toolchain"

docker build \
         --no-cache \
         --target conan-base \
         --platform ${docker_platform} \
         --tag nexus.homelab/conan-base-almalinux:latest \
         src/almalinux \
&& docker push \
            --platform ${docker_platform} \
            nexus.homelab/conan-base-almalinux:latest \
&& docker build \
            --target conan-bootstrap \
            --platform ${docker_platform} \
            --tag nexus.homelab/conan-bootstrap-almalinux:latest \
            src/almalinux \
&& docker push \
            --platform ${docker_platform} \
            nexus.homelab/conan-bootstrap-almalinux:latest \
&& docker build \
            --target conan-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${TOOLCHAIN_PREFIX}" \
            --platform ${docker_platform} \
            --tag nexus.homelab/conan-build-almalinux:latest \
            src/almalinux \
&& docker push \
            --platform ${docker_platform} \
            nexus.homelab/conan-build-almalinux:latest \
&& docker build \
            --target conan-docker-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${TOOLCHAIN_PREFIX}" \
            --platform ${docker_platform} \
            --tag nexus.homelab/conan-docker-build-almalinux:latest \
            src/almalinux \
&& docker push \
            --platform ${docker_platform} \
            nexus.homelab/conan-docker-build-almalinux:latest

exit

PKG_PREFIX="opt+toolchain-"

cp src/requirements.txt src/ubuntu
mkdir -p src/ubuntu/config/etc/pki/ca-trust/source/anchors
cp src/DaverSomethingSomethingRootCA.crt src/ubuntu/config/etc/pki/ca-trust/source/anchors

docker build \
            --no-cache \
            --file src/Dockerfile-ubuntu \
            --target conan-base \
            --platform ${docker_platform} \
            --tag nexus.homelab/conan-base-ubuntu:latest \
            src \
&& docker push \
            --platform ${docker_platform} \
            nexus.homelab/conan-base-ubuntu:latest \
&& docker build \
            --file src/Dockerfile-ubuntu \
            --target conan-bootstrap \
            --platform ${docker_platform} \
            --tag nexus.homelab/conan-bootstrap-ubuntu:latest \
            src \
&& docker push \
            --platform ${docker_platform} \
            nexus.homelab/conan-bootstrap-ubuntu:latest \
&& docker build \
            --file src/Dockerfile-ubuntu \
            --target conan-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${TOOLCHAIN_PREFIX}" \
            --platform ${docker_platform} \
            --tag nexus.homelab/conan-build-ubuntu:latest \
            src \
&& docker push \
            --platform ${docker_platform} \
            nexus.homelab/conan-build-ubuntu:latest
