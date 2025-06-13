FROM almalinux:latest

RUN dnf install -y 'dnf-command(config-manager)'

# Configure the GitHub repo for the gh client
RUN dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# VS Code requires git so we do that in Dockerfile before we get here
RUN yum install --enablerepo crb -y \
    git \
    tree \
    python3-pip

COPY requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/requirements.txt

RUN groupadd -g 1001 luser && \
    useradd -m -u 1001 -g 1001 -s /bin/bash luser && \
    echo "luser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

SHELL ["/bin/bash", "-c"]

# Set the default user
USER luser
