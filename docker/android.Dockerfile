FROM ubuntu:22.04

RUN apt update -y && apt upgrade -y && apt install -y wget curl git unzip xz-utils zip libglu1-mesa libmpv-dev libsqlite3-0 libsqlite3-dev build-essential cmake ninja-build libgtk-3-dev pkg-config clang mesa-utils unzip xz-utils zip libglu1-mesa openjdk-17-jdk

RUN mkdir /tmp/downloads \
    && cd /tmp/downloads \
    && wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.7-stable.tar.xz -O /tmp/downloads/flutter_linux_stable.tar.xz \
    && mkdir -p /app/develop \
    && cd /app/develop \
    && tar -xf /tmp/downloads/flutter_linux_stable.tar.xz -C /app/develop/

ENV PATH="$PATH:/app/develop/flutter/bin"

WORKDIR /opt/tmp
RUN curl https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip > cmdlinetools.zip
RUN unzip cmdlinetools.zip
RUN rm cmdlinetools.zip

RUN mkdir -p /opt/android_sdk
RUN yes|./cmdline-tools/bin/sdkmanager --sdk_root=/opt/android_sdk "cmdline-tools;latest"
RUN rm -r /opt/tmp
ENV ANDROID_HOME="/opt/android_sdk"
ENV PATH="${PATH}:/opt/android_sdk/cmdline-tools/latest/bin"

RUN yes|sdkmanager --sdk_root="/opt/android_sdk" "platform-tools" "platforms;android-33"  "build-tools;34.0.0"
RUN yes|sdkmanager --licenses


RUN useradd -m -u 1000 -s /bin/bash builder
RUN mkdir -p /app/project/build
RUN chown -R builder:builder /app/project/
RUN chown -R builder:builder $ANDROID_HOME
USER builder

WORKDIR /app/project

COPY ./android .
COPY ./lib .
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
