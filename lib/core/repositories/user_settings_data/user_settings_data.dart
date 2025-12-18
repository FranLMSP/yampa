import 'package:yampa/core/player/enums.dart';
import 'package:yampa/models/user_settings.dart';

abstract class UserSettingsData {
  Future<UserSettings> getUserSettings();
  Future<void> saveUserSettings(UserSettings userSettings);
  Future<void> saveLastWindowSize(WindowSize windowSize);
  Future<void> saveUserTheme(UserThemeMode userTheme);
  Future<void> saveDefaultSortMode(SortMode sortMode);
  Future<UserThemeMode> getUserTheme();
  Future<SortMode> getDefaultSortMode();
  Future<WindowSize?> getLastWindowSize();
  Future<void> close();
}
