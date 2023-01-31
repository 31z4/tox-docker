define expand_version
	${1} ${shell echo ${1} | cut -f 1,2 -d .} ${shell echo ${1} | cut -f 1 -d .}
endef

TOX_VERSIONS := $(shell sed -ne 's/tox==//p' requirements.in)
TOX_VERSIONS := $(call expand_version,${TOX_VERSIONS})

IMAGE_VERSIONS := $(shell git describe)
IMAGE_VERSIONS := $(call expand_version,${IMAGE_VERSIONS})

IMAGE_NAME = 31z4/tox
IMAGE_TAG ?= latest

ifdef PLATFORM
	PLATFORM_ARG := --platform ${PLATFORM}
endif

build:
	docker build --pull ${PLATFORM_ARG} -t ${IMAGE_NAME}:${IMAGE_TAG} .

test:
	docker run -v ${CURDIR}/tests:/tests -w /tests -it --rm ${PLATFORM_ARG} ${IMAGE_NAME}:${IMAGE_TAG}

buildx-and-push:
	tag_args="-t ${IMAGE_NAME}:latest" ; \
	for tv in ${TOX_VERSIONS} ; do \
		tag_args="$$tag_args -t ${IMAGE_NAME}:$$tv" ; \
		for iv in ${IMAGE_VERSIONS} ; do \
			tag_args="$$tag_args -t ${IMAGE_NAME}:$$tv-$$iv" ; \
		done ; \
	done; \
	docker buildx build --platform linux/amd64,linux/arm64/v8 --pull --push $$tag_args .

tox-upgrade:
	pip-compile --generate-hashes requirements.in