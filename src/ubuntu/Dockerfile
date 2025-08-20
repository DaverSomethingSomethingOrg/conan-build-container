FROM ubuntu:latest AS conan-base

# Set up a baseline install before proceeding with our customizations
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      ca-certificates \
      gnupg \
      ssh \
      git \
      git-lfs \
      sudo \
      curl \
      wget \
      vim \
      less \
      build-essential \
      dpkg-dev \
      devscripts \
      debhelper \
      fakeroot \
      python3 \
      python-is-python3 \
      python3-pip \
      python3-venv

#TODO How do we get rid of/limit build-essential from our image and still
#     run our custom Conan deployer / package generator?

# Copy over any needed source files or configuration
COPY config /

# Setup Certs and toolchain Apt repo(s)
COPY keys/ /tmp/keys/
RUN if [ -f "/tmp/keys/InternalCA.crt" ]; then \
      mv /tmp/keys/InternalCA.crt /usr/local/share/ca-certificates/; \
    fi; \
    \
    if [ -f "/tmp/keys/internal-keyring.gpg" ]; then \
      mv /tmp/keys/internal-keyring.gpg /etc/apt/trusted.gpg.d; \
    fi; \
    rm -fR /tmp/keys/;
    
RUN update-ca-certificates

ENV MINIMAL_PATH="${PATH}"
ENV CC=gcc
ENV CXX=g++

# Make sure VIRTUAL_ENV PATH is always ahead of any other path to python
ENV VIRTUAL_ENV=/opt/python-venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY python-requirements.txt* /tmp
RUN if [ -f "/tmp/python-requirements.txt" ]; then \
      pip install --no-cache-dir -r /tmp/python-requirements.txt; \
      rm /tmp/python-requirements.txt; \
    fi;

######################################################################
# Bootstrapping image with Vendor gcc toolchain
#
FROM conan-base AS conan-bootstrap

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      make \
      cmake \
      binutils \
      gcc \
      g++

# Now that we have a build-worthy environment, detect conan default profile
# - Do it here to save more time starting the build!
RUN conan profile detect


######################################################################
# Build image with our own gcc toolchain
#
FROM conan-base AS conan-build
ARG PKG_PREFIX="opt+toolchain-"
ARG TOOLCHAIN_PREFIX="/opt/toolchain"

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      ${PKG_PREFIX}make \
      ${PKG_PREFIX}cmake \
      ${PKG_PREFIX}binutils \
      ${PKG_PREFIX}gcc

ENV PATH="${VIRTUAL_ENV}/bin:${TOOLCHAIN_PREFIX}/bin:${MINIMAL_PATH}"

# Now that we have a build-worthy environment, detect conan default profile
# - Do it here to save more time starting the build!
RUN conan profile detect

######################################################################
# Docker Toolchain Image Developer with Docker, GH Client, gh-act extension
#
FROM conan-build AS conan-docker-build

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin \
      gh

# Need `GH_TOKEN` passed in as a secret to install gh-act
RUN --mount=type=secret,id=gh_token,env=GH_TOKEN \
    gh extension install nektos/gh-act
