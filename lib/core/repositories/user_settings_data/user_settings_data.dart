import 'package:yampa/models/user_settings.dart';

abstract class UserSettingsData {
  Future<UserSettings> getUserSettings();
  Future<void> saveUserSettings(UserSettings userSettings);
  Future<void> saveLastWindowSize(WindowSize windowSize);
  Future<WindowSize?> getLastWindowSize();
  Future<void> close();
}
