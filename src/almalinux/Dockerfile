FROM almalinux:latest AS conan-base

# Set up a baseline install before proceeding with our customizations
RUN dnf install -y 'dnf-command(config-manager)' yum-utils \
 && yum-config-manager --enable crb \
 && yum install -y \
    ca-certificates \
    gnupg2 \
    openssh \
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

# Copy over any needed source files or configuration
COPY config /

# Setup Certs and toolchain Yum repo(s)
COPY keys/ /tmp/keys/
RUN if [ -f "/tmp/keys/InternalCA.crt" ]; then \
      mv /tmp/keys/InternalCA.crt /etc/pki/ca-trust/source/anchors/; \
      update-ca-trust; \
    fi; \
    rm -fR /tmp/keys/;

ENV MINIMAL_PATH="${PATH}"
ENV CC=gcc
ENV CXX=g++

# Make sure VIRTUAL_ENV PATH is always ahead of any other path to python
ENV VIRTUAL_ENV="/opt/python-venv"
RUN python3 -m venv "${VIRTUAL_ENV}"
ENV PATH="${VIRTUAL_ENV}/bin:${MINIMAL_PATH}"

COPY python-requirements.txt* /tmp
RUN if [ -f "/tmp/python-requirements.txt" ]; then \
      pip install --no-cache-dir -r /tmp/python-requirements.txt; \
      rm /tmp/python-requirements.txt; \
    fi;


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

# Configure Docker and GitHub repos and install clients
RUN dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
 && dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo \
 && yum install -y \
    docker-ce \
    gh \
    ;

# Need `GH_TOKEN` passed in as a secret to install gh-act
RUN --mount=type=secret,id=gh_token,env=GH_TOKEN \
    gh extension install nektos/gh-act
