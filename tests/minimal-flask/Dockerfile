FROM 31z4/tox

RUN set -eux; \
    cd ~; \
    git clone --depth 1 https://github.com/pallets/flask.git; \
    cd flask

WORKDIR /home/tox/flask