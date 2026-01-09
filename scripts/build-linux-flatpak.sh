#!/bin/bash

set -e

# 1. Build the Flutter app
flutter build linux --release

# 2. Setup Flatpak (removes need for pre-installation in Dockerfile)
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 3. Build the Flatpak
mkdir -p build/flatpak
# Using --user and --install-deps-from=flathub to manage runtimes at runtime
flatpak-builder --user --install-deps-from=flathub --force-clean --repo=build/flatpak/repo build/flatpak/build com.francoacg.Yampa.yaml

# 4. Export the Flatpak bundle
mkdir -p outputs
flatpak build-bundle build/flatpak/repo outputs/yampa.flatpak com.francoacg.Yampa
