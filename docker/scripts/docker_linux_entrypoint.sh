#!/usr/bin/env bash

dart --disable-analytics
flutter --disable-analytics

flutter pub get

eval "$@"
