FROM ubuntu:latest AS conan-base

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install --no-install-recommends -y \
    ca-certificates \
    git \
    git-lfs \
    sudo \
    wget \
    vim \
    python3 \
    python-is-python3 \
    python3-pip \
    python3-venv \
    build-essential \
    devscripts \
    debhelper \
    fakeroot

# Setup Certs and toolchain Apt repo(s)
COPY config /
RUN update-ca-certificates

ENV MINIMAL_PATH="${PATH}"
ENV CC=gcc
ENV CXX=g++

# Make sure VIRTUAL_ENV PATH is always ahead of any other path to python
ENV VIRTUAL_ENV=/opt/python-venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
COPY requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/requirements.txt


######################################################################
# Bootstrapping image with Vendor gcc toolchain
#
FROM conan-base AS conan-bootstrap
RUN apt-get install --no-install-recommends -y \
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

RUN apt-get install --no-install-recommends -y \
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
#FROM conan-build AS conan-docker-build
#
## Configure Docker CE repo
#RUN dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#
## Configure the GitHub repo for the gh client
#RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
#
## VS Code requires git so we do that in Dockerfile before we get here
#RUN yum install -y \
#    docker-ce \
#    gh \
#    ;
#
## Need `GH_TOKEN` passed in as a secret to install gh-act
#RUN --mount=type=secret,id=gh_token,env=GH_TOKEN \
#    gh extension install nektos/gh-act
