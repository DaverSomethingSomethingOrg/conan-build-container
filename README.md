# Conan Build Containers

Work-in-Progress:

GitHub Workflows are still being developed for building these images,
so currently the script `build_containers.sh` is used to build and
push all images.


This repository contains Container image definitions used for building
packages using the [Conan C/C++ Package Manager](https://conan.io/).

OS/Platform support for all images includes:

    - AlmaLinux 9.6 (x86_64, aarch64)
    - Ubuntu 24.04LTS (x86_64, aarch64)

We build four different images here.

## `conan-base-${os_name}:${arch}-latest`

Basic conan functionality but no GCC toolchain provided.

## `conan-bootstrap-${os_name}:${arch}-latest`

`conan-bootstrap` takes `conan-base` and adds the OS Vendor's GCC toolchain
(and CMake!) installed.

## `conan-build-${os_name}:${arch}-latest`

`conan-build` is our Conan base image for any Conan Toolchain builds.
This image is similar to the
[`conan-docker-tools`](https://github.com/conan-io/conan-docker-tools)
image generated for and used by the Conan project themselves.

After using our `conan-base` and `conan-boostrap` images to run the
[Demo MultiPhase GCC Compiler Bootstrap Build](https://daversomethingsomethingorg.github.io/ConanToolchain/latest/DemoMultiPhase/)
We can combine our powers with the packages generated to assemble
our `conan-build` images.

## `conan-docker-build-${os_name}:${arch}-latest`

`conan-docker-build` adds Docker CE and GitHub Client (`gh`) with
the `gh-act` plugin for use in toolchain workflow/container development.

## `build_containers.sh` - Building the images

```bash
# ./build_containers.sh --help
Usage: ./build_containers.sh [options]

--toolchain_prefix  Toplevel directory to install toolchain into.
                    Default: /opt/toolchain

--build_almalinux   Build images for the 'AlmaLinux' OS.
                    Default: false/disabled

--build_ubuntu      Build images for the 'Ubuntu' OS.
                    Default: false/disabled

--build_build       Also build our Demo GCC Toolchain images.
                    Default: false/disabled

--help              print this help text

#
```

## Reference

- https://github.com/conan-io/conan-docker-tools

## License and Copyright

Copyright © 2025 David L. Armstrong

[Apache-2.0](LICENSE.txt)
