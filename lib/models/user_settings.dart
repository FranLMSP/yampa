import 'package:yampa/core/player/enums.dart';

class WindowSize {
  final double width;
  final double height;

  WindowSize({required this.width, required this.height});
}

class UserSettings {
  final SortMode defaultSortMode;
  final WindowSize? lastWindowSize;

  UserSettings({
    this.defaultSortMode = SortMode.titleAtoZ,
    this.lastWindowSize,
  });
}
