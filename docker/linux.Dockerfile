FROM debian:13.2-slim AS flutter

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    wget \
    libfuse2 \
    fuse \
    file \
    clang \
    ninja-build \
    mesa-utils \
    libglu1-mesa \
    libgtk-3-dev \
    cmake \
    build-essential \
    git \
    lcov \
    libglu1-mesa \
    libsqlite3-0 \
    libsqlite3-dev \
    libmpv-dev \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ENV TAR_OPTIONS="--no-same-owner --no-same-permissions"
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="$PATH:/opt/flutter/bin"
RUN flutter config --enable-linux-desktop --no-enable-android --no-enable-ios --no-enable-web && flutter doctor && flutter precache --linux

WORKDIR /app

COPY . .

COPY ./docker/scripts/docker_linux_entrypoint.sh "/docker_entrypoint.sh"
RUN chmod +x "/docker_entrypoint.sh"

ENTRYPOINT [ "/docker_entrypoint.sh" ]
