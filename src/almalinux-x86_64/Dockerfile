FROM almalinux:latest AS build-base

USER root

RUN dnf install -y 'dnf-command(config-manager)'

# Configure the GitHub repo for the gh client
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# VS Code requires git so we do that in Dockerfile before we get here
RUN yum install --enablerepo crb -y \
    procps-ng \
    git \
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

ENV CC=gcc
ENV CXX=g++

COPY requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/requirements.txt

FROM build-base AS bootstrap-base
RUN yum install --enablerepo crb -y \
    make \
    cmake \
    binutils \
    gcc \
    gcc-c++ \
    libstdc++-static

