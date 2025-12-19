#!/bin/bash

set -e

PROJECT_ROOT=$(pwd)
BIN_DIR="$PROJECT_ROOT/scripts/bin"
mkdir -p "$BIN_DIR"

if [ ! -f "$BIN_DIR/linuxdeploy" ]; then
    wget -O "$BIN_DIR/linuxdeploy" https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
    chmod +x "$BIN_DIR/linuxdeploy"
fi

flutter build linux --release

rm -rf AppDir || true
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/lib
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/512x512/apps

cp -r build/linux/x64/release/bundle/* AppDir/usr/bin/
cp assets/icon/icon.png AppDir/usr/share/icons/hicolor/512x512/apps/yampa.png

cat <<EOF > AppDir/usr/share/applications/yampa.desktop
[Desktop Entry]
Type=Application
Name=yampa
Exec=yampa
Icon=yampa
Categories=Utility;
Terminal=false
EOF

export OUTPUT="yampa-x86_64.AppImage"

"$BIN_DIR/linuxdeploy" \
    --appdir AppDir \
    -e AppDir/usr/bin/yampa \
    -i AppDir/usr/share/icons/hicolor/512x512/apps/yampa.png \
    -d AppDir/usr/share/applications/yampa.desktop \
    --library /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 \
    --library /usr/lib/x86_64-linux-gnu/libmpv.so.2 \
    --output appimage
