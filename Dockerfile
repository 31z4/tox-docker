FROM ubuntu:22.04 as builder

ENV PATH=/pyenv/shims:/pyenv/bin:${PATH} \
    PYENV_ROOT=/pyenv

ARG PYENV_RELEASE=2.3.11
ARG PYENV_CHECKSUM=c133556734a301e4942202d4e2cffc5e1ddacf74a3744d0c092320903e582791

COPY python-versions.txt /pyenv/version

# Build and install Python using pyenv.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gcc \
        libbz2-dev \
        libc6-dev \
        libffi-dev \
        libgdbm-dev \
        libgdbm-compat-dev \
        libreadline-dev \
        libssl-dev \
        libsqlite3-dev \
        liblzma-dev \
        make \
        tk-dev \
        zlib1g-dev; \
    curl -Ls -o pyenv.tar.gz https://github.com/pyenv/pyenv/archive/v${PYENV_RELEASE}.tar.gz; \
    echo ${PYENV_CHECKSUM} pyenv.tar.gz | sha256sum --strict --check; \
    tar -xzf pyenv.tar.gz --strip=1 -C /pyenv; \
    export PYTHON_CONFIGURE_OPTS=" \
        --enable-loadable-sqlite-extensions \
        --enable-option-checking=fatal \
        --enable-optimizations \
        --enable-shared \
        --with-lto \
    "; \
    for version in `cat /pyenv/version`; do \
        pyenv install -v ${version}; \
    done; \
    find /pyenv/versions -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
        \) -exec rm -rf '{}' + \
    ;

# Install tox.
COPY requirements.txt /
RUN pip install --no-deps -r /requirements.txt

FROM ubuntu:22.04

# Install ca-certificates (required for pip) and add a user with an explicit UID/GID.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    groupadd -r tox --gid=10000; \
    useradd --no-log-init -r -g tox --uid=10000 tox

COPY --from=builder /pyenv /pyenv

ENV PATH=/pyenv/shims:/pyenv/bin:${PATH} \
    PYENV_ROOT=/pyenv

USER tox

ENTRYPOINT ["python3.11", "-m", "tox"]