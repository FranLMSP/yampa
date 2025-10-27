lint:
	./scripts/lint.sh

lint-all:
	flutter analyze

FILE ?= .
DOCKER_IMAGE ?= yampa_linux_builder
format:
	dart format $(FILE)

.PHONY: docker/clean-image build/linux build/windows build/android build/all

docker/clean-image:
	docker image rm $(DOCKER_IMAGE)

build-dockerfile:
	docker build -t $(DOCKER_IMAGE) -f docker/linux.Dockerfile ./

build/linux:
	make build-dockerfile \
	&& docker run --rm -v ./:/app/project/ -v yampa_build:/app/project/build/ $(DOCKER_IMAGE) "flutter clean && flutter doctor && flutter build linux --release"

build/windows:
	echo "TODO"

build/android:
	make build-dockerfile \
	&& docker run --rm -v ./:/app/project/ -v yampa_build:/app/project/build/ $(DOCKER_IMAGE) "flutter clean && flutter doctor && flutter build apk --release"

build/all: build/linux build/windows build/android
