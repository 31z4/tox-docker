FROM ubuntu:22.04

ARG GPG_KEY=F23C5A6CF475977595C89F51BA6932366A755776

# Install common build dependencies, add deadsnakes PPA and cleanup.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        g++ \
        gcc \
        git \
        make; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get install -y --no-install-recommends \
        dirmngr \
        gnupg; \
    \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$GPG_KEY"; \
    gpg -o /usr/share/keyrings/deadsnakes.gpg --export "$GPG_KEY"; \
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/deadsnakes.gpg] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" >> /etc/apt/sources.list; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

# Install Python and pip and cleanup.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        python3.8 \
        python3.9 \
        python3.10 \
        python3.11 \
        python3.12 \
        \
        python3.8-dev \
        python3.9-dev \
        python3.10-dev \
        python3.11-dev \
        python3.12-dev \
        \
        python3.8-venv \
        python3.9-venv \
        python3.10-venv \
        python3.11-venv \
        python3.12-venv \
        \
        python3.8-distutils \
        python3.9-distutils \
        python3.10-distutils \
        python3.11-distutils \
        python3.12-distutils \
        \
        python3-pip; \
    rm -rf /var/lib/apt/lists/*; \
    \
    # We still use Python 3.11 as the default interpreter because system pip
    # is incompatible with Python 3.12 due to deprecated pkgutil.ImpImporter.
    python3.11 -m pip install --upgrade pip

# Install tox and add a user with an explicit UID/GID.
COPY requirements.txt /
RUN set -eux; \
    pip3.11 install --no-deps -r /requirements.txt; \
    groupadd -r tox --gid=10000; \
    useradd --no-log-init -r -g tox -m --uid=10000 tox; \
    mkdir /tests; \
    chown tox:tox /tests; \
    chown tox:tox /home/tox

WORKDIR /tests
VOLUME /tests

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
USER tox
CMD ["tox"]
