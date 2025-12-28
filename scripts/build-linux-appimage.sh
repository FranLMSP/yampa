#!/bin/bash

set -e

PROJECT_ROOT=$(pwd)
BIN_DIR="$PROJECT_ROOT/scripts/bin"
mkdir -p "$BIN_DIR"

if [ ! -f "$BIN_DIR/linuxdeploy" ]; then
    wget -O "$BIN_DIR/linuxdeploy" https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
    chmod +x "$BIN_DIR/linuxdeploy"
fi

if [ ! -f "$BIN_DIR/appimagetool" ]; then
    wget -O "$BIN_DIR/appimagetool" https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x "$BIN_DIR/appimagetool"
fi

flutter build linux --release

rm -rf AppDir || true
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/lib
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/512x512/apps

cp build/linux/x64/release/bundle/yampa AppDir/usr/bin/
cp -r build/linux/x64/release/bundle/data AppDir/usr/bin/
cp -r build/linux/x64/release/bundle/lib AppDir/usr/bin/

cp assets/icon/icon.png AppDir/usr/share/icons/hicolor/512x512/apps/yampa.png

cat <<EOF > AppDir/usr/share/applications/yampa.desktop
[Desktop Entry]
Type=Application
Name=yampa
Exec=yampa
Icon=yampa
Categories=AudioVideo;Audio;Player;
Terminal=false
EOF

export LDAI_OUTPUT="./outputs/yampa-x64.AppImage"
mkdir -p ./outputs

# Automatically find all libraries in the Flutter bundle and pass them to linuxdeploy.
# This ensures they are moved to usr/lib and the RPATH is correctly updated.
EXTRA_LIBS=""
for lib in build/linux/x64/release/bundle/lib/*.so*; do
    EXTRA_LIBS="$EXTRA_LIBS --library $lib"
done

# Set LD_LIBRARY_PATH so linuxdeploy can find the Flutter plugin libraries during scan
export LD_LIBRARY_PATH="$PROJECT_ROOT/build/linux/x64/release/bundle/lib:$LD_LIBRARY_PATH"

# Run linuxdeploy to bundle everything into AppDir/usr/lib
"$BIN_DIR/linuxdeploy" \
    --appdir AppDir \
    -e AppDir/usr/bin/yampa \
    -i AppDir/usr/share/icons/hicolor/512x512/apps/yampa.png \
    -d AppDir/usr/share/applications/yampa.desktop \
    $EXTRA_LIBS \
    --library /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 \
    --library /usr/lib/x86_64-linux-gnu/libmpv.so.2

# 5. Fix RPATH / AOT Loading
# linuxdeploy moves libraries to usr/lib, but Flutter's engine is hardcoded 
# to look for libapp.so (the AOT snapshot) and other libs in a 'lib' folder 
# relative to the executable. We create symlinks to satisfy this.
# Ensure the lib directory exists in usr/bin
mkdir -p AppDir/usr/bin/lib
for lib in AppDir/usr/lib/*.so*; do
    libname=$(basename "$lib")
    if [ ! -e "AppDir/usr/bin/lib/$libname" ]; then
        ln -sf "../../lib/$libname" "AppDir/usr/bin/lib/$libname"
    fi
done

# 6. Build final AppImage
"$BIN_DIR/appimagetool" AppDir "$LDAI_OUTPUT"
