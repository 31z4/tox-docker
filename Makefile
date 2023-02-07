define expand_version
	${1} ${shell echo ${1} | cut -f 1,2 -d .} ${shell echo ${1} | cut -f 1 -d .}
endef

TOX_VERSIONS := $(shell sed -ne 's/tox==//p' requirements.in)
TOX_VERSIONS := $(call expand_version,${TOX_VERSIONS})

IMAGE_VERSIONS := $(shell git describe)
IMAGE_VERSIONS := $(call expand_version,${IMAGE_VERSIONS})

ifdef PLATFORM
	PLATFORM_ARG := --platform ${PLATFORM}
endif

build:
	docker build --pull ${PLATFORM_ARG} -t 31z4/tox .

test-all: test-minimal test-minimal-custom test-minimal-flask

test-minimal:
	docker run -v ${CURDIR}/tests/minimal:/home/tox/tests -it --rm ${PLATFORM_ARG} 31z4/tox

test-minimal-custom:
	docker build ${PLATFORM_ARG} -t 31z4/tox-test-minimal-custom -f tests/minimal-custom/Dockerfile tests/minimal-custom
	docker run -v ${CURDIR}/tests/minimal-custom:/home/tox/tests -it --rm ${PLATFORM_ARG} 31z4/tox-test-minimal-custom

test-minimal-flask:
	docker build ${PLATFORM_ARG} -t 31z4/tox-test-minimal-flask -f tests/minimal-flask/Dockerfile tests/minimal-flask
	docker run -it --rm ${PLATFORM_ARG} 31z4/tox-test-minimal-flask run-parallel

buildx-and-push:
	tag_args="-t 31z4/tox:latest" ; \
	for tv in ${TOX_VERSIONS} ; do \
		tag_args="$$tag_args -t 31z4/tox:$$tv" ; \
		for iv in ${IMAGE_VERSIONS} ; do \
			tag_args="$$tag_args -t 31z4/tox:$$tv-$$iv" ; \
		done ; \
	done; \
	docker buildx build --platform linux/amd64,linux/arm64/v8 --pull --push $$tag_args .

tox-upgrade:
	pip-compile --generate-hashes requirements.in