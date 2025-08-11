FROM almalinux:latest AS conan-base

RUN dnf install -y 'dnf-command(config-manager)' yum-utils
RUN yum-config-manager --enable crb

RUN yum install -y \
    ca-certificates \
    procps-ng \
    git \
    git-lfs \
    sudo \
    tree \
    python3 \
    python3-pip \
    python-unversioned-command.noarch \
    wget \
    rpmdevtools \
    rpmlint \
    perl-File-Compare \
    perl-FindBin \
    perl-IPC-Cmd \
    perl-Digest-SHA \
    perl-threads \
    perl-Thread-Queue \
    perl-open \
    texinfo \
    libstdc++-devel \
    glibc-devel \
    glibc-headers

# Setup Certs and toolchain Yum repo(s)
COPY config /
RUN update-ca-trust

ENV MINIMAL_PATH="${PATH}"
ENV CC=gcc
ENV CXX=g++

# Make sure VIRTUAL_ENV PATH is always ahead of any other path to python
ENV VIRTUAL_ENV="/opt/python-venv"
RUN python3 -m venv "${VIRTUAL_ENV}"
ENV PATH="${VIRTUAL_ENV}/bin:${MINIMAL_PATH}"
COPY requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/requirements.txt


######################################################################
# Bootstrapping image with Vendor gcc toolchain
#
FROM conan-base AS conan-bootstrap
RUN yum install -y \
    make \
    cmake \
    binutils \
    gcc \
    gcc-c++ \
    libstdc++-static

# Now that we have a build-worthy environment, detect conan default profile
# - Do it here to save more time starting the build!
RUN conan profile detect

######################################################################
# Build image with our own gcc toolchain
#
FROM conan-base AS conan-build
ARG PKG_PREFIX="opt-toolchain-"
ARG TOOLCHAIN_PREFIX="/opt/toolchain"

RUN yum install --enablerepo conan-toolchain -y \
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

# Configure Docker CE repo
RUN dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Configure the GitHub repo for the gh client
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# VS Code requires git so we do that in Dockerfile before we get here
RUN yum install -y \
    docker-ce \
    gh \
    ;

# Need `GH_TOKEN` passed in as a secret to install gh-act
RUN --mount=type=secret,id=gh_token,env=GH_TOKEN \
    gh extension install nektos/gh-act
