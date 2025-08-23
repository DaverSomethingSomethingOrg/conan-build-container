#!/bin/bash
#!/usr/bin/bash

#set -x

Usage(){
   cat <<EOF
Usage: $0 [options]

--toolchain_prefix  Toplevel directory to install toolchain into.
                    Default: /opt/toolchain

--build_almalinux   Build images for the 'AlmaLinux' OS.
                    Default: false/disabled

--build_ubuntu      Build images for the 'Ubuntu' OS.
                    Default: false/disabled

--build_build       Also build our Demo GCC Toolchain images.
                    Default: false/disabled

--help              print this help text

EOF
}

toolchain_prefix="/opt/toolchain"
build_almalinux=false
build_ubuntu=false
build_build=false
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
        "--build_build")
            build_build=true
            shift # Consume this option argument
            ;;
#        "--use_cache")
#            use_cache=true
#            shift # Consume this option argument
#            ;;
        "--help")
            Usage
            exit 0
            ;;
        *)
            # Handle other arguments or break the loop
            Usage
            exit 1
            ;;
    esac
done

echo
echo "toolchain_prefix=${toolchain_prefix}"
echo "build_almalinux=${build_almalinux}"
echo "build_ubuntu=${build_ubuntu}"
echo "build_build=${build_build}"
#echo "use_cache=${use_cache}"

PKG_PREFIX_almalinux="opt-toolchain-"
PKG_PREFIX_ubuntu="opt+toolchain-"

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

for os_name in 'almalinux' 'ubuntu'; do

    ######################################################################
    # Only build the requested OS images using --build_<osname> arguments
    #
    build_varname="build_${os_name}"
    if [ "${!build_varname}" = false ]; then
        continue
    fi

    pkg_prefix_varname="PKG_PREFIX_${os_name}"
    PKG_PREFIX="${!pkg_prefix_varname}"

    cp src/requirements.txt "src/${os_name}/python-requirements.txt"

    set -e
    docker pull "${os_name}:latest"

    docker build \
         --target conan-base \
         --tag "nexus.homelab/conan-base-${os_name}:${machine_arch}-latest" \
         "src/${os_name}"

    docker push \
            "nexus.homelab/conan-base-${os_name}:${machine_arch}-latest"

    docker build \
            --target conan-bootstrap \
            --tag "nexus.homelab/conan-bootstrap-${os_name}:${machine_arch}-latest" \
            "src/${os_name}"

    docker push \
            "nexus.homelab/conan-bootstrap-${os_name}:${machine_arch}-latest"

    ######################################################################
    # Build and build-derived images below.
    # Enable with --build_build
    #
    if [ "${build_build}" = false ]; then
        continue
    fi

    docker build \
        --target conan-build \
        --build-arg PKG_PREFIX="${PKG_PREFIX}" \
        --build-arg TOOLCHAIN_PREFIX="${toolchain_prefix}" \
        --tag "nexus.homelab/conan-build-${os_name}:${machine_arch}-latest" \
        "src/${os_name}"

    docker push \
        "nexus.homelab/conan-build-${os_name}:${machine_arch}-latest"
    
    docker build \
        --target conan-docker-build \
        --build-arg PKG_PREFIX="${PKG_PREFIX}" \
        --build-arg TOOLCHAIN_PREFIX="${toolchain_prefix}" \
        --secret id=gh_token,env=GH_TOKEN \
        --tag "nexus.homelab/conan-docker-build-${os_name}:${machine_arch}-latest" \
        "src/${os_name}"

    docker push \
        "nexus.homelab/conan-docker-build-${os_name}:${machine_arch}-latest"

    set +e

done
