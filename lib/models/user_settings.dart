import 'package:yampa/core/player/enums.dart';

enum UserThemeMode {
  dark,
  light,
  system, // TODO: it would be nice if the app was able to detect the accent colors of the user's system's theme
  custom, // TODO: eventually allow the user to customize the colors of the app
}

class WindowSize {
  final double width;
  final double height;

  WindowSize({required this.width, required this.height});
}

class UserSettings {
  final SortMode defaultSortMode;
  final WindowSize? lastWindowSize;
  final UserThemeMode? themeMode;
  final String? languageCode;

  UserSettings({
    this.defaultSortMode = SortMode.titleAtoZ,
    this.themeMode = UserThemeMode.system,
    this.lastWindowSize,
    this.languageCode,
  });
}
