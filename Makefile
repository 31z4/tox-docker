define expand_version
	${1} ${shell echo ${1} | cut -f 1,2 -d .} ${shell echo ${1} | cut -f 1 -d .}
endef

TOX_VERSIONS := $(shell sed -ne 's/tox==//p' requirements.in)
TOX_VERSIONS := $(call expand_version,${TOX_VERSIONS})

IMAGE_VERSIONS := $(shell git describe)
IMAGE_VERSIONS := $(call expand_version,${IMAGE_VERSIONS})

IMAGE_NAME := 31z4/tox

build:
	docker build --pull -t ${IMAGE_NAME}:latest .

buildx:
	docker buildx build --platform linux/amd64,linux/arm64/v8 --pull -t ${IMAGE_NAME}:latest .

test: build
	docker run -v ${CURDIR}/tests:/tests -w /tests -it --rm ${IMAGE_NAME}:latest

testx: buildx
	for platform in linux/amd64 linux/arm64/v8 ; do \
		docker run -v ${CURDIR}/tests:/tests -w /tests -it --rm  --platform $$platform ${IMAGE_NAME}:latest ; \
	done

tag:
	for tv in ${TOX_VERSIONS} ; do \
		docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:$$tv ; \
		for iv in ${IMAGE_VERSIONS} ; do \
			docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:$$tv-$$iv ; \
		done ; \
	done

tox-upgrade:
	pip-compile --generate-hashes requirements.in