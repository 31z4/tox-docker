FROM 31z4/tox

USER root

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        python3.8; \
    rm -rf /var/lib/apt/lists/*

USER tox
