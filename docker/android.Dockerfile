FROM debian:13.2-slim AS flutter

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    git \
    lcov \
    libglu1-mesa \
    libsqlite3-0 \
    libsqlite3-dev \
    libmpv-dev \
    ca-certificates \
    unzip \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*


ENV TAR_OPTIONS="--no-same-owner --no-same-permissions"
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV SDK_ROOT="/opt/android/sdks"
ENV ANDROID_HOME="$SDK_ROOT/android-sdk" \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="$PATH:/opt/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"


RUN mkdir -p "$ANDROID_HOME" \
    && command_line_tools_url="$(curl -s https://developer.android.com/studio/ | grep -o 'https://dl.google.com/android/repository/commandlinetools-linux-[0-9]\+_latest.zip')" \
    && curl -o android-cmdline-tools.zip "$command_line_tools_url" \
    && mkdir -p "$ANDROID_HOME/cmdline-tools/" \
    && unzip -q android-cmdline-tools.zip -d "$ANDROID_HOME/cmdline-tools/" \
    && mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" \
    && rm android-cmdline-tools.zip \
    && (yes || true) | sdkmanager --licenses \
    && sdkmanager --update \
    && (yes || true) | sdkmanager \
    "platform-tools" \
    "build-tools;36.1.0" \
    "ndk;29.0.14206865" \
    "cmake;4.1.2" \
    && for version in 36; do (yes || true) | sdkmanager "platforms;android-$version"; done \
    && flutter config --enable-android --no-enable-ios --no-enable-web --no-enable-linux-desktop \
    && (yes || true) | flutter doctor --android-licenses \
    && flutter precache --android

WORKDIR /app

COPY . .

COPY ./docker/scripts/docker_linux_entrypoint.sh "/docker_entrypoint.sh"
RUN chmod +x "/docker_entrypoint.sh"

ENTRYPOINT ["/docker_entrypoint.sh"]