lint:
	./scripts/lint.sh

lint-all:
	flutter analyze

FILE ?= .
DOCKER_IMAGE_LINUX ?= yampa_linux_builder
DOCKER_IMAGE_ANDROID ?= yampa_android_builder
DOCKER_IMAGE_WINDOWS ?= yampa_windows_builder

format:
	dart format $(FILE)

.PHONY: docker/clean-images build/linux build/windows build/android build/all

docker/clean-images:
	docker image rm $(DOCKER_IMAGE_LINUX) || true
	docker image rm $(DOCKER_IMAGE_ANDROID) || true
	docker image rm $(DOCKER_IMAGE_WINDOWS) || true

docker/build-image/linux:
	docker build -t $(DOCKER_IMAGE_LINUX) -f docker/linux.Dockerfile ./

docker/build-image/android:
	docker build -t $(DOCKER_IMAGE_ANDROID) -f docker/android.Dockerfile ./

docker/build-image/windows:
	echo "There is no cross compilation from Linux at the moment"

build/linux:
	make docker/build-image/linux \
	&& docker run --rm --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined -v ./:/app $(DOCKER_IMAGE_LINUX) "flutter clean && flutter doctor && ./scripts/build-linux-appimage.sh"

build/android:
	make docker/build-image/android \
	&& docker run --rm -v ./:/app $(DOCKER_IMAGE_ANDROID) "flutter clean && flutter doctor && flutter build apk --release"

build/windows:
	echo "There is no cross compilation from Linux at the moment"

build/all: build/linux build/windows build/android

.PHONY: release/get-latest-tag release/new-tag


release/get-latest-tag:
	git tag --sort=creatordate | tail -n 1

DRY_RUN ?= --dry-run
release/new-tag:
	./scripts/version-tag.sh $(DRY_RUN)
