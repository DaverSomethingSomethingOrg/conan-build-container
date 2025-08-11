#!/bin/bash
#!/usr/bin/bash

#set -x

toolchain_prefix="/opt/toolchain"
build_almalinux=false
build_ubuntu=false
#build_build=false
#use_cache=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        "--toolchain_prefix")
            shift # Consume this option argument
            toolchain_prefix="$1"
            shift # Consume this option value
            ;;
        "--build_almalinux")
            build_almalinux=true
            shift # Consume this option argument
            ;;
        "--build_ubuntu")
            build_ubuntu=true
            shift # Consume this option argument
            ;;
#        "--build_build")
#            build_build=true
#            shift # Consume this option argument
#            ;;
#        "--use_cache")
#            use_cache=true
#            shift # Consume this option argument
#            ;;
        *)
            # Handle other arguments or break the loop
            break
            ;;
    esac
done

echo "toolchain_prefix=${toolchain_prefix}"
echo "build_almalinux=${build_almalinux}"
echo "build_ubuntu=${build_ubuntu}"
#echo "build_build=${build_build}"
#echo "use_cache=${use_cache}"

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

#CACHE_USAGE="--no-cache"
#if [ "${use_cache}" = true ]; then
#    CACHE_USAGE=""
#fi

set -x
os_name="almalinux"
build_varname="build_${os_name}"
if [ "${!build_varname}" = true ]; then

    PKG_PREFIX="opt-toolchain-"

    cp src/requirements.txt "src/${os_name}"
    mkdir -p "src/${os_name}/config/etc/pki/ca-trust/source/anchors"
    cp "src/DaverSomethingSomethingRootCA.crt" "src/${os_name}/config/etc/pki/ca-trust/source/anchors"

    docker pull "${os_name}:latest"

    docker build \
         --target conan-base \
         --tag "nexus.homelab/conan-base-${os_name}:${machine_arch}-latest" \
         "src/${os_name}" \
    && docker push \
            "nexus.homelab/conan-base-${os_name}:${machine_arch}-latest" \
    && docker build \
            --target conan-bootstrap \
            --tag "nexus.homelab/conan-bootstrap-${os_name}:${machine_arch}-latest" \
            "src/${os_name}" \
    && docker push \
            "nexus.homelab/conan-bootstrap-${os_name}:${machine_arch}-latest" \
    && docker build \
            --target conan-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${toolchain_prefix}" \
            --tag "nexus.homelab/conan-build-${os_name}:${machine_arch}-latest" \
            "src/${os_name}" \
    && docker push \
            "nexus.homelab/conan-build-${os_name}:${machine_arch}-latest" \
    && docker build \
            --target conan-docker-build \
            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
            --build-arg TOOLCHAIN_PREFIX="${toolchain_prefix}" \
            --secret id=gh_token,env=GH_TOKEN \
            --tag "nexus.homelab/conan-docker-build-${os_name}:${machine_arch}-latest" \
            "src/${os_name}" \
    && docker push \
            "nexus.homelab/conan-docker-build-${os_name}:${machine_arch}-latest" \

fi

os_name="ubuntu"
build_varname="build_${os_name}"
if [ "${!build_varname}" = true ]; then

    PKG_PREFIX="opt+toolchain-"

    cp src/requirements.txt "src/${os_name}"
    mkdir -p "src/${os_name}/config/etc/pki/ca-trust/source/anchors"
    cp "src/DaverSomethingSomethingRootCA.crt" "src/${os_name}/config/etc/pki/ca-trust/source/anchors"

    docker pull "${os_name}:latest"

    docker build \
        --target conan-base \
        --tag "nexus.homelab/conan-base-${os_name}:${machine_arch}-latest" \
        "src/${os_name}" \
    && docker push \
        "nexus.homelab/conan-base-${os_name}:${machine_arch}-latest" \
    && docker build \
        --target conan-bootstrap \
        --tag "nexus.homelab/conan-bootstrap-${os_name}:${machine_arch}-latest" \
        "src/${os_name}" \
    && docker push \
        "nexus.homelab/conan-bootstrap-${os_name}:${machine_arch}-latest" \

#    && docker build \
#        --target conan-build \
#        --build-arg PKG_PREFIX="${PKG_PREFIX}" \
#        --build-arg TOOLCHAIN_PREFIX="${toolchain_prefix}" \
#        --tag "nexus.homelab/conan-build-${os_name}:${machine_arch}-latest" \
#        "src/${os_name}" \
#    && docker push \
#        "nexus.homelab/conan-build-${os_name}:${machine_arch}-latest" \

#    && docker build \
#            --target conan-docker-build \
#            --build-arg PKG_PREFIX="${PKG_PREFIX}" \
#            --build-arg TOOLCHAIN_PREFIX="${toolchain_prefix}" \
#            --secret id=gh_token,env=GH_TOKEN \
#            --tag "nexus.homelab/conan-docker-build-${os_name}:${machine_arch}-latest" \
#            "src/${os_name}" \
#    && docker push \
#            "nexus.homelab/conan-docker-build-${os_name}:${machine_arch}-latest" \

fi
