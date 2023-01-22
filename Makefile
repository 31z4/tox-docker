build:
	docker build --pull -t 31z4/tox:latest .

buildx:
	docker buildx build --platform linux/amd64,linux/arm64/v8 --pull -t 31z4/tox:latest .

test: build
	docker run -v $(CURDIR)/tests:/tests -w /tests -it --rm 31z4/tox:latest

testx: buildx
	for platform in linux/amd64 linux/arm64/v8 ; do \
		docker run -v $(CURDIR)/tests:/tests -w /tests -it --rm  --platform $$platform 31z4/tox:latest ; \
	done

tox-upgrade:
	pip-compile --generate-hashes requirements.in