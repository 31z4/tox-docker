define expand_version
	${1} ${shell echo ${1} | cut -f 1,2 -d .} ${shell echo ${1} | cut -f 1 -d .}
endef

TOX_VERSION := $(shell sed -ne 's/tox==//p' requirements.in)
TOX_VERSIONS := $(call expand_version,${TOX_VERSION})

IMAGE_VERSION := $(shell git describe)
IMAGE_VERSIONS := $(call expand_version,${IMAGE_VERSION})

ifdef PLATFORM
	PLATFORM_ARG := --platform ${PLATFORM}
endif

build:
	docker build --no-cache --pull ${PLATFORM_ARG} -t 31z4/tox .

test-all: test-minimal test-minimal-custom test-minimal-flask

test-minimal:
	docker run -v ${CURDIR}/tests/minimal:/tests -it --rm ${PLATFORM_ARG} 31z4/tox

test-minimal-custom:
	docker build ${PLATFORM_ARG} -t 31z4/tox-test-minimal-custom -f tests/minimal-custom/Dockerfile tests/minimal-custom
	docker run -v ${CURDIR}/tests/minimal-custom:/tests -it --rm ${PLATFORM_ARG} 31z4/tox-test-minimal-custom

test-minimal-flask:
	docker build ${PLATFORM_ARG} -t 31z4/tox-test-minimal-flask -f tests/minimal-flask/Dockerfile tests/minimal-flask
	docker run -it --rm ${PLATFORM_ARG} 31z4/tox-test-minimal-flask run-parallel --skip-env style

buildx-and-push:
	tag_args="-t 31z4/tox:latest" ; \
	for tv in ${TOX_VERSIONS} ; do \
		tag_args="$$tag_args -t 31z4/tox:$$tv" ; \
		for iv in ${IMAGE_VERSIONS} ; do \
			tag_args="$$tag_args -t 31z4/tox:$$tv-$$iv" ; \
		done ; \
	done; \
	docker buildx build --platform linux/amd64,linux/arm64/v8 --no-cache --pull --push $$tag_args .

tags:
	@tags="latest"; \
	for tv in ${TOX_VERSIONS} ; do \
		tags="$$tv, $$tags" ; \
		for iv in ${IMAGE_VERSIONS} ; do \
			tags="$$tv-$$iv, $$tags" ; \
		done ; \
	done; \
	echo "Tags: $$tags"
	@echo "GitCommit: $$(git rev-list -n 1 ${IMAGE_VERSION})"

tox-upgrade:
	pip-compile --generate-hashes requirements.in
