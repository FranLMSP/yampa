lint:
	./scripts/lint.sh

lint-all:
	flutter analyze

FILE ?= .
DOCKER_IMAGE_LINUX ?= yampa_linux_builder
DOCKER_IMAGE_ANDROID ?= yampa_android_builder
format:
	dart format $(FILE)

.PHONY: docker/clean-images build/linux build/windows build/android build/all

docker/clean-images:
	docker image rm $(DOCKER_IMAGE_LINUX) \
	&& docker image rm $(DOCKER_IMAGE_ANDROID)

docker/build-image/linux:
	docker build -t $(DOCKER_IMAGE_LINUX) -f docker/linux.Dockerfile ./

docker/build-image/android:
	docker build -t $(DOCKER_IMAGE_ANDROID) -f docker/android.Dockerfile ./

build/linux:
	make docker/build-image/linux \
	&& docker run --rm -v ./:/app/project/ -v yampa_build:/app/project/build/ $(DOCKER_IMAGE_LINUX) "flutter clean && flutter doctor && flutter build linux --release"

build/android:
	make docker/build-image/android \
	&& docker run --rm -v ./:/app/project/ -v yampa_build:/app/project/build/ $(DOCKER_IMAGE_ANDROID) "flutter clean && flutter doctor && flutter build apk --release"

build/windows:
	echo "TODO"

build/all: build/linux build/windows build/android
