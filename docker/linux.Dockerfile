FROM ubuntu:22.04

RUN apt update -y && apt upgrade -y && apt install -y wget curl git unzip xz-utils zip libglu1-mesa libmpv-dev libsqlite3-0 libsqlite3-dev build-essential cmake ninja-build libgtk-3-dev pkg-config clang mesa-utils

RUN mkdir /tmp/downloads \
    && cd /tmp/downloads \
    && wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.7-stable.tar.xz -O /tmp/downloads/flutter_linux_stable.tar.xz \
    && mkdir -p /app/develop \
    && cd /app/develop \
    && tar -xf /tmp/downloads/flutter_linux_stable.tar.xz -C /app/develop/

ENV PATH="$PATH:/app/develop/flutter/bin"

RUN useradd -m -u 1000 -s /bin/bash builder
RUN mkdir -p /app/project/build
RUN chown -R builder:builder /app/project/
USER builder

WORKDIR /app/project

COPY ./android .
COPY ./lib .
COPY ./linux .
COPY ./test .
COPY ./.gitignore .
COPY ./.metadata .
COPY ./analysis_options.yaml .
COPY ./pubspec.lock .
COPY ./pubspec.yaml .

RUN dart --disable-analytics
RUN flutter --disable-analytics
RUN flutter pub get

ENTRYPOINT ["bash", "-lc"]
