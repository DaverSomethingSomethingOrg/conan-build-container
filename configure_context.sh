#!/bin/bash
#!/usr/bin/bash

set -x

# Basic stuff
cp src/requirements.txt "src/ubuntu/python-requirements.txt"
cp src/requirements.txt "src/almalinux/python-requirements.txt"

# Install our Internal CA certificate, if we have one
mkdir -p "src/almalinux/keys" "src/ubuntu/keys/"
if [ -f "src/InternalCA.crt" ]; then
    cp "src/InternalCA.crt" "src/almalinux/keys/"
    cp "src/InternalCA.crt" "src/ubuntu/keys/"
#    mkdir -p "src/almalinux/config/etc/pki/ca-trust/source/anchors"
#    cp "src/InternalCA.crt" "src/almalinux/config/etc/pki/ca-trust/source/anchors"
fi

# Install APT keyring for our Conan Toolchain repo
if [ -f "src/internal-keyring.gpg" ]; then
    cp "src/internal-keyring.gpg" "src/ubuntu/keys/"
fi
