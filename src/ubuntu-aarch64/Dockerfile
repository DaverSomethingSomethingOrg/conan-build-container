FROM ubuntu:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y

RUN apt-get install --no-install-recommends -y \
    git \
    sudo \
    wget \
    vim \
    python3 \
    python3-pip

COPY requirements.txt /tmp
RUN pip install --no-cache-dir  --break-system-packages -r /tmp/requirements.txt

RUN groupadd -g 1001 luser && \
    useradd -m -u 1001 -g 1001 -s /bin/bash luser && \
    echo "luser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

SHELL ["/bin/bash", "-c"]

# Set the default user
WORKDIR /home/luser
USER luser
