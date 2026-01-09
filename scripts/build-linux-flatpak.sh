#!/bin/bash

set -e

flutter build linux --release

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

mkdir -p build/flatpak
flatpak-builder --user --install-deps-from=flathub --force-clean --repo=build/flatpak/repo build/flatpak/build com.francoacg.Yampa.yaml

mkdir -p outputs
flatpak build-bundle build/flatpak/repo outputs/yampa.flatpak com.francoacg.Yampa
