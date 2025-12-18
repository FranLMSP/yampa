import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yampa/models/user_settings.dart';

enum ViewMode { portrait, landscape, desktop }

ViewMode getViewMode(BoxConstraints constraints) {
  if (constraints.maxWidth <= 820) {
    return ViewMode.portrait;
  }
  return ViewMode.landscape;
}

Future<void> showButtonActionMessage(String message) async {
  if (isPlatformMobile()) {
    await Fluttertoast.cancel();
    await Fluttertoast.showToast(msg: message);
  }
}

bool isPlatformDesktop() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

bool isPlatformMobile() {
  return Platform.isAndroid || Platform.isIOS;
}


ThemeMode getMaterialThemeFromUserTheme(UserThemeMode? userThemeMode) {
  final themeMap = {
    UserThemeMode.light: ThemeMode.light,
    UserThemeMode.dark: ThemeMode.dark,
    UserThemeMode.system: ThemeMode.system,
    UserThemeMode.custom: ThemeMode.system,
  };

  return themeMap[userThemeMode] ?? ThemeMode.system;
}
